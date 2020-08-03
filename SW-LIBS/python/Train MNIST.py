"""
Used to analyze sparsity in model
"""

from tensorflow.keras.datasets.mnist import load_data
import numpy as np
from tensorflow.keras.models import Sequential, load_model, Model
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Activation
from tensorflow.keras.utils import to_categorical
from pprint import pprint as pp
import matplotlib.pyplot as plt



NUM_CLASSES = 10
(TRAIN_DIGITS, TRAIN_LABELS), (TEST_DIGITS, TEST_LABELS) = load_data()
IMAGE_HEIGHT = TRAIN_DIGITS.shape[1]
IMAGE_WIDTH = TRAIN_DIGITS.shape[2]
NUM_CHANNELS = 1  # we have grayscale images


def build_model(scale):
    min_constraint = 0
    max_constraint = 1
    activation_function = 'hard_sigmoid'
    model = Sequential()
    # add Convolutional layers
    # kernel_constraint=MinMaxNorm(min_value=min_constraint, max_value=max_constraint, rate=1.0)
    # bias_constraint=MinMaxNorm(min_value=min_constraint, max_value=max_constraint, rate=1.0)
    model.add(Conv2D(filters=scale, kernel_size=(3,3), activation=activation_function, padding='same',
                     input_shape=(IMAGE_HEIGHT, IMAGE_WIDTH, NUM_CHANNELS)))
    model.add(MaxPooling2D(pool_size=(2,2)))
    model.add(Conv2D(filters=scale*2, kernel_size=(3,3), activation=activation_function, padding='same'))
    model.add(MaxPooling2D(pool_size=(2,2)))
    model.add(Conv2D(filters=scale*2, kernel_size=(3,3), activation=activation_function, padding='same'))
    model.add(MaxPooling2D(pool_size=(2,2)))
    model.add(Flatten())
    # Densely connected layers
    model.add(Dense(scale*4, activation=activation_function))
    # output layer
    model.add(Dense(NUM_CLASSES, activation='softmax'))
    # compile with adam optimizer & categorical_crossentropy loss function
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return model


def train_model(scale, epochs, filename):
    # re-shape the images data
    train_data = np.reshape(TRAIN_DIGITS, (TRAIN_DIGITS.shape[0], IMAGE_HEIGHT, IMAGE_WIDTH, NUM_CHANNELS))
    test_data = np.reshape(TEST_DIGITS, (TEST_DIGITS.shape[0], IMAGE_HEIGHT, IMAGE_WIDTH, NUM_CHANNELS))

    # re-scale the image data to values between (0.0,1.0]
    train_data = train_data.astype('float32') / 255.
    test_data = test_data.astype('float32') / 255.

    # one-hot encode the labels - we have 10 output classes
    # so 3 -> [0 0 0 1 0 0 0 0 0 0], 5 -> [0 0 0 0 0 1 0 0 0 0] & so on
    
    train_labels_cat = to_categorical(TRAIN_LABELS, NUM_CLASSES)
    test_labels_cat = to_categorical(TEST_LABELS, NUM_CLASSES)

    # shuffle the training dataset (5 times!)
    for _ in range(5):
        indexes = np.random.permutation(len(train_data))

    train_data = train_data[indexes]
    train_labels_cat = train_labels_cat[indexes]

    # now set-aside 10% of the train_data/labels as the
    # cross-validation sets
    val_perc = 0.10
    val_count = int(val_perc * len(train_data))

    # first pick validation set from train_data/labels
    val_data = train_data[:val_count, :]
    val_labels_cat = train_labels_cat[:val_count, :]

    # leave rest in training set
    train_data2 = train_data[val_count:, :]
    train_labels_cat2 = train_labels_cat[val_count:, :]

    # NOTE: We will train on train_data2/train_labels_cat2 and
    # cross-validate on val_data/val_labels_cat
    model = build_model(scale)
    print(model.summary())

    results = model.fit(train_data2, train_labels_cat2,
                        epochs=epochs, batch_size=64,
                        validation_data=(val_data, val_labels_cat))

    test_loss, test_accuracy = \
      model.evaluate(test_data, test_labels_cat, batch_size=64)
    print('Test loss: %.4f accuracy: %.4f' % (test_loss, test_accuracy))
    model.save(filename)
    return model, test_accuracy

def get_hidden_layer(model, layer, data):
    intermediate_layer_model = Model(inputs=model.input,
                                     outputs=model.layers[layer].output)
    intermediate_output = intermediate_layer_model.predict(data)
    return intermediate_output

if __name__ == '__main__':
    #model, test_accuracy = train_model(8 , 20, 'latest.h5')  # Comment out either line 96 or 97
    model = load_model('lastest.h5')                          # To retrain model comment 97 to load a model comment 96
    print(model.summary())
    intermediate_layer_outputs = []
    data = TEST_DIGITS[0:1]
    data = data[..., np.newaxis]

    for index, layer in enumerate(model.layers):
        output = 'working on intermediate layer: ' + str(index)
        # print(output)
        intermediate_output = get_hidden_layer(model, index, data)
        #pp(intermediate_output.shape)
        #pp(intermediate_output)
        intermediate_output = intermediate_output.flatten()
        #intermediate_output = ((intermediate_output + 1) * 255) / 2
        #intermediate_output = intermediate_output.round()
        #intermediate_output = intermediate_output.astype('uint8')
        intermediate_layer_outputs.append(intermediate_output)

    flat_intermediate_layer_outputs = []
    for layer in intermediate_layer_outputs:
        flat_intermediate_layer_outputs = np.hstack([flat_intermediate_layer_outputs, layer])

    layers = []
    for layer in model.layers:
        w8s = []
        biases = []
        weights = layer.get_weights()  # list of numpy arrays
        if weights is not None:
            if len(weights) >= 1:
                w8s = weights[0]
                #w8s = ((weights[0] + 1) * 255) / 2
                #w8s = w8s.round()
                #w8s = w8s.astype('uint8')
            if len(weights) >= 2:
                biases = weights[1]
                #biases = ((weights[1] + 1) * 255) / 2
                #biases = biases.round()
                #biases = biases.astype('uint8')
            new_layer = [w8s, biases]
            layers.append(new_layer)

    new_layers = []
    for layer in layers:
        if len(layer[0]) > 0:
            weights = layer[0]
            biases = layer[1]
            weights = weights.flatten()
            biases = biases.flatten()
            new_layers = np.hstack([new_layers, weights, biases])

    #new_layers = np.hstack([flat_intermediate_layer_outputs, new_layers])
    num_bins = 10
    plt.hist(flat_intermediate_layer_outputs, num_bins, facecolor='blue', alpha=0.5, edgecolor='black', linewidth=1)
    plt.title('Distribution of Weights/Biases of CNN')
    plt.xlabel('Bins')
    plt.ylabel('Number of Weights/Biases per Bin')
    plt.show()

