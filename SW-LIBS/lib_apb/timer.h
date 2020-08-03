#ifndef TIMER_H
#define TIMER_H

#include "common.h"

// Timer (0x8002 0000 - 0x8002 FFFF)
// APB Registers
#define TIMER                           (0x80020000)
#define TIMER_IOS                       (TIMER + 0x00)
#define TIMER_TCF                       (TIMER + 0x04)
#define TIMER_TCNT                      (TIMER + 0x08)
#define TIMER_TSCR                      (TIMER + 0x0C)
#define TIMER_TOV                       (TIMER + 0x10)
#define TIMER_TCR                       (TIMER + 0x14)
#define TIMER_TIE                       (TIMER + 0x14)
#define TIMER_TSCR2                     (TIMER + 0x1C)
#define TIMER_FLG1                      (TIMER + 0x20)
#define TIMER_FLG2                      (TIMER + 0x24)
#define TIMER_TCN(channel)              (TIMER + 0x28 + (0x4 * channel))

// Timer APB Register Bits
//// IOS
#define TIMER_IOS_INPUT(channel)       ~(1 << channel)
#define TIMER_IOS_OUTPUT(channel)       (1 << channel)
//// TCF
#define TIMER_TCF_MASK                  (0xFF)
//// TSCR
#define TIMER_TSCR_ENABLE               (1 << 7)
#define TIMER_TSCR_DISABLE             ~(1 << 7)
//// TOV
#define TIMER_TOV_MASK           (0xFF)
//// TCR
#define TIMER_TCR_EDGE_MASK(channel)    (0x101 << channel)
#define TIMER_TCR_EDGE_DISABLE          (0x000)
#define TIMER_TCR_EDGE_FALLING          (0x001)
#define TIMER_TCR_EDGE_RISING           (0x100)
#define TIMER_TCR_EDGE_EITHER           (0x101)
#define TIMER_TCR_OUTPUT_MASK(channel)  ((0x101 << 16) << channel)
#define TIMER_TCR_OUTPUT_DISCONNECT     (0x000 << 16)
#define TIMER_TCR_OUTPUT_TOGGLE         (0x001 << 16)
#define TIMER_TCR_OUTPUT_CLEAR          (0x100 << 16)
#define TIMER_TCR_OUTPUT_SET            (0x101 << 16)
//// TIE
#define TIMER_TIE_MASK(channel)         (1 << channel)
#define TIMER_TIE_ENABLE                (1)
#define TIMER_TIE_DISABLE              ~(1)
//// TSCR2
#define TIMER_TSCR2_TOI_ENABLE          (1 << 7)
#define TIMER_TSCR2_TOI_DISABLE        ~(1 << 7)
#define TIMER_TSCR2_TCRE_ENABLE         (1 << 6)
#define TIMER_TSCR2_TCRE_DISABLE       ~(1 << 6)
#define TIMER_TSCR2_PRE_MASK            (0x7)
#define TIMER_TSCR2_PRE_DIV1            (0)
#define TIMER_TSCR2_PRE_DIV2            (1)
#define TIMER_TSCR2_PRE_DIV4            (2)
#define TIMER_TSCR2_PRE_DIV8            (3)
#define TIMER_TSCR2_PRE_DIV16           (4)
#define TIMER_TSCR2_PRE_DIV32           (5)
#define TIMER_TSCR2_PRE_DIV64           (6)
#define TIMER_TSCR2_PRE_DIV128          (7)
//// FLG1 CHECK: may want to just make a general mask for the channels
#define TIMER_FLG1_MASK                 (0xFF)
//// FLG2
#define TIMER_FLG2_CLEAR                (1 << 7)

// Function Prototypes CHECK:: all come from previous timer doc
void timer_enable();
void timer_disable();
void timer_set_output_action(unsigned int channel, unsigned int output_action);
void timer_set_input_capture_edge(unsigned int channel, unsigned int capture_edge);
void timer_set_prescaler(unsigned int pre_div);
void timer_set_output_compare(unsigned int channel, unsigned int output_action, unsigned int interrupt_enable, unsigned int value);
void timer_set_input_capture(unsigned int channel, unsigned int capture_edge, unsigned int interrupt_enable);
unsigned int timer_read_input_capture(unsigned int channel);
void timer_clear_interrupt(unsigned int channel);
void timer_enable_cf(unsigned int channels);
void timer_enable_tov(unsigned int channels);
void timer_disable_tov(unsigned int channels);
unsigned int timer_read_count();

#endif
