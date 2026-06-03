import numpy as np
import pandas as pd
from pathlib import Path
from sklearn.preprocessing import StandardScaler

# ── Config ────────────────────────────────────────────────────────────────────
DATA_PATH   = Path("data/FoGSTAR-sensor_data.csv")
OUT_DIR     = Path("data/prepared")
WINDOW_SIZE = 120   # 2 seconds at 60 Hz
STEP_SIZE   = 60    # 50% overlap
SENSOR_COLS = [
    "ankleL_acc_x", "ankleL_acc_y", "ankleL_acc_z",
    "ankleL_gyro_x", "ankleL_gyro_y", "ankleL_gyro_z",
    "ankleR_acc_x",  "ankleR_acc_y",  "ankleR_acc_z",
    "ankleR_gyro_x", "ankleR_gyro_y", "ankleR_gyro_z",
    "back_acc_x",    "back_acc_y",    "back_acc_z",
    "back_gyro_x",   "back_gyro_y",   "back_gyro_z",
    "wrist_acc_x",   "wrist_acc_y",   "wrist_acc_z",
    "wrist_gyro_x",  "wrist_gyro_y",  "wrist_gyro_z",
]
# ─────────────────────────────────────────────────────────────────────────────


def load_and_impute(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)

    # Interpolate within each (subject, session) group to preserve continuity.
    # Values at the very start/end of a session that can't be interpolated are
    # forward- then backward-filled; any remaining NaNs (whole-channel dropout
    # sessions) are filled with 0.
    df[SENSOR_COLS] = (
        df.groupby(["subjectID", "sessionID"])[SENSOR_COLS]
        .transform(lambda s: s.interpolate(method="linear", limit_direction="both").ffill().bfill().fillna(0.0))
    )
    return df


def normalize_per_subject(df: pd.DataFrame) -> pd.DataFrame:
    # Fit a scaler on each subject's data and transform in place.
    # This prevents data leakage across subjects and accounts for
    # sensor placement differences between participants.
    def _scale_group(block):
        return pd.DataFrame(
            StandardScaler().fit_transform(block),
            index=block.index,
            columns=block.columns,
        )

    df[SENSOR_COLS] = (
        df.groupby("subjectID")[SENSOR_COLS]
        .apply(_scale_group)
        .droplevel(0)
        .sort_index()
    )
    return df


def make_windows(
    df: pd.DataFrame,
    window_size: int,
    step_size: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    X_list, y_list, groups_list = [], [], []

    for (subject, session), group in df.groupby(["subjectID", "sessionID"]):
        group = group.reset_index(drop=True)
        values = group[SENSOR_COLS].values       # (T, F)
        labels = group["fog"].values              # (T,)

        n_windows = (len(group) - window_size) // step_size + 1
        if n_windows <= 0:
            continue

        for i in range(n_windows):
            start = i * step_size
            end   = start + window_size
            window = values[start:end]            # (window_size, n_features)
            # Majority-vote label for the window
            label  = int(labels[start:end].mean() >= 0.5)
            X_list.append(window)
            y_list.append(label)
            groups_list.append(subject)

    X      = np.stack(X_list).astype(np.float32)   # (N, W, F)
    y      = np.array(y_list,      dtype=np.int64)  # (N,)
    groups = np.array(groups_list, dtype=np.int64)  # (N,)  — subject per window
    return X, y, groups


def split_by_subject(
    X: np.ndarray,
    y: np.ndarray,
    groups: np.ndarray,
    val_subjects:  list[int],
    test_subjects: list[int],
) -> dict[str, np.ndarray]:
    val_mask  = np.isin(groups, val_subjects)
    test_mask = np.isin(groups, test_subjects)
    train_mask = ~val_mask & ~test_mask

    return {
        "X_train": X[train_mask], "y_train": y[train_mask],
        "X_val":   X[val_mask],   "y_val":   y[val_mask],
        "X_test":  X[test_mask],  "y_test":  y[test_mask],
    }


def compute_class_weight(y_train: np.ndarray) -> np.ndarray:
    # Returns [weight_class0, weight_class1] balanced by inverse frequency.
    counts = np.bincount(y_train)
    total  = len(y_train)
    n_classes = len(counts)
    weights = total / (n_classes * counts)
    return weights.astype(np.float32)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Loading data...")
    df = load_and_impute(DATA_PATH)
    print(f"  {len(df):,} rows, {df[SENSOR_COLS].isnull().sum().sum()} NaNs remaining")

    print("Normalizing per subject...")
    df = normalize_per_subject(df)

    print(f"Creating windows (size={WINDOW_SIZE}, step={STEP_SIZE})...")
    X, y, groups = make_windows(df, WINDOW_SIZE, STEP_SIZE)
    print(f"  Windows: {X.shape}  |  FoG rate: {y.mean():.1%}")

    # Use the last 2 subjects as test, next 2 as validation.
    # Subjects are 1-22; hold out 21-22 for test, 19-20 for val.
    val_subjects  = [19, 20]
    test_subjects = [21, 22]
    splits = split_by_subject(X, y, groups, val_subjects, test_subjects)

    class_weights = compute_class_weight(splits["y_train"])

    print("\nSplit summary:")
    for split in ("train", "val", "test"):
        xk, yk = f"X_{split}", f"y_{split}"
        fog_rate = splits[yk].mean()
        print(f"  {split:5s}: {splits[xk].shape}  FoG={fog_rate:.1%}")

    print(f"\nClass weights (non-FoG / FoG): {class_weights}")

    print(f"\nSaving to {OUT_DIR}/...")
    np.save(OUT_DIR / "X_train.npy",        splits["X_train"])
    np.save(OUT_DIR / "y_train.npy",        splits["y_train"])
    np.save(OUT_DIR / "X_val.npy",          splits["X_val"])
    np.save(OUT_DIR / "y_val.npy",          splits["y_val"])
    np.save(OUT_DIR / "X_test.npy",         splits["X_test"])
    np.save(OUT_DIR / "y_test.npy",         splits["y_test"])
    np.save(OUT_DIR / "class_weights.npy",  class_weights)
    np.save(OUT_DIR / "groups_train.npy",   groups[~np.isin(groups, val_subjects + test_subjects)])

    print("Done.")


if __name__ == "__main__":
    main()
