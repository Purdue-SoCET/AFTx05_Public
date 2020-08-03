#include "../crc.h"
#include "../csim_macros.h"

int main() {
  MAIN_INIT;
  crc_set_polynomial(0x4C11DB3);
  // Generating checksum for 128bit data.
  crc_set_input(0x11122210);
  crc_reset();
  crc_set_input(0x42501202);
  crc_start();
  while(!crc_ready());
  crc_set_input(0x24FCC0);
  crc_start();
  while(!crc_ready());
  crc_set_input(0x4222A65C);
  crc_start();
  while(!crc_ready());
  crc_set_input(0x0);
  crc_start();
  while(!crc_ready());
  // Doing the CRC again but using the previous checksum to show it is zero result
  crc_set_input(0x11122210);
  crc_reset();
  crc_set_input(0x42501202);
  crc_start();
  while(!crc_ready());
  crc_set_input(0x24FCC0);
  crc_start();
  while(!crc_ready());
  crc_set_input(0x4222A65C);
  crc_start();
  while(!crc_ready());
  crc_set_input(0xDFBAF47C);
  crc_start();
  while(!crc_ready());
  MAIN_RETURN;
}
