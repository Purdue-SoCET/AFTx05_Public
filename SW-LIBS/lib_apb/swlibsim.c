#include "common.h"
#include "gpio.h"
#include "pwm.h"
#include "crc.h"
#include "timer.h"
#include "csim_macros.h"

int main() {
  MAIN_INIT;//asm volatile ("li sp, 0x000083FC;");
  // GPIO
 /* gpio_enable_output(GPIOALL_AFTX05, GPIOALL_AFTX05);
  gpio_enable_input(GPIOALL_AFTX05);
  gpio_enable_interrupt_posedge(GPIOALL_AFTX05);
  gpio_enable_interrupt_negedge(GPIOALL_AFTX05);
  REGISTER32_RW(GPIO_INTERRUPT_STATUS) = GPIOALL_AFTX05;*/
  // PWM
  /*pwm_set_period(PWMN(0), 15);
  pwm_set_duty(PWMN(0), 5);
  pwm_set_active_high(PWMN(0));
  pwm_set_align_center(PWMN(0));
  pwm_enable(PWMN(0));*/
  // CRC
  crc_reset();
  crc_set_input(0xFFFFFFFF);
  crc_set_polynomial(0x4C11DB7);
  crc_start();
  // Timer
  //timer_enable();
  /*REGISTER32_RW(0x80002000) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002004) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002008) = 0xFFFFFFFF;
  REGISTER32_RW(0x8000200C) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002010) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002014) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002018) = 0xFFFFFFFF;
  REGISTER32_RW(0x8000201C) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002020) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002024) = 0xFFFFFFFF;
  REGISTER32_RW(0x80002028) = 0xFFFFFFFF;
  REGISTER32_RW(0x8000202C) = 0xFFFFFFFF;*/
  MAIN_RETURN;//while(1);
  //return 0;
}
