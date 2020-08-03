#include "common.h"

unsigned int register32_read(unsigned int register32) {
  return REGISTER32_RW(register32);
}
void register32_write(unsigned int register32, unsigned int value32) {
  REGISTER32_RW(register32) = value32;
}
void register32_and(unsigned int register32, unsigned int value32) {
  REGISTER32_RW(register32) &= value32;
}
void register32_or(unsigned int register32, unsigned int value32) {
  REGISTER32_RW(register32) |= value32;
}

unsigned int rounding_division(unsigned int dividend, unsigned int divisor) {
  if(divisor == 0) return 0;
  return (dividend + (divisor/2)) / divisor;
}
