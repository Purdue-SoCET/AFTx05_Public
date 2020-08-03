#include <stdint.h>

#include "conv.h"
#include "dense.h"
#include "img.h"
#include "../../c-firmware/c_self_test.h"

// Global Variables
uint8_t IMG_SIZE  = 10 * 10;
uint8_t N_FILTERS = 1;
uint8_t N_CLASSES = 10;
uint8_t KERNEL    = 3;

void Conv(uint8_t output_conv_arr[IMG_SIZE][N_FILTERS]);
int32_t maxOf(int32_t a, int32_t b);
int32_t minOf(int32_t a, int32_t b);
int32_t RoundingDivideByPOT(int32_t x, int exponent);
int32_t SaturatingRoundingDoublingHighMul(int32_t a, int32_t b);
int32_t MultiplyByQuantizedMultiplierSmallerThanOne(int32_t x, int32_t quant_mul, int right_shift);
void FullyConnectedDense(uint8_t quantized_inputs[IMG_SIZE][N_FILTERS], uint8_t output_full_conn_dense_arr[1][N_CLASSES]);
uint8_t argMaxPred(uint8_t quantized_input[1][N_CLASSES]);
int32_t MAC(int32_t acc, int32_t x, int32_t y);

int32_t maxOf(int32_t a, int32_t b) {
	if (a > b) return a;
	else return b;
}

int32_t minOf(int32_t a, int32_t b) {
	if (a < b) return a;
	else return b;
}

int32_t RoundingDivideByPOT(int32_t x, int exponent) {
	int32_t mask = (int32_t)((1 << exponent) - 1);
	int32_t zero = (int32_t)(0);
	int32_t one = (int32_t)(1);
	int32_t remainder = x & mask;

	int32_t maskiflessthan = x;
	if (x < zero) maskiflessthan &= zero;

	int32_t threshold = (mask >> 1) + (maskiflessthan & one);
	int32_t maskifgreaterthan = remainder;
	if (remainder > threshold) maskifgreaterthan &= threshold;

	return (x >> exponent) + (maskifgreaterthan & one);
}

int32_t SaturatingRoundingDoublingHighMul(int32_t a, int32_t b) {
	int overflow = (a == b) & (a == 0-2147483648);
	if (overflow) return (int32_t)(2147483647);

	int32_t a_32 = (int32_t) a;
	int32_t b_32 = (int32_t) b;
	int32_t ab_32 = a_32 * b_32;
	int32_t nudge;

	if (ab_32 >= 0) nudge = (int32_t)(1 << 14);
	else nudge = (int32_t)(1 - (1 << 14));

	int32_t ab_x2_high16 = (int32_t)((ab_32 + nudge) / (int32_t)((int32_t)(1) << 15));
	return ab_x2_high16;
}

int32_t MultiplyByQuantizedMultiplierSmallerThanOne(int32_t x, int32_t quant_mul, int right_shift) {
	return RoundingDivideByPOT(SaturatingRoundingDoublingHighMul(x, quant_mul), right_shift);
}

int32_t MAC(int32_t acc, int32_t x, int32_t y) { // 00000ccc
	return acc + (x * y);
}

void Conv(uint8_t output_conv_arr[IMG_SIZE][N_FILTERS]) {
	int rows = N_FILTERS;
	int cols = IMG_SIZE;

	int32_t acc;
	int32_t input_val;
	int32_t weight_val;
	for (int i = 0; i < rows; i++) {
		acc = 0;
		for (int j = 0; j < cols; j++) {
			if ((j + 1 <= cols - 1) & (j > 0)) {
				for (int k = 0; k < KERNEL; k++) {
					input_val = (int32_t)(img[0][j - 1 + k][0]) - input_offset_conv;
					weight_val = (int32_t)(quantized_weight_conv[0][0][k][i]) - weight_offset_conv;
					acc = MAC(acc, input_val, weight_val);
				}
			}
			acc += quantized_bias_conv[i];
			acc = MultiplyByQuantizedMultiplierSmallerThanOne(acc, M_0_conv, right_shift_conv);
			acc += output_offset_conv;
			acc = maxOf(acc, (int32_t)(0));
			acc = minOf(acc, (int32_t)(255));
			output_conv_arr[j][i] = (uint8_t)(acc);
		}
	}
}

void FullyConnectedDense(uint8_t quantized_inputs[IMG_SIZE][N_FILTERS], uint8_t output_full_conn_dense_arr[1][N_CLASSES]) {
	int32_t acc;
	int32_t input_val;
	int32_t weight_val;
	int weight_index;
	for (int i = 0; i < N_CLASSES; i++) {
		acc = 0;
		weight_index = 0;
		for (int j = 0; j < IMG_SIZE; j++) {
			for (int k = 0; k < N_FILTERS; k++) {
				input_val = (int32_t)(quantized_inputs[j][k]);
				weight_val = (int32_t)(quantized_weight_dense[i][weight_index]);
				acc += (input_val - input_offset_dense) * (weight_val - weight_offset_dense);
				weight_index++;
			}
		}
		acc += quantized_bias_dense[i];
		acc = MultiplyByQuantizedMultiplierSmallerThanOne(acc, M_0_dense, right_shift_dense);
		acc += output_offset_dense;
		acc = maxOf(acc, (int32_t)(0));
		acc = minOf(acc, (int32_t)(255));
		output_full_conn_dense_arr[0][i] = (uint8_t)(acc);
	}
}
uint8_t argMaxPred(uint8_t quantized_input[1][N_CLASSES]) {
	uint8_t argMax      = 0;
	uint8_t argMaxIndex = 0;

	for (int i = 0; i < N_CLASSES; i++) {
		if (quantized_input[0][i] > argMax) {
			argMax      = quantized_input[0][i];
			argMaxIndex = i;
		}
	}
	return argMaxIndex;
}

int main (void) {	
	uint8_t output_conv[IMG_SIZE][N_FILTERS];
	uint8_t output_dense[1][N_CLASSES];
	uint8_t final_pred = 0;
	uint8_t mismatch = 0;
	
	Conv(output_conv);
	FullyConnectedDense(output_conv, output_dense);
	final_pred = argMaxPred(output_dense);

	for (int i = 0; i < N_CLASSES; i++) {
		if (dense_correct[i] != output_dense[0][i]) {
			mismatch = 1;
		}
	}

	if (final_pred != lbl) {
		mismatch = 1;
	}

	if (mismatch) {
		TEST_FINISH_FAIL(1)
	}

	TEST_FINISH_SUCCESS
	return 0;
}
