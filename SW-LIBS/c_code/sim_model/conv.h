#ifndef CONV_H
#define CONV_H
#include <stdint.h>

const uint8_t quantized_weight_conv[1][1][3][1] = { 
255, 
 93, 
  0
};

const int32_t quantized_bias_conv[1] = { 6735 };

const uint8_t weight_offset_conv = 26;

const uint8_t input_offset_conv = 0;

const uint8_t output_offset_conv = 0;

const int right_shift_conv = 11;

const int32_t M_0_conv = 30859;

#endif
