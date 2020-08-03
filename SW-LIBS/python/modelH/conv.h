#ifndef CONV_H
#define CONV_H
#include <stdint.h>

const uint8_t quantized_weight_conv[1][1][3][8] = { 
206, 107, 228, 216, 221, 200, 217, 240, 
205, 255, 214, 147, 218, 204, 223, 225, 
203, 218, 215,   0, 225, 206, 223,  47
};

const int32_t quantized_bias_conv[8] = { 0, -3, -562, 4239, 1, 0, -1436, 355 };

const uint8_t weight_offset_conv = 210;

const uint8_t input_offset_conv = 0;

const uint8_t output_offset_conv = 0;

const int right_shift_conv = 9;

const int32_t M_0_conv = 31887;

#endif