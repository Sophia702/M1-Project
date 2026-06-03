import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras import models, layers, callbacks
import numpy as np
from pathlib import Path

# --- Config :) ----------------------------------
PREPARED = Path("data/prepared")
WINDOW_SIZE =  120
EPOCH = 50
BATCH_SIZE = 32
N_FEATURES = 24
# ------------------------------------------------


def load_data():
    # Loading in data prepared by prepare_data.py :D
    X_train = np.load(PREPARED / "X_train.npy")
    y_train = np.load(PREPARED / "y_train.npy")
    x_val = np.load(PREPARED / "X_val.npy")
    y_val = np.load(PREPARED / "y_val.npy")
    X_test = np.load(PREPARED / "X_test.npy")
    y_test = np.load(PREPARED / "y_test.npy")
    class_weight = np.load(PREPARED / "class_weights.npy")
    return X_train, y_train, x_val, y_val, X_test, y_test, class_weight


def focal_loss(gamma=2.0, alpha=0.75):
    # Down-weights easy negatives so the model focuses on hard FoG examples.
    # alpha=0.75 gives extra weight to the minority FoG class.
    def loss_fn(y_true, y_pred):
        y_true = tf.cast(y_true, tf.float32)
        bce = tf.keras.backend.binary_crossentropy(y_true, y_pred)
        p_t = y_true * y_pred + (1 - y_true) * (1 - y_pred)
        alpha_t = y_true * alpha + (1 - y_true) * (1 - alpha)
        return alpha_t * tf.pow(1.0 - p_t, gamma) * bce
    return loss_fn


def build_model(window_size=WINDOW_SIZE, n_features=N_FEATURES):
    inp = layers.Input(shape=(window_size, n_features))

    # Small Gaussian noise makes CNN features less subject-specific
    x = layers.GaussianNoise(0.05)(inp)

    # CNN block (extracting temporal features)
    x = layers.Conv1D(64, kernel_size=5, padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv1D(64, kernel_size=5, padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPool1D(pool_size=4)(x)
    x = layers.Dropout(0.4)(x)

    # BiLSTM block - model temporal dependencies
    # recurrent_dropout regularizes the hidden state connections inside the LSTM
    x = layers.Bidirectional(layers.LSTM(32, return_sequences=False, recurrent_dropout=0.3))(x)
    x = layers.Dropout(0.5)(x)

    # Classifier head
    out = layers.Dense(1, activation="sigmoid")(x)
    model = keras.Model(inputs=inp, outputs=out)
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=3e-4),
        loss=focal_loss(gamma=2.0, alpha=0.75),
        metrics=["accuracy", tf.keras.metrics.AUC(name="auc"), tf.keras.metrics.Recall(name="recall"), tf.keras.metrics.Precision(name="precision")]
    )
    return model

def train(model, X_train, y_train, X_val, y_val, X_test, y_test, class_weight):
    cw_dict = {0: float(class_weight[0]), 1: float(class_weight[1])}

    cb = [
        callbacks.EarlyStopping(monitor="val_auc", patience=10, mode="max", restore_best_weights=True),
        callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=5, min_lr=1e-6),
        callbacks.ModelCheckpoint("best_model.keras", monitor="val_auc", mode="max", save_best_only=True),
    ]

    history = model.fit(X_train, y_train, validation_data=(X_val,y_val),
                        epochs=EPOCH,
                        batch_size=BATCH_SIZE,
                        class_weight=cw_dict,
                        callbacks=cb)
    return history




def evaluate_model(model, X_test, y_test):
    results = model.evaluate(X_test, y_test, verbose=0)
    names = model.metrics_names
    for name, value in zip(names, results):
        print(f"{name}: {value:.4f}")



if __name__ == "__main__":
    X_train, y_train, X_val, y_val, X_test, y_test, class_weight = load_data()
    model = build_model()
    model.summary()
    history = train(model, X_train, y_train, X_val, y_val, X_test, y_test, class_weight)
    evaluate_model(model, X_test, y_test)
