#include "timer.h"

void timer_enable() {
  REGISTER32_RW(TIMER_TSCR) |= TIMER_TSCR_ENABLE;
}
void timer_disable() {
  REGISTER32_RW(TIMER_TSCR) &= TIMER_TSCR_DISABLE;
}
void timer_set_output_action(unsigned int channel, unsigned int output_action) {
  REGISTER32_RW(TIMER_TCR) = (REGISTER32_RW(TIMER_TCR) & ~TIMER_TCR_OUTPUT_MASK(channel)) | (TIMER_TCR_OUTPUT_MASK(channel) & (output_action << channel));
}
void timer_set_input_capture_edge(unsigned int channel, unsigned int capture_edge) {
  REGISTER32_RW(TIMER_TCR) = (REGISTER32_RW(TIMER_TCR) & ~TIMER_TCR_EDGE_MASK(channel)) | (TIMER_TCR_EDGE_MASK(channel) & (capture_edge << channel));
}
void timer_set_prescaler(unsigned int pre_div) {
  REGISTER32_RW(TIMER_TSCR2) = (REGISTER32_RW(TIMER_TSCR2) & ~TIMER_TSCR2_PRE_MASK) | (TIMER_TSCR2_PRE_MASK & pre_div);
}
void timer_set_output_compare(unsigned int channel, unsigned int output_action, unsigned int interrupt_enable, unsigned int value) {
  REGISTER32_RW(TIMER_TCR) = (REGISTER32_RW(TIMER_TCR) & ~TIMER_TCR_OUTPUT_MASK(channel)) | (TIMER_TCR_OUTPUT_MASK(channel) & (output_action << channel));
  REGISTER32_RW(TIMER_TCN(channel)) = value;
  REGISTER32_RW(TIMER_TIE) = (REGISTER32_RW(TIMER_TIE) & ~TIMER_TIE_MASK(channel)) | (TIMER_TIE_MASK(channel) & (interrupt_enable << channel));
}
void timer_set_input_capture(unsigned int channel, unsigned int capture_edge, unsigned int interrupt_enable) {
  REGISTER32_RW(TIMER_TCR) = (REGISTER32_RW(TIMER_TCR) & ~TIMER_TCR_EDGE_MASK(channel)) | (TIMER_TCR_EDGE_MASK(channel) & (capture_edge << channel));
  REGISTER32_RW(TIMER_TIE) = (REGISTER32_RW(TIMER_TIE) & ~TIMER_TIE_MASK(channel)) | (TIMER_TIE_MASK(channel) & (interrupt_enable << channel));
}
unsigned int timer_read_input_capture(unsigned int channel) { // CHECK
  return REGISTER32_RW(TIMER_TCN(channel));
}
void timer_clear_interrupt(unsigned int channels) { // CHECK: this only clears the selectee channels? not all?
  REGISTER32_RW(TIMER_FLG1) |= TIMER_FLG1_MASK & channels;
}
void timer_enable_cf(unsigned int channels) {
  REGISTER32_RW(TIMER_TCF) |= TIMER_TCF_MASK & channels;
}
void timer_enable_tov(unsigned int channels) {
  REGISTER32_RW(TIMER_TOV) |= TIMER_TOV_MASK & channels;
}
void timer_disable_tov(unsigned int channels) {
  REGISTER32_RW(TIMER_TOV) &= ~TIMER_TOV_MASK | ~channels;
}
unsigned int timer_read_count() {
  return REGISTER32_RW(TIMER_TCNT);
}
