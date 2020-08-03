#ifndef READ_CIMG_H
#define READ_CIMG_H
#include "params.h"
#include "stdafx.h"

void read_cImg(char *cImg, char *lbl) {
	FILE *readFile;
	fopen_s(&readFile, cImgFile, "r");
	fread(cImg, sizeof(cImg[0]), digit_count, readFile);
	lbl[0] = fgetc(readFile);
}

#endif READ_CIMG_H