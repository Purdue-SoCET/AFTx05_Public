#include "pwm.h"


void pwm_set_frequency(unsigned int channel, unsigned int frequency) {
  frequency = PWM_MAX_FREQ < frequency ? PWM_MAX_FREQ : frequency;
  unsigned int period = rounding_division(CHIP_FREQ, frequency); // rounding
  REGISTER32_RW(PWM_PERIOD + channel) = period;
  REGISTER32_RW(PWM_DUTY + channel) =  rounding_division(period, 2) + AFTX05_DUTY_OFFSET;
}
//// Period
void pwm_set_period(unsigned int channel, unsigned int period){
  REGISTER32_RW(PWM_PERIOD + channel) = period;
}
//// Duty
void pwm_set_duty(unsigned int channel, unsigned int duty){
  REGISTER32_RW(PWM_DUTY + channel) = duty + AFTX05_DUTY_OFFSET;
}
//// Control
void pwm_disable(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) &= PWM_CONTROL_DISABLE;
}
void pwm_enable(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) |= PWM_CONTROL_ENABLE;
}
void pwm_set_active_high(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) &= PWM_CONTROL_ACTIVE_HIGH;
}
void pwm_set_active_low(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) |= PWM_CONTROL_ACTIVE_LOW;
}
void pwm_set_align_left(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) &= PWM_CONTROL_ALIGN_LEFT;
}
void pwm_set_align_center(unsigned int channel) {
  REGISTER32_RW(PWM_CONTROL + channel) |= PWM_CONTROL_ALIGN_CENTER;
}
