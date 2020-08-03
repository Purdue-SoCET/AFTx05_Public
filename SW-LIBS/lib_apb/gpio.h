#ifndef GPIO_H
#define GPIO_H

#include "common.h"

// GPIO (0x8000 0000 - 0x8000 FFFF)
// APB Registers
#define GPIO                            (0x80000000)
#define GPIO_DATA                       (GPIO + 0x04)
#define GPIO_DATA_DIRECTION             (GPIO + 0x08)
#define GPIO_INTERRUPT_ENABLE           (GPIO + 0x0C)
#define GPIO_POSITIVE_EDGE              (GPIO + 0x10)
#define GPIO_NEGATIVE_EDGE              (GPIO + 0x14)
#define GPIO_INTERRUPT_CLEAR            (GPIO + 0x18)
#define GPIO_INTERRUPT_STATUS           (GPIO + 0x1C)

#define GPION(pin)                      (1 << pin)
#define GPIOALL_AFTX05                  (0xFF)
#define GPIOALL                         (0xFFFFFFFF)

// Function Prototypes
//// Input
void gpio_enable_input(unsigned int pins);
unsigned int gpio_read_input(unsigned int pins);
//// Output
void gpio_enable_output(unsigned int pins, unsigned int pin_outputs);
void gpio_set_output(unsigned int pins, unsigned int pin_outputs);
//// Interrupts
void gpio_enable_interrupt_posedge(unsigned int pins); //CHECK: are posedge and negedge mutually exclusive? should they be?
void gpio_disable_interrupt_posedge(unsigned int pins); //CHECK: are posedge and negedge mutually exclusive? should they be?
void gpio_enable_interrupt_negedge(unsigned int pins); //CHECK: are posedge and negedge mutually exclusive? should they be?
void gpio_disable_interrupt_negedge(unsigned int pins); //CHECK: are posedge and negedge mutually exclusive? should they be?
void gpio_clear_interrupt(unsigned int pins);
unsigned int gpio_interrupt_status(unsigned int pins);

#endif
