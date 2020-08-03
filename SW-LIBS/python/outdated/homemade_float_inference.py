"""
Outdated code used when prototyping integer inferencing
"""

import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.utils import to_categorical
from tensorflow.keras import backend as K
import argparse
import h5py
import model_pb2
import uuid
from encoder import choose_quant_params
import random

IMG_SHAPE = (28, 28)


def load_mnist():
    """
    Loads MNIST data
    """
    (x_train, y_train), (x_test, y_test) = mnist.load_data()

    x_train = x_train.reshape(x_train.shape[0], x_train.shape[1], x_train.shape[2], 1)
    x_test = x_test.reshape(x_test.shape[0], x_test.shape[1], x_test.shape[2], 1)
    y_train = to_categorical(y_train, num_classes=10)  # one hot
    y_test = to_categorical(y_test, num_classes=10)  # one hot

    return x_train, x_test, y_train, y_test


def load_model_from_file(hdf5_model_filepath, display_summary=True):
    """
    Load model from file
    """
    hdf5_file = h5py.File(hdf5_model_filepath, mode='r')
    model = model_pb2.Model()
    model.id = str(uuid.uuid4())
    model.name = 'MyModel'
    model.keras_version = hdf5_file.attrs['keras_version']
    model.backend = hdf5_file.attrs['backend']
    model.model_config = hdf5_file.attrs['model_config']
    f = hdf5_file['model_weights']
    layers = {}
    for layer_name in f.attrs['layer_names']:
        g = f[layer_name]
        layers[layer_name] = {}
        for weight_name in g.attrs['weight_names']:
            weight_value = g[weight_name].value
            layers[layer_name][weight_name] = weight_value
    hdf5_file.close()

    conv_layer_weights = layers[b'conv2d'][b'conv2d/kernel:0']
    conv_layer_biases = layers[b'conv2d'][b'conv2d/bias:0']
    dense_layer_weights = layers[b'dense'][b'dense/kernel:0']
    dense_layer_biases = layers[b'dense'][b'dense/bias:0']
    pred_layer_weights = layers[b'pred'][b'pred/kernel:0']
    pred_layer_biases = layers[b'pred'][b'pred/bias:0']

    if (display_summary):
        print("Model Summary:")
        print("=========================")
        print(f"Conv Layer: \nweight shape: {conv_layer_weights.shape}\nbias shape: {conv_layer_biases.shape} ")
        print(f"Dense Layer: \nweight shape: {dense_layer_weights.shape}\nbias shape: {dense_layer_biases.shape} ")
        print(f"Pred Layer: \nweight shape: {pred_layer_weights.shape}\nbias shape: {pred_layer_biases.shape} ")
    return layers


def activation_func(x):
    return np.max([0, x])


def evaluate_conv_layer(input, weights, biases):
    input = np.reshape(input, IMG_SHAPE)
    filters = weights.shape[3]
    output_shape = (filters, IMG_SHAPE[0], IMG_SHAPE[1])
    output = np.zeros(shape=output_shape)
    for i in range(filters):
        for j in range(0, IMG_SHAPE[0] - 2):
            for k in range(0, IMG_SHAPE[1] - 2):
                kernel_img = input[j:j + 3, k:k + 3]
                kernel_weight = weights[:, :, 0, i]
                result = np.sum(np.dot(kernel_img, kernel_weight)) + biases[i]

                output[i][j + 1][k + 1] = activation_func(result)
    return output


def evaluate_dense_layer(input, weights, biases, num_channels):
    output = np.zeros(shape=(num_channels,))
    for i in range(num_channels):
        output[i] = activation_func(np.sum(input * weights[:, i]) + biases[i])
    return output


def evaluate_pred_layer(input, weights, biases, num_channels):
    output = np.zeros(shape=(num_channels,))
    for i in range(num_channels):
        output[i] = np.sum(input * weights[:, i]) + biases[i]
    # Softmax prediction
    output_exp = np.exp(output)
    total = np.sum(output_exp)
    for i in range(num_channels):
        output[i] = output_exp[i] / total
    return output


def get_scale_zero_points(arr):
    min, max = np.min(arr), np.max(arr)
    scale, zero_points = choose_quant_params(min, max)
    return scale, zero_points


def infer(img, model):
    conv_layer_weights = model[b'conv2d'][b'conv2d/kernel:0']
    conv_layer_biases = model[b'conv2d'][b'conv2d/bias:0']
    dense_layer_weights = model[b'dense'][b'dense/kernel:0']
    dense_layer_biases = model[b'dense'][b'dense/bias:0']
    pred_layer_weights = model[b'pred'][b'pred/kernel:0']
    pred_layer_biases = model[b'pred'][b'pred/bias:0']

    output_hl_1 = evaluate_conv_layer(img, conv_layer_weights, conv_layer_biases)
    flat_output_hl_1 = output_hl_1.flatten()
    output_hl_2 = evaluate_dense_layer(flat_output_hl_1, dense_layer_weights, dense_layer_biases, 256)
    pred_output = evaluate_pred_layer(output_hl_2, pred_layer_weights, pred_layer_biases, 10)

    quant_map = {}
    quant_map['conv2d'] = get_scale_zero_points(output_hl_1)
    quant_map['dense']  = get_scale_zero_points(output_hl_2)
    quant_map['pred']   = get_scale_zero_points(pred_output)
    return pred_output.argmax(), quant_map


def test_model(imgs, labels, indexs):
    total = 0
    correct = 0
    quants = []
    for i in range(500):
        print(f"{correct} / {total}")
        guess, quant_entry = infer(imgs[indexs[i]], model)
        quants.append(quant_entry)
        answer = labels[indexs[i]].argmax()
        if guess == answer:
            correct += 1
        total += 1
    print(correct / total)
    return quants


if __name__ == '__main__':
    model = load_model_from_file('lastest.h5')

    x_train, x_test, y_train, y_test = load_mnist()

    indexs = random.sample(range(0, 10000), 500)
    # # shuffle the training dataset (5 times!)
    # for _ in range(5):
    #     indexes = np.random.permutation(len(x_test))
    #
    # x_test = x_test[indexes]
    # y_test = y_test[indexes]

    quants = test_model(x_test, y_test, indexs)

    avg_quant = {}
    avg_quant['conv2d'] = (0, 0)
    avg_quant['dense'] = (0, 0)
    avg_quant['pred'] = (0, 0)

    for entry in quants:
        avg_quant['conv2d'] = (avg_quant['conv2d'][0] + entry['conv2d'][0], avg_quant['conv2d'][1] + entry['conv2d'][1])
        avg_quant['dense'] = (avg_quant['dense'][0] + entry['dense'][0], avg_quant['dense'][1] + entry['dense'][1])
        avg_quant['pred'] = (avg_quant['pred'][0] + entry['pred'][0], avg_quant['pred'][1] + entry['pred'][1])

    avg_quant['conv2d'] = (avg_quant['conv2d'][0] / 500, avg_quant['conv2d'][1] / 500)
    avg_quant['dense'] = (avg_quant['dense'][0] / 500, avg_quant['dense'][1] / 500)
    avg_quant['pred'] = (avg_quant['pred'][0] / 500, avg_quant['pred'][1] / 500)

    print("Conv2D (Scale, Zero-Point)")
    print(avg_quant['conv2d'])

    print("Dense (Scale, Zero-Point)")
    print(avg_quant['dense'])

    print("Pred (Scale, Zero-Point)")
    print(avg_quant['pred'])