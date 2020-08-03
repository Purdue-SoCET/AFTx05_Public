#ifndef CRC_H
#define CRC_H

#include "common.h"

// CRC (0x8003 0000 - 0x8003 FFFF)
// APB Registers
#define CRC                             (0x80030000)
#define CRC_NAND_NOR_CONTROL            (CRC + 0x00)
#define CRC_NAND_NOR_INPUT              (CRC + 0x04)
#define CRC_NAND_NOR_OUTPUT             (CRC + 0x08)
#define CRC_XOR_BUF_CONTROL             (CRC + 0x0C)
#define CRC_XOR_BUF_INPUT               (CRC + 0x10)
#define CRC_XOR_BUF_OUTPUT              (CRC + 0x14)
#define CRC_CONTROL                     (CRC + 0x18)
#define CRC_CONFIG                      (CRC + 0x1C)
#define CRC_STATUS                      (CRC + 0x20)
#define CRC_INPUT                       (CRC + 0x24)
#define CRC_OUTPUT                      (CRC + 0x28)

// CRC APB Register Bits
//// NAND/NOR Control
#define CRC_NAND_CONTROL                (0 << 0)
#define CRC_NOR_CONTROL                 (1 << 0)
//// NAND/NOR Input
#define CRC_NAND_NOR_INPUT_A            (1 << 0)
#define CRC_NAND_NOR_INPUT_B            (1 << 1)
//// XOR/BUF Control
#define CRC_BUF_CONTROL                 (0 << 0)
#define CRC_XOR_CONTROL                 (1 << 0)
//// XOR/BUF Input
#define CRC_XOR_BUF_INPUT_A             (1 << 0)
#define CRC_XOR_BUF_INPUT_B             (1 << 1)
//// CRC Control
#define CRC_CONTROL_START               (1 << 0)
#define CRC_CONTROL_RESET               (1 << 1)
//// CRC CONFIG
#define CRC_CONFIG_BUF_ALL              (0x00000000)
#define CRC_CONFIG_XOR_ALL              (0xFFFFFFFF)

void crc_start();
void crc_reset();
void crc_set_polynomial(unsigned int polynomial);
void crc_set_input(unsigned int input);
unsigned int crc_ready();
unsigned int crc_output();

#endif
