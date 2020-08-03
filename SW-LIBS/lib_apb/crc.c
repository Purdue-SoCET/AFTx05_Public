#include "crc.h"

void crc_start() {
  REGISTER32_RW(CRC_CONTROL) |= CRC_CONTROL_START;
}
void crc_reset() {
  REGISTER32_RW(CRC_CONTROL) |= CRC_CONTROL_RESET;
}
void crc_set_polynomial(unsigned int polynomial) {
  REGISTER32_RW(CRC_CONFIG) = polynomial;
}
void crc_set_input(unsigned int input) {
  REGISTER32_RW(CRC_INPUT) = input;
}
unsigned int crc_ready() {
  return REGISTER32_RW(CRC_STATUS);
}
unsigned int crc_output() {
  return REGISTER32_RW(CRC_OUTPUT);
}
