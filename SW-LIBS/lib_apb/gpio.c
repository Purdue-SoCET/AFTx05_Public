#include "gpio.h"

//// Input
void gpio_enable_input(unsigned int pins) {
  REGISTER32_RW(GPIO_DATA_DIRECTION) &= ~pins;
}
unsigned int gpio_read_input(unsigned int pins) {
  return REGISTER32_RW(GPIO_DATA) & pins;
}
//// Output
void gpio_enable_output(unsigned int pins, unsigned int pin_outputs) {
  REGISTER32_RW(GPIO_DATA_DIRECTION) |= pins;
  REGISTER32_RW(GPIO_DATA) = (REGISTER32_RW(GPIO_DATA) & ~pins) | (pins & pin_outputs);
}
void gpio_set_output(unsigned int pins, unsigned int pin_outputs) {
  REGISTER32_RW(GPIO_DATA) = (REGISTER32_RW(GPIO_DATA) & ~pins) | (pins & pin_outputs);
}
//// Interrupts
void gpio_enable_interrupt_posedge(unsigned int pins) {
  REGISTER32_RW(GPIO_NEGATIVE_EDGE) &= ~pins;
  REGISTER32_RW(GPIO_POSITIVE_EDGE) |= pins;
  REGISTER32_RW(GPIO_INTERRUPT_ENABLE) |= pins;
}
void gpio_disable_interrupt_posedge(unsigned int pins) {
  REGISTER32_RW(GPIO_INTERRUPT_ENABLE) &= ~pins;
  REGISTER32_RW(GPIO_POSITIVE_EDGE) &= ~pins;
}
void gpio_enable_interrupt_negedge(unsigned int pins) {
  REGISTER32_RW(GPIO_POSITIVE_EDGE) &= ~pins;
  REGISTER32_RW(GPIO_NEGATIVE_EDGE) |= pins;
  REGISTER32_RW(GPIO_INTERRUPT_ENABLE) |= pins;
}
void gpio_disable_interrupt_negedge(unsigned int pins) {
  REGISTER32_RW(GPIO_INTERRUPT_ENABLE) &= ~pins;
  REGISTER32_RW(GPIO_NEGATIVE_EDGE) &= ~pins;
}
void gpio_clear_interrupt(unsigned int pins) {
  REGISTER32_RW(GPIO_INTERRUPT_CLEAR) |= pins;
}
unsigned int gpio_interrupt_status(unsigned int pins) {
  return REGISTER32_RW(GPIO_INTERRUPT_STATUS) & pins;
}
