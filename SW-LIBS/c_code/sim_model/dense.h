#ifndef DENSE_H
#define DENSE_H
#include <stdint.h>

const uint8_t quantized_weight_dense[10][100] = { 
131, 158, 126, 144, 143, 156, 150, 140, 143, 139, 137, 141, 140, 123, 160, 161, 171, 149, 155, 159, 148, 136, 140, 141, 141, 167, 189, 189, 181, 157,  96, 134, 129, 131, 168, 168, 171, 210, 163, 197,  97, 100, 157, 151, 188, 161,   7, 190, 167, 217, 136,  95, 165, 162, 200, 109,  19, 192, 150, 208, 117, 118, 172, 187, 190, 119, 135, 184, 166, 186, 127, 156, 151, 180, 187, 204, 159, 156, 177, 169, 164, 124, 130, 160, 166, 213, 178, 139, 119, 144, 154, 157, 141, 124,  74,  88, 101, 124, 133, 141, 
221, 204, 202, 220, 197, 181, 206, 180, 204, 217, 201, 200, 203, 172, 134, 186, 165, 160, 181, 162, 209, 206, 213,  79,  87, 158, 135, 156, 165, 148, 184, 217, 187,  89,  80, 161, 199, 116, 130,  88, 180, 224, 226, 104,  82, 144, 211,  95, 135, 139, 208, 233, 207,  69,  73, 179, 160,   1, 120, 118, 175, 235,  77,  68, 150, 197, 145,  96, 169, 142, 184, 199, 164, 188, 161, 143, 167, 162, 167, 173, 198, 175, 169, 196, 150, 147, 189, 186, 144, 187, 207, 190, 189, 159, 115,  62,  56, 158, 195, 193, 
124, 123, 123, 143, 125, 145, 152, 129, 143, 126, 147, 126, 132, 198, 196, 200, 192, 159, 136, 110, 104, 120, 185, 180, 183, 180, 187, 165, 158, 122, 110, 169, 178, 184, 163, 151, 164, 163, 154, 133, 147, 178,  74,  45,  99,  68, 121, 134, 141, 135, 196, 136, 155, 144, 169, 190, 157, 154, 131, 172, 255, 143, 226, 190, 183, 209, 170, 182, 177, 225, 178, 135, 188, 188, 199, 162, 163, 186, 192, 199, 152, 117, 178, 161, 160, 155, 147, 165, 183, 171, 126, 149, 143, 121,  99, 118, 115, 119, 122, 132, 
131, 140, 121, 152, 132, 125, 121, 148, 152, 128, 144, 118, 171, 183, 197, 185, 171, 155, 120,  99, 129, 126, 215, 191, 192, 177, 192, 169, 154, 112, 129, 147, 222, 162, 149, 130, 209, 179, 188, 117, 132, 164, 145,  90, 143, 164, 181, 151,  92,  70, 126, 181, 158, 114, 141, 173, 157, 175, 149, 154, 132, 173, 238, 162,  98, 100, 151, 186, 188, 170, 103, 152, 197, 191, 174, 143, 187, 166, 161, 114, 114, 141, 212, 178, 185, 177, 175, 158, 132, 120, 127, 129, 129, 156, 172, 171, 174, 156, 136, 119, 
198, 170, 192, 155, 179, 118, 122, 139, 156, 160, 166, 206, 181, 159, 103, 120, 134, 170, 197, 210, 161, 197, 171, 175, 155, 128, 109, 159, 166, 215, 170, 162, 148, 130, 157, 137,  92, 182, 135, 146, 152, 127, 130, 189, 222, 181, 165, 190, 165, 138, 162, 153, 185, 201, 202, 177, 217, 203, 162, 145, 177, 168, 107, 142, 133, 170, 188, 141, 144, 116, 202, 206, 137,  62,  97, 135, 139, 142, 125, 144, 200, 198, 168, 131, 139, 139, 170, 177, 199, 178, 170, 171, 176, 145,  85,  46,  38,  60, 133, 190, 
142, 143, 161, 170, 150, 141, 161, 141, 177, 174, 160, 154, 135, 124, 146, 144, 156, 165, 164, 174, 154, 145, 114, 148, 161, 161, 157, 178, 176, 217, 220, 137,  69, 156, 177, 177, 140, 149, 169, 253, 232, 115, 170, 181, 203, 198, 109, 116,  42,  46, 190, 186, 118, 135, 158, 164, 120, 160, 156, 163, 127, 140, 192, 188, 111, 135, 143, 180, 174, 173, 157, 157, 154, 180, 188, 170, 170, 178, 196, 186, 136, 177, 165, 153, 170, 185, 179, 154, 169, 181, 153, 174, 152, 141, 154, 177, 158, 134, 151, 158, 
168, 174, 179, 186, 217, 236, 218, 221, 197, 172, 144, 170, 159, 165, 180, 155, 174, 202, 210, 204, 147, 157, 157, 134, 150, 134, 148, 146, 157, 183, 159, 179, 110, 115, 144, 135, 101,  67, 126, 110, 107, 130, 115, 164, 181, 185, 106, 162, 176, 230, 101, 110,  90, 183, 187, 195, 169, 169, 191, 169,  77, 134,  88, 145, 180, 212, 164, 208, 175, 165, 132, 161,  76, 107, 155, 218, 186, 174, 166, 129, 168, 178, 185,  67,  90, 116, 120, 107, 118, 126, 154, 163, 157, 159, 125, 136, 106, 141, 158, 161, 
178, 164, 171, 172, 169, 159, 167, 180, 156, 186, 185, 167, 191, 132,  86,  38,  37,  62, 122, 157, 180, 157, 179, 212, 183, 164, 159, 156, 152, 112, 130, 200, 206, 179, 195, 179, 217, 192, 175, 128, 154, 243, 186, 188, 167,  93, 181, 186, 179, 102, 160, 212, 160, 161, 116,  70, 201, 188, 187, 130, 159, 198, 145,  77, 103, 152, 172, 144, 131,  94, 171, 203, 119, 100, 138, 154, 129, 103,  87,  78, 185, 191, 167, 191, 156, 159, 167, 115,  79, 120, 179, 162, 131, 197, 202, 208, 251, 238, 200, 194, 
111, 129, 121, 129, 114, 130, 141, 129, 136, 140, 113, 134, 135, 129, 171, 167, 182, 153, 166, 134, 132, 134,  93, 154, 151, 174, 183, 172, 171, 182, 145, 113, 167, 166, 190, 168, 131, 172, 184, 197, 189, 141, 160, 172, 182, 191, 161, 167, 175, 208, 167, 150, 115,  92, 149, 214, 162, 140, 111, 116, 133, 107, 125, 170, 180, 187, 143, 157, 148, 185, 116,  96, 140, 185, 163, 155, 164, 162, 180, 143, 115, 125, 142, 134, 166, 204, 193, 180, 182, 156, 119, 125, 112, 117, 124, 116, 100, 111, 132, 127, 
153, 181, 179, 187, 171, 154, 145, 150, 169, 150, 186, 152, 170, 178,  88,  69,  45,  54,  89, 127, 171, 192, 110, 105, 139, 164, 197, 162, 141,  86, 160, 138,  92, 154, 173, 192, 155, 176, 152,  91, 133, 149, 163, 208, 203, 133, 202, 211, 201, 138, 149, 183, 181, 173, 173, 162, 194, 187, 119,  89, 149, 176,  84, 134, 135, 136, 176, 134, 131,  99, 164, 188, 140, 117, 115, 131, 136, 129, 127, 163, 179, 177, 137, 160, 147, 146, 150, 168, 200, 209, 169, 173, 190, 210, 210, 200, 242, 215, 216, 176
};

const int32_t quantized_bias_dense[10] = { -93, 358, -243, -226, 144, -30, 39, 75, -248, 66 };

const uint8_t weight_offset_dense = 162;

const uint8_t input_offset_dense = 0;

const uint8_t output_offset_dense = 187;

const int right_shift_dense = 7;

const int32_t M_0_dense = 28386;

const uint8_t dense_correct[10] = { 153, 112, 155, 171, 167, 169, 135, 206, 158, 190 };

#endif