#ifndef PARAMS_H
#define PARAMS_H

const int col_count = 28;
const int row_count = 28;
const int digit_count = col_count * row_count;
const int lbl_count = 1;
const int digit_width = 3;
const int delim_width = 1;
const int image_size = ((col_count * row_count) + lbl_count) * (digit_width + delim_width);

const char *fImgFile = "fImg.txt"; //original "file image", written in decimal
const char *cImgFile = "cImg.txt"; //file converted to binary using C
const char *hImgFile = "iImg.h"; //Helper file with array and label

#endif