#ifndef CONVERTFILE_H
#define CONVERTFILE_H
#include "params.h"
#include <math.h>
#include <stdint.h>

void fImgTOcImg(char *fImg, char *cImg, char *lbl) { //convert file image to bytes
	for (int i = 0; i < digit_count; i++) {
		for (int j = 0; j < digit_width; j++) {
			cImg[i] += (fImg[j + i * (digit_width + delim_width)] - '0') * pow(10, (digit_width - 1) - j);
		}
	}
	lbl[0] = fImg[image_size - 2] - '0';
}

void printVisual(char *cImg, char lbl, bool printLbl) { //prints the test image for visualization
	for (int i = 0; i < row_count; i++) {
		for (int j = 0; j < col_count; j++) printf("%03d ", (cImg[i*col_count + j] >= 0) ? cImg[i*col_count + j] : 256 + cImg[i*col_count + j]);
		printf("\n");
	}
	if (printLbl) printf("%d\n", lbl);
	printf("\n");
}

void saveBinary(char* cImg, char lbl) {
	FILE *writeFile;
	fopen_s(&writeFile, cImgFile, "w+");
	fwrite(cImg, sizeof(cImg[0]), digit_count, writeFile);
	fwrite(&lbl, sizeof(lbl), lbl_count, writeFile);
	fclose(writeFile);
}

void convertBinary() {
	FILE *readFile;
	fopen_s(&readFile, fImgFile, "r");
	fseek(readFile, 0, SEEK_SET);

	char fImg[image_size] = { 0 };
	fread(fImg, sizeof(fImg[0]), image_size, readFile);
	fclose(readFile);

	char cImg[digit_count] = { 0 };
	char lbl = 0;
	fImgTOcImg(fImg, cImg, &lbl);
	printVisual(cImg, lbl, true);

	saveBinary(cImg, lbl);
}

void fImgTOiImg(char *fImg, uint8_t *iImg, uint8_t *lbl) {
	for (int i = 0; i < digit_count; i++) {
		for (int j = 0; j < digit_width; j++) {
			iImg[i] += (fImg[j + i * (digit_width + delim_width)] - '0') * pow(10, (digit_width - 1) - j);
		}
	}
	lbl[0] = fImg[image_size - 2] - '0';
}

void saveHelper(uint8_t* iImg, uint8_t lbl) {
	FILE *writeFile;
	fopen_s(&writeFile, hImgFile, "w+");
	fprintf(writeFile, "#ifndef IIMG_H\n");
	fprintf(writeFile, "#define IIMG_H\n");
	fprintf(writeFile, "#include <stdint.h>\n\n");

	fprintf(writeFile, "uint8_t img[%d] = { ", digit_count);
	for (int i = 0; i < row_count; i++) {
		for (int j = 0; j < col_count; j++) {
			if (i*col_count + j == digit_count - 1) fprintf(writeFile, "%d", iImg[i*col_count + j]);
			else fprintf(writeFile, "%d, ", iImg[i*col_count + j]);
		}
		if (i != row_count - 1) fprintf(writeFile, "\n");
	}
	fprintf(writeFile, " };\n\n");

	fprintf(writeFile, "uint8_t imgLbl = %d;\n\n", lbl);

	fprintf(writeFile, "#endif");
	fclose(writeFile);
}

void convertHelper() {
	FILE *readFile;
	fopen_s(&readFile, fImgFile, "r");
	fseek(readFile, 0, SEEK_SET);

	char fImg[image_size] = { 0 };
	fread(fImg, sizeof(fImg[0]), image_size, readFile);
	fclose(readFile);

	uint8_t iImg[digit_count] = { 0 };
	uint8_t lbl = 0;
	fImgTOiImg(fImg, iImg, &lbl);
	
	saveHelper(iImg, lbl);
}
#endif