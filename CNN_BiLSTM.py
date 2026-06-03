import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras import models, layers, callbacks
import numpy as np
from pathlib import Path

X_train_path = Path("data") / "prepared" / "X_train.npy"
Y_train_path = Path("data") / "prepared" / "y_train.npy"

X_train = np.load(X_train_path)
y_train = np.load(Y_train_path)

model = keras.Sequential()

