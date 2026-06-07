"""
CNN_BiLSTM2.py — Transformer + BiLSTM architecture

Based on the 1st place solution by Baurzhan Urazalinov in the Kaggle
"TLVMC Parkinson's Freezing of Gait Prediction" competition (mAP 0.514).

Architecture overview:
    Input (raw AccV, AccML, AccAP + jerk features)
        │
    Linear projection  →  embed raw + jerk into model dimension
        │
    5× Transformer Encoder  →  capture global temporal dependencies
        │
    3× Bidirectional LSTM   →  capture sequential/directional context
        │
    Dense(1) + Sigmoid      →  P(FoG)

Key insight from the competition:
  - Transformers excel at global context (relating the start and end of a
    freeze episode) but struggle with local sequential order.
  - BiLSTMs on top enforce sequential ordering the Transformer ignores.
  - Together they outperform either architecture alone.
"""

import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras import layers, callbacks, regularizers
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt

# --- Config --------------------------------------
PREPARED    = Path("data/prepared")
FS          = 128           # Hz
WINDOW_SIZE = 256           # 2 seconds at 128 Hz
N_RAW       = 3             # AccV, AccML, AccAP
N_JERK      = 3             # d/dt of each acceleration axis
N_FEATURES  = N_RAW + N_JERK  # 6 total input channels

# Transformer hyperparameters (from 1st place solution)
D_MODEL     = 128           # embedding / model dimension
N_HEADS     = 4             # attention heads (D_MODEL must be divisible)
N_ENC       = 5             # number of Transformer encoder layers
FFN_DIM     = 256           # feed-forward network hidden size inside each encoder
DROPOUT_T   = 0.1           # Transformer dropout (kept low as in the original)

# BiLSTM hyperparameters
LSTM_UNITS  = [128, 64, 32] # units for each of the 3 stacked BiLSTM layers

EPOCHS      = 80
BATCH_SIZE  = 64
L2          = 1e-4
MAX_TRAIN_WINDOWS = 12000   # CPU feasibility cap — set None for full dataset
# -------------------------------------------------


# ── Step 1: Jerk feature computation ─────────────────────────────────────────
#
# Jerk = rate of change of acceleration (d/dt of AccV, AccML, AccAP).
# In FoG episodes the acceleration signal becomes erratic — the jerk
# (how fast the signal is changing) spikes sharply. Including jerk gave
# top Kaggle solutions ~7.5% improvement in mAP over raw signals alone.
# We compute it as a simple finite difference along the time axis and
# append it as 3 additional channels, giving a (256, 6) input per window.

def add_jerk(X: np.ndarray) -> np.ndarray:
    """Append jerk (first difference of acc) as 3 extra channels.

    Args:
        X: shape (N, T, 3) — raw accelerometer windows
    Returns:
        shape (N, T, 6) — raw + jerk concatenated on channel axis
    """
    # Difference along time axis; pad first timestep with zeros so shape is preserved
    jerk = np.diff(X, axis=1, prepend=X[:, :1, :])
    return np.concatenate([X, jerk], axis=-1).astype(np.float32)


# ── Step 2: Transformer Encoder block ────────────────────────────────────────
#
# Each encoder block contains:
#   1. Multi-Head Self-Attention  — every timestep attends to all others,
#      letting the model learn "this tremor at t=50 relates to the hesitation
#      at t=10" without distance limitations that RNNs have.
#   2. Add & LayerNorm (residual) — stabilises training in deep nets.
#   3. Feed-Forward Network (FFN) — two Dense layers applied position-wise,
#      adding non-linearity after attention.
#   4. Add & LayerNorm (residual) — again for stability.
#
# Five stacked encoders give the model progressively more abstract
# representations of the 2-second IMU window.

def transformer_encoder_block(x, d_model, n_heads, ffn_dim, dropout_rate):
    # Multi-Head Self-Attention
    attn_out = layers.MultiHeadAttention(
        num_heads=n_heads, key_dim=d_model // n_heads,
        dropout=dropout_rate,
    )(x, x)                          # query=key=value=x (self-attention)
    attn_out = layers.Dropout(dropout_rate)(attn_out)
    x = layers.LayerNormalization(epsilon=1e-6)(x + attn_out)  # residual

    # Position-wise Feed-Forward Network
    ffn_out = layers.Dense(ffn_dim, activation="relu")(x)
    ffn_out = layers.Dropout(dropout_rate)(ffn_out)
    ffn_out = layers.Dense(d_model)(ffn_out)
    ffn_out = layers.Dropout(dropout_rate)(ffn_out)
    x = layers.LayerNormalization(epsilon=1e-6)(x + ffn_out)   # residual

    return x


# ── Step 3: Positional Encoding ───────────────────────────────────────────────
#
# Transformers have no built-in sense of order — without positional encoding
# they treat the sequence as a set. We inject sinusoidal position signals
# (different frequencies per dimension) so the model knows timestep 0
# comes before timestep 255. This is the same encoding used in the original
# "Attention Is All You Need" paper.

def positional_encoding(seq_len, d_model):
    positions = np.arange(seq_len)[:, np.newaxis]        # (T, 1)
    dims      = np.arange(d_model)[np.newaxis, :]        # (1, D)
    angles    = positions / np.power(10000, (2 * (dims // 2)) / d_model)
    angles[:, 0::2] = np.sin(angles[:, 0::2])            # even dims → sin
    angles[:, 1::2] = np.cos(angles[:, 1::2])            # odd  dims → cos
    return tf.cast(angles[np.newaxis, :, :], tf.float32) # (1, T, D)


# ── Step 4: Full model ────────────────────────────────────────────────────────

def build_model(window_size=WINDOW_SIZE, n_features=N_FEATURES):
    reg = regularizers.l2(L2)
    inp = layers.Input(shape=(window_size, n_features), name="raw_jerk")

    # ── 4a. Linear projection ─────────────────────────────────────────────────
    # Project the 6-channel input into D_MODEL dimensions so every timestep
    # has the same embedding size the Transformer expects.
    x = layers.Dense(D_MODEL, kernel_regularizer=reg)(inp)   # (B, T, D_MODEL)

    # ── 4b. Positional encoding ───────────────────────────────────────────────
    # Add fixed sinusoidal position signals — not learned, but fixed math.
    pos_enc = positional_encoding(window_size, D_MODEL)
    x = x + pos_enc                                           # (B, T, D_MODEL)
    x = layers.Dropout(DROPOUT_T)(x)

    # ── 4c. 5× Transformer Encoder layers ────────────────────────────────────
    # Each layer refines the representation. Early layers capture low-level
    # patterns (sudden jerk spikes); later layers capture high-level context
    # (a tremor following a turn = FoG onset vs. normal turn).
    for _ in range(N_ENC):
        x = transformer_encoder_block(x, D_MODEL, N_HEADS, FFN_DIM, DROPOUT_T)
                                                              # (B, T, D_MODEL)

    # ── 4d. 3× Bidirectional LSTM layers ─────────────────────────────────────
    # The Transformer output is a sequence (B, T, D_MODEL). BiLSTMs process
    # this left-to-right and right-to-left simultaneously, enforcing causal
    # sequential ordering the Transformer lacks.
    #
    # return_sequences=True on the first two passes the full sequence to the
    # next LSTM; False on the last collapses to a single (B, units*2) vector.
    x = layers.Bidirectional(
        layers.LSTM(LSTM_UNITS[0], return_sequences=True,
                    recurrent_dropout=0.1, kernel_regularizer=reg)
    )(x)
    x = layers.Dropout(0.3)(x)

    x = layers.Bidirectional(
        layers.LSTM(LSTM_UNITS[1], return_sequences=True,
                    recurrent_dropout=0.1, kernel_regularizer=reg)
    )(x)
    x = layers.Dropout(0.3)(x)

    x = layers.Bidirectional(
        layers.LSTM(LSTM_UNITS[2], return_sequences=False,
                    recurrent_dropout=0.1, kernel_regularizer=reg)
    )(x)
    x = layers.Dropout(0.4)(x)                               # (B, 64)

    # ── 4e. Classifier head ───────────────────────────────────────────────────
    out = layers.Dense(1, activation="sigmoid",
                       kernel_regularizer=reg)(x)             # (B, 1)

    model = keras.Model(inputs=inp, outputs=out)
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=3e-4),
        loss="binary_crossentropy",  # class_weight handles imbalance; focal loss kills gradients at init in deep nets
        metrics=[
            tf.keras.metrics.AUC(name="auc"),
            tf.keras.metrics.Recall(name="recall"),
            tf.keras.metrics.Precision(name="precision"),
        ],
    )
    return model


# ── Focal loss (same as CNN_BiLSTM.py) ───────────────────────────────────────

def focal_loss(gamma=2.0, alpha=0.75):
    def loss_fn(y_true, y_pred):
        y_true  = tf.cast(y_true, tf.float32)
        bce     = tf.keras.backend.binary_crossentropy(y_true, y_pred)
        p_t     = y_true * y_pred + (1 - y_true) * (1 - y_pred)
        alpha_t = y_true * alpha  + (1 - y_true) * (1 - alpha)
        return alpha_t * tf.pow(1.0 - p_t, gamma) * bce
    return loss_fn


# ── Data loading and helpers ──────────────────────────────────────────────────

def load_data():
    X_train      = np.load(PREPARED / "X_train.npy")
    y_train      = np.load(PREPARED / "y_train.npy")
    X_val        = np.load(PREPARED / "X_val.npy")
    y_val        = np.load(PREPARED / "y_val.npy")
    X_test       = np.load(PREPARED / "X_test.npy")
    y_test       = np.load(PREPARED / "y_test.npy")
    class_weight = np.load(PREPARED / "class_weights.npy")
    return X_train, y_train, X_val, y_val, X_test, y_test, class_weight


def stratified_subsample(X, y, n, seed=42):
    rng      = np.random.default_rng(seed)
    fog_idx  = np.where(y == 1)[0]
    nfog_idx = np.where(y == 0)[0]
    fog_rate = len(fog_idx) / len(y)
    n_fog    = int(n * fog_rate)
    n_nfog   = n - n_fog
    chosen   = np.concatenate([
        rng.choice(fog_idx,  min(n_fog,  len(fog_idx)),  replace=False),
        rng.choice(nfog_idx, min(n_nfog, len(nfog_idx)), replace=False),
    ])
    rng.shuffle(chosen)
    return X[chosen], y[chosen]


def make_callbacks():
    return [
        callbacks.EarlyStopping(monitor="val_auc", patience=15,
                                mode="max", restore_best_weights=True),
        callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5,
                                    patience=6, min_lr=1e-6),
        callbacks.ModelCheckpoint("best_model2.keras", monitor="val_auc",
                                  mode="max", save_best_only=True),
    ]


def plot_history(history):
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    fig.suptitle("Transformer + BiLSTM Training History", fontsize=13, fontweight="bold")
    for ax, (metric, label) in zip(axes, [("loss", "Loss"), ("auc", "AUC"), ("recall", "Recall")]):
        ax.plot(history.history[metric],          label="Train", color="#3498db")
        ax.plot(history.history[f"val_{metric}"], label="Val",   color="#e74c3c")
        ax.set_title(label)
        ax.set_xlabel("Epoch")
        ax.legend()
        ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("training_history2.png", dpi=150, bbox_inches="tight")
    print("Saved training_history2.png")


def evaluate_model(model, X_test, y_test):
    results = model.evaluate(X_test, y_test, verbose=0)
    for name, value in zip(["loss", "auc", "recall", "precision"], results):
        print(f"  {name}: {value:.4f}")


if __name__ == "__main__":
    X_train, y_train, X_val, y_val, X_test, y_test, class_weight = load_data()

    # Add jerk features to all splits
    X_train = add_jerk(X_train)
    X_val   = add_jerk(X_val)
    X_test  = add_jerk(X_test)

    print(f"Train: {X_train.shape}  Val: {X_val.shape}  Test: {X_test.shape}")
    print(f"Class weights (non-FoG={class_weight[0]:.3f}, FoG={class_weight[1]:.3f})")

    if MAX_TRAIN_WINDOWS and len(X_train) > MAX_TRAIN_WINDOWS:
        X_train, y_train = stratified_subsample(X_train, y_train, MAX_TRAIN_WINDOWS)
        print(f"Subsampled train to {X_train.shape[0]} windows  FoG={y_train.mean():.1%}")

    model = build_model()
    model.summary()

    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=make_callbacks(),
        class_weight={0: float(class_weight[0]), 1: float(class_weight[1])},
    )

    plot_history(history)
    print("\nHeld-out test results:")
    evaluate_model(model, X_test, y_test)
