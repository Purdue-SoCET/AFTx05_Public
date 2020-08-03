#ifndef COMMON_H
#define COMMON_H

#define REGISTER32_RW(addr)             (*(volatile unsigned int*)(addr))

#define CHIP_FREQ                     (50000000) //This should eventually be changed based on an ifndef depending on what it is running on. Current freq is for AFTx05

unsigned int register32_read(unsigned int register32);
void register32_write(unsigned int register32, unsigned int value32);
void register32_and(unsigned int register32, unsigned int value32);
void register32_or(unsigned int register32, unsigned int value32);

unsigned int rounding_division(unsigned int dividend, unsigned int divisor);
#endif
