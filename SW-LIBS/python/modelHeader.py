from tensorflow import keras
import tensorflow as tf
import offline
import re
import numpy as np
from PIL import Image

################################ TEST IMAGE

IMG_SIZE = (10, 10)

mnist = keras.datasets.mnist
(train_images, TRAIN_LABELS), (test_images, TEST_LABELS) = mnist.load_data()

TRAIN_DIGITS = []
TEST_DIGITS = []

for img in train_images:
    res = np.array(Image.fromarray(img).resize(size=IMG_SIZE))
    TRAIN_DIGITS.append(res)
TRAIN_DIGITS = np.asarray(TRAIN_DIGITS)

for img in test_images:
    res = np.array(Image.fromarray(img).resize(size=IMG_SIZE))
    TEST_DIGITS.append(res)
TEST_DIGITS = np.asarray(TEST_DIGITS)

TRAIN_DIGITS = TRAIN_DIGITS / 255.0
TEST_DIGITS = TEST_DIGITS / 255.0
IMAGE_HEIGHT = TRAIN_DIGITS.shape[1]
IMAGE_WIDTH = TRAIN_DIGITS.shape[2]
NUM_CHANNELS = 1

################################ HEADER VARS
# load TFLite file
interpreter = tf.lite.Interpreter(model_path=f'model.tflite')
# Allocate memory.
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
inter_layer = interpreter.get_tensor_details()

weight_index = 4
bias_index = 6
output_index = 1
input_index = 2
quantized_weight_conv = interpreter.get_tensor(inter_layer[weight_index]['index'])
quantized_bias_conv = interpreter.get_tensor(inter_layer[bias_index]['index'])
# offsets only
weight_scale_conv, weight_offset_conv = inter_layer[weight_index]['quantization']
input_scale_conv, input_offset_conv = inter_layer[input_index]['quantization']
output_scale_conv, output_offset_conv = inter_layer[output_index]['quantization']
#right_shift and M_0
M_conv = (input_scale_conv * weight_scale_conv) / output_scale_conv
right_shift_conv, M_0_conv = offline.quantize_mult_smaller_one(M_conv)
right_shift_conv, M_0_conv = offline.change_32_M_0_to_16_M_0(M_0_conv, right_shift_conv)

# hidden dense layer offline parameters
weight_index = 11
bias_index = 9
output_index = 8
input_index = 0
quantized_weight_dense = interpreter.get_tensor(inter_layer[weight_index]['index'])
quantized_bias_dense = interpreter.get_tensor(inter_layer[bias_index]['index'])
# offsets only
weight_scale_dense, weight_offset_dense = inter_layer[weight_index]['quantization']
input_scale_dense, input_offset_dense = inter_layer[input_index]['quantization']
output_scale_dense, output_offset_dense = inter_layer[output_index]['quantization']
#right_shift and M_0_
M_dense = (input_scale_dense * weight_scale_dense) / output_scale_dense
right_shift_dense, M_0_dense = offline.quantize_mult_smaller_one(M_dense)
right_shift_dense, M_0_dense = offline.change_32_M_0_to_16_M_0(M_0_dense, right_shift_dense)


def createHfile(filepath):
    filename = re.search(r"(\w+)\.h", filepath).group(1)
    writeFile = open(filepath, "w+")
    writeFile.write("#ifndef %s_H\n" % filename.upper())
    writeFile.write("#define %s_H\n" % filename.upper())
    writeFile.write("#include <stdint.h>\n\n")
    return writeFile


def closeHfile(hfile):
    hfile.write("#endif")
    hfile.close()


def imgtoH(hfile, imgIndex):
    img = offline.quantize(input_details[0], TEST_DIGITS[imgIndex:imgIndex + 1])
    lbl = TEST_LABELS[imgIndex]
    nRow = len(img)
    nCol = len(img[0])
    hfile.write("const %s %s[1][%d][1] = { \n" % ("uint8_t", "img", nRow * nCol))
    for row in range(nRow):
        for col in range(nCol):
            if col == nCol - 1 and row == nRow - 1:
                hfile.write("%3u" % img[row][col])
            else:
                hfile.write("%3u, " % img[row][col])
        hfile.write("\n")
    hfile.write("};\n\n")
    vartoH(hfile, "uint8_t", "lbl", lbl)


def arr2DtoH(hfile, c_dtypestr, arrname, arr):
    nRow = len(arr)
    nCol = len(arr[0])
    hfile.write("const %s %s[%d][%d] = { \n" % (c_dtypestr, arrname, nRow, nCol))
    for row in range(nRow):
        for col in range(nCol):
            if col == nCol - 1 and row == nRow - 1:
                hfile.write("%3u" % arr[row][col])
            else:
                hfile.write("%3u, " % arr[row][col])
        hfile.write("\n")
    hfile.write("};\n\n")


def arr1DtoH(hfile, c_dtypestr, arrname, arr):
    nCol = len(arr)
    hfile.write("const %s %s[%d] = { " % (c_dtypestr, arrname, nCol))
    for col in range(nCol):
        if col == nCol - 1:
            hfile.write("%d" % arr[col])
        else:
            hfile.write("%d, " % arr[col])
    hfile.write(" };\n\n")


def vartoH(hfile, c_dtypestr, varname, value):
    hfile.write("const %s %s = %d;\n\n" % (c_dtypestr, varname, value))


if __name__ == '__main__':
    imgpath = "modelH/img.h"
    imgFile = createHfile(imgpath)
    imgtoH(imgFile, 0) ####################################### CHANGE THE IMG INDEX HERE
    closeHfile(imgFile)

    convpath = "modelH/conv.h"
    densepath = "modelH/dense.h"
    convFile = createHfile(convpath)
    denseFile = createHfile(densepath)

    arr2DtoH(convFile, "uint8_t", "quantized_weight_conv[1][1]", quantized_weight_conv[0][0])
    arr1DtoH(convFile, "int32_t", "quantized_bias_conv", quantized_bias_conv)
    vartoH(convFile, "uint8_t", "weight_offset_conv", weight_offset_conv)
    vartoH(convFile, "uint8_t", "input_offset_conv", input_offset_conv)
    vartoH(convFile, "uint8_t", "output_offset_conv", output_offset_conv)
    vartoH(convFile, "int", "right_shift_conv", right_shift_conv)
    vartoH(convFile, "int32_t", "M_0_conv", M_0_conv)
    closeHfile(convFile)

    arr2DtoH(denseFile, "uint8_t", "quantized_weight_dense", quantized_weight_dense)
    arr1DtoH(denseFile, "int32_t", "quantized_bias_dense", quantized_bias_dense)
    vartoH(denseFile, "uint8_t", "weight_offset_dense", weight_offset_dense)
    vartoH(denseFile, "uint8_t", "input_offset_dense", input_offset_dense)
    vartoH(denseFile, "uint8_t", "output_offset_dense", output_offset_dense)
    vartoH(denseFile, "int", "right_shift_dense", right_shift_dense)
    vartoH(denseFile, "int32_t", "M_0_dense", M_0_dense)
    closeHfile(denseFile)