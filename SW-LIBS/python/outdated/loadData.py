from keras.datasets.mnist import load_data
import numpy as np
from keras.models import Sequential, load_model, Model
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Activation
from keras.utils import to_categorical
from keras.constraints import MinMaxNorm
from pprint import pprint as pp
import keras.backend as K
from keras.utils.generic_utils import get_custom_objects
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from keras.engine.topology import Layer

NUM_CLASSES = 10
(TRAIN_DIGITS, TRAIN_LABELS), (TEST_DIGITS, TEST_LABELS) = load_data()
IMAGE_HEIGHT = TRAIN_DIGITS.shape[1]
IMAGE_WIDTH = TRAIN_DIGITS.shape[2]
NUM_CHANNELS = 1  # we have grayscale images

def saveTestImg(imgNum):
    currFlat = np.hstack(TEST_DIGITS[imgNum])
    currLbl = TEST_LABELS[imgNum]
    saveArray = np.append(currFlat, currLbl)
    np.savetxt("fImg.txt", saveArray, fmt="%03u", delimiter=' ')

def saveModelWandB(modelName, layerCount):
    model = load_model(modelName)
    for layer in range(layerCount):
        print(layer)
        try:
            weights = model.layers[layer].get_weights()[0]
            print("weights")
            print(np.shape(weights))
        except:
            weights = None
        try:
            biases = model.layers[layer].get_weights()[1]
            print("biases")
            print(np.shape(biases))
        except:
            biases = None
        print()
    pass


if __name__ == '__main__':
    saveTestImg(0);
    #saveModelWandB('8_relu.h5', 9)
    pass