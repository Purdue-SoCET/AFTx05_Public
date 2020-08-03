"""
Outdated code used when prototyping integer inferencing
"""


#!/usr/bin/env python

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import os
import h5py
import numpy as np
import uuid
import model_pb2
import warnings


"""
adated from:
https://github.com/transcranial/keras-js/blob/master/python/encoder.py
"""

IMG_DIM = 28


def quantize_arr(arr, min_val=None, max_val=None, dtype=np.uint8):
    """Quantization based on real_value = scale * (quantized_value - zero_point).
    """

    if (min_val is None) | (max_val is None):
        min_val, max_val = np.min(arr), np.max(arr)


    scale, zero_point = choose_quant_params(min_val, max_val, dtype=dtype)

    transformed_arr = zero_point + arr / scale
    # print(transformed_arr)
    if dtype == np.uint8:
        clamped_arr = np.clip(transformed_arr, 0, 255)
        quantized = clamped_arr.astype(np.uint8)
    elif dtype == np.uint32:
        clamped_arr = np.clip(transformed_arr, 0, 2 ** 31)
        quantized = clamped_arr.astype(np.uint32)
    else:
        raise ValueError('dtype={} is not supported'.format(dtype))

    # print(clamped_arr)
    min_val = min_val.astype(np.float32)
    max_val = max_val.astype(np.float32)

    return quantized, min_val, max_val


def dequantize_arr(arr, scale, zero_point):
    return scale * (arr - zero_point)


def choose_quant_params(min, max, dtype=np.uint8):
    # Function adapted for python from:
    # https://github.com/google/gemmlowp/blob/master/doc/quantization_example.cc
    # We extend the [min, max] interval to ensure that it contains 0.
    # Otherwise, we would not meet the requirement that 0 be an exactly
    # representable value.
    min = np.min([min, 0])
    max = np.max([max, 0])

    # the min and max quantized values, as floating-point values
    if dtype == np.uint8:
        qmin = 0.0
        qmax = 255.0
    elif dtype == np.uint32:
        qmin = 0.0
        qmax = 2 ** 31 * 1.0
    else:
        raise ValueError('dtype={} is not supported'.format(dtype))

    # First determine the scale.
    scale = (max - min) / (qmax - qmin)

    # Zero-point computation.
    # First the initial floating-point computation. The zero-point can be
    # determined from solving an affine equation for any known pair
    # (real value, corresponding quantized value).
    # We know two such pairs: (rmin, qmin) and (rmax, qmax).
    # Let's use the first one here.
    initial_zero_point = qmin - min / scale

    # Now we need to nudge the zero point to be an integer
    # (our zero points are integer, and this is motivated by the requirement
    # to be able to represent the real value "0" exactly as a quantized value,
    # which is required in multiple places, for example in Im2col with SAME
    # padding).

    if initial_zero_point < qmin:
        nudged_zero_point = dtype(qmin)
    elif initial_zero_point > qmax:
        nudged_zero_point = dtype(qmax)
    else:
        nudged_zero_point = dtype(round(initial_zero_point))

    return scale, nudged_zero_point


def quantize_mult_smaller_one(real_mul):
    s = 0
    while real_mul < 0.5:
        real_mul *= 2
        s += 1
    q = np.int64(round(real_mul * (1 << 31)))
    if q == (1 << 31):
        q /= 2
        s -= 1
    return s, np.int32(q)


def quantize_mult_greater_one(real_mul):
    s = 0
    while real_mul >= 1.0:
        real_mul /= 2
        s += 1
    q = np.int64(round(real_mul * (1 << 31)))
    if q == (1 << 31):
        q /= 2
        s += 1
    return s, np.int32(q)


class KerasQuantizer:
    """Encoder class.
    Takes as input a Keras model saved in hdf5 format that includes the model architecture with the weights.
    This is the resulting file from running the command:
    ```
    model.save('my_model.h5')
    ```
    See https://keras.io/getting-started/faq/#savingloading-whole-models-architecture-weights-optimizer-state
    """

    def __init__(self, hdf5_model_filepath, quant_params):
        if not hdf5_model_filepath:
            raise Exception('hdf5_model_filepath must be provided.')
        if not quant_params:
            raise Exception('quant_params must be provided.')
        self.hdf5_model_filepath = hdf5_model_filepath
        self.layers = {}
        """
        conv_layer_weights = layers[b'conv2d'][b'conv2d/kernel:0']
        conv_layer_biases = layers[b'conv2d'][b'conv2d/bias:0']
        dense_layer_weights = layers[b'dense'][b'dense/kernel:0']
        dense_layer_biases = layers[b'dense'][b'dense/bias:0']
        pred_layer_weights = layers[b'pred'][b'pred/kernel:0']
        pred_layer_biases = layers[b'pred'][b'pred/bias:0']
        """
        self.quant_params = quant_params
        self.create_model()
        self.quantize()

    def create_model(self):
        """Initializes a model from the protobuf definition.
        """
        self.model = model_pb2.Model()
        self.model.id = str(uuid.uuid4())
        self.model.name = 'MyModel'

    def quantize(self):
        """quantize method.
        Originally was serialize function from encoder.py
        Strategy for extracting the weights is adapted from the
        load_weights_from_hdf5_group method of the Container class:
        see https://github.com/keras-team/keras/blob/master/keras/engine/topology.py#L2505-L2585
        """

        hdf5_file = h5py.File(self.hdf5_model_filepath, mode='r')

        self.model.keras_version = hdf5_file.attrs['keras_version']
        self.model.backend = hdf5_file.attrs['backend']
        self.model.model_config = hdf5_file.attrs['model_config']

        f = hdf5_file['model_weights']
        for layer_name in f.attrs['layer_names']:
            g = f[layer_name]
            self.layers[layer_name] = {}
            for weight_name in g.attrs['weight_names']:
                weight_value = g[weight_name].value
                if b'/bias:0' in weight_name:
                    quant_type = np.uint32
                    quantized, min_val, max_val = quantize_arr(weight_value, dtype=quant_type)
                    self.layers[layer_name][weight_name] = quantized.astype(quant_type)
                else:
                    quant_type = np.uint8
                    quantized, min_val, max_val = quantize_arr(weight_value, dtype=quant_type)
                    self.layers[layer_name][weight_name] = quantized.astype(quant_type)

        hdf5_file.close()

    def do_final_pred(self, layer_input, act_params):
        layer_input = layer_input[0]
        pred_layer_weights = self.layers[b'pred'][b'pred/kernel:0']
        pred_layer_biases = self.layers[b'pred'][b'pred/bias:0']
        input_scale = act_params[2][0]
        input_offset = act_params[2][1]
        output_scale = act_params[3][0]
        output_offset = act_params[3][1]
        weight_min = self.quant_params[2][0][0]
        weight_max = self.quant_params[2][0][1]
        weight_scale, weight_offset = choose_quant_params(weight_min, weight_max)
        bias_min = self.quant_params[5][0]
        bias_max = self.quant_params[5][1]
        bias_scale, bias_offset = choose_quant_params(bias_min, bias_max)
        M = (input_scale * weight_scale) / output_scale
        right_shift, M_0 = quantize_mult_smaller_one(M)

        # int only attempt
        # output_arr = np.zeros(shape=(10,), dtype=np.uint8)
        # for i in range(10):
        #     acc = np.int32(0)
        #     for j in range(256):
        #         input_val = np.int32(layer_input[j])
        #         weight_val = np.int32(pred_layer_weights[j][i])
        #         acc += (input_val - input_offset) * (weight_val - weight_offset)
        #     acc += pred_layer_biases[i]
        #     acc = (M_0 >> right_shift) * acc
        #     acc += output_offset
        #     acc = np.max([acc, 0])
        #     acc = np.min([acc, 255])
        #     output_arr[i] = np.uint8(acc)

        # using floats
        output_arr = np.zeros(shape=(10,), dtype=np.float32)
        for i in range(10):
            for j in range(256):
                r1_aprox = input_scale * (layer_input[j] - input_offset)
                r2_aprox = weight_scale * (pred_layer_weights[j][i] - weight_offset)
                output_arr[i] += r1_aprox * r2_aprox
            output_arr[i] += bias_scale * (pred_layer_biases[i] - bias_offset)

        return output_arr
