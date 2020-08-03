"""
Code dump for scratch code when working through softmax function
"""

# Slop code for SoftMax Function...
#
# pp(output_full_conn_arr)
# pp(quantized_correct_output)
# pp(dequantize(inter_layer[0], quantized_correct_output))
#
# output_full_conn_arr_2 = np.zeros(shape=(1, 10), dtype=np.uint8)
# input_scale, input_offset = inter_layer[0]['quantization']
# output_scale, output_offset = inter_layer[2]['quantization']
# M = input_scale / output_scale
# left_shift, M_0 = quantize_mult_greater_one(M)
# quantized_correct_output = interpreter.get_tensor(inter_layer[2]['index'])
# max_in_row = max(output_full_conn_arr[0])
# diff_min = -25

# input_scale_fixed_point = float_to_q(input_scale, 0)
# scaled_val = np.int32(output_full_conn_arr[0][8]) - input_offset
# float_input_val = (np.int64(input_scale_fixed_point) * scaled_val) >> 12

# sum_of_exps = 0
# temp_arr = []
# # Sum of Exps
# for i in range(10):
#     input_val = np.int32(output_full_conn_arr[0][i])
#     input_diff = input_val - max_in_row
#     if input_diff >= -32:
#         input_diff_rescaled = MultiplyByQuantizedMultiplierGreaterThanOne(input_diff, M_0, left_shift)
#         result = exp_on_negative_values(input_diff_rescaled, 5)
#         mask = (1 << (32 - 0 - 1)) - 1
#         mask_shift = np.int32((result & mask) >> 12)
#         rescaled_x = np.int32(mask_shift | (0 << 31))  # stay pos
#         sum_of_exps += rescaled_x
#
#
# # # sum_of_exps = float_to_q(1.25, 12)
# headroom_plus_one = CountLeadingZeros(np.uint32(sum_of_exps))
# num_bits_over_unit = 12 - headroom_plus_one
# shifted_sum_minus_one = np.int32((np.uint32(sum_of_exps) << headroom_plus_one) - (np.uint32(1) << 31))
# shifted_scale = one_over_one_plus_x_for_x_in_0_1(shifted_sum_minus_one, 0)
# #
# for i in range(10):
#     input_val = np.int32(output_full_conn_arr[0][i])
#     input_diff = np.int32(input_val - max_in_row)
#     if input_diff >= -32:
#         input_diff_rescaled = MultiplyByQuantizedMultiplierGreaterThanOne(input_diff, M_0, left_shift)
#         result = exp_on_negative_values(input_diff_rescaled, 5)
#         scaled_result = SaturatingRoundingDoublingHighMul(shifted_scale, result)
#         unsat_output = RoundDividByPOT(scaled_result, num_bits_over_unit + 31 - 8)
#         unsat_output = np.min([unsat_output, np.int32(255)])
#         unsat_output = np.max([unsat_output, np.int32(0)])
#         output_full_conn_arr_2[0][i] = np.uint8(unsat_output)
#     else:
#         output_full_conn_arr_2[0][i] = np.uint8(0)
#
# pp(output_full_conn_arr_2)
# pp(quantized_correct_output)

# fixed_sum_of_exps = FixedPointAcc_Raw(sum_of_exps)
# headroom_plus_one = CountLeadingZeros(fixed_sum_of_exps)
# num_bits_over_unit = kAccumulationIntegerBits - headroom_plus_one
# shifted_sum_minus_one = np.int32((np.int32(fixed_sum_of_exps) << headroom_plus_one) - (np.int32(1) << 31))
# shifted_scale = one_over_one_plus_x_for_x_in_0_1(FixedPoint0_Raw(shifted_sum_minus_one))
#
# for i in range(10):
#     input_val = np.int32(output_full_conn_arr[0][i])
#     input_diff = np.int32(input_val - max_in_row)
#     if input_diff >= diff_min:
#         input_diff_rescaled = MultiplyByQuantizedMultiplierGreaterThanOne(input_diff, M_0, left_shift)
#         scaled_diff_f8 = FixedPointScaledDiff_Raw(input_diff_rescaled)
#         sum_of_exps += Rescale(exp_on_negative_vales(scaled_diff_f8))
#         exp_in_0 = exp_on_negative_vales(scaled_diff_f8)
#         unsat_output = RoundDividByPOT(FixedPoint0_Raw(shifted_scale * exp_in_0), num_bits_over_unit + 31 - 8)
#         unsat_output = np.max([unsat_output, np.int32(0)])
#         unsat_output = np.min([unsat_output, np.int32(255)])
#         output_full_conn_arr_2[0][i] = np.uint8(unsat_output)
#     else:
#         output_full_conn_arr_2[0][i] = 0