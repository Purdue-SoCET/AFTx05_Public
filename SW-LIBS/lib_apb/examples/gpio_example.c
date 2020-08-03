#include "../gpio.h"
#include "../csim_macros.h"

// Description: Acts as a looping up-counter which is incremented each time GPION7 is pulled high. This example is to meant to be used with a common cathode (common ground) display. If a common anode is being used, invert the value of 'digit' for the output pins.
// This demonstration would be better with a posedge interrupt but the interrupt handler has not been implemented.

// 'digit' is aligned [][7:0] = [-, a, b, c, d, e, f, g] for the 7 segment display
// 'digit': 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, f
unsigned int digit[] = {0b1111110, 0b1100000, 0b1101101, 0b1111001,
                        0b0110011, 0b1011011, 0b1011111, 0b1110000,
                        0b1111111, 0b1110011, 0b1110111, 0b0011111,
                        0b1001110, 0b0111101, 0b1001111, 0b1000111};

int main() {
  MAIN_INIT;
  // Variables
  int digit_sel = 0; // 'digit' index
  int digit_count = 16; // 'digit' count
  unsigned int pins_6_0 = GPION(6) | GPION(5) | GPION(4) | GPION(3) | GPION(2) | GPION(1) | GPION(0); // output pin mask
  // IO Config
  gpio_enable_output(pins_6_0, digit[digit_sel]); // gpio pins 6-0 are outputs
  gpio_enable_input(GPION(7)); // gpio pin 7 is an input
  // Functionality
  while(1) {
    if(gpio_read_input(GPION(7))) {
      digit_sel = (digit_sel + 1) % digit_count;
      gpio_set_output(pins_6_0, digit[digit_sel]);
      //CHECK: could make it wait till button release
    }
  }
  MAIN_RETURN;
}
