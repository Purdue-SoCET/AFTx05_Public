#ifndef TIMER_H
#define TIMER_H

#define TIMER_BASE                  (volatile int *)0x80010000
#define IOS                         (volatile int *)(TIMER_BASE+1)
#define TCF                         (volatile int *)(TIMER_BASE+2)
#define TCNT                        (volatile int *)(TIMER_BASE+3)
#define TSCR                        (volatile int *)(TIMER_BASE+4)
#define TOV                         (volatile int *)(TIMER_BASE+5)
#define TCR                         (volatile int *)(TIMER_BASE+6)
#define TIE                         (volatile int *)(TIMER_BASE+7)
#define TSCR2                       (volatile int *)(TIMER_BASE+8)
#define FLG1                        (volatile int *)(TIMER_BASE+9)
#define FLG2                        (volatile int *)(TIMER_BASE+10)
#define TC0                         (volatile int *)(TIMER_BASE+11)
#define TC1                         (volatile int *)(TIMER_BASE+12)
#define TC2                         (volatile int *)(TIMER_BASE+13)
#define TC3                         (volatile int *)(TIMER_BASE+14)
#define TC4                         (volatile int *)(TIMER_BASE+15)
#define TC5                         (volatile int *)(TIMER_BASE+16)
#define TC6                         (volatile int *)(TIMER_BASE+17)
#define TC7                         (volatile int *)(TIMER_BASE+18)

#define CHANNEL_0                   0
#define CHANNEL_1                   1
#define CHANNEL_2                   2
#define CHANNEL_3                   3
#define CHANNEL_4                   4
#define CHANNEL_5                   5
#define CHANNEL_6                   6
#define CHANNEL_7                   7
#define TIMER                       8

#define ENABLED                     1
#define DISABLED                    0

#define OM_OFFSET                   24                     
#define OL_OFFSET                   16
#define EDGEA_OFFSET                8
#define EDGEB_OFFSET                0

#define CLKDIV_OFFSET               0 

#define SET_BIT(addr, position)     (*addr |= (1 << position))
#define CLEAR_BIT(addr, position)   (*addr &= (0xFFFFFFFF & ~(1 << 7)))
#define CLEAR_FLAG(addr, position)  (*addr = (1 << position))
#define SET_TCREN()                 SET_BIT(TSCR,7)  
#define CLEAR_TCREN()               CLEAR_BIT(TSCR,7)
#define SET_IOS(position)           SET_BIT(IOS, position)
#define CLEAR_IOS(position)         CLEAR_BIT(IOS, position)
#define SET_TCF(position)           SET_BIT(TCF, position)
#define SET_TOV(position)           SET_BIT(TOV, position)
#define CLEAR_TOV(position)         CLEAR_BIT(TOV, position)
#define SET_TIE(position)           SET_BIT(TIE, position)
#define CLEAR_TIE(position)         CLEAR_BIT(TIE, position)
#define SET_TOI()                   SET_BIT(TSCR2, 7)
#define CLEAR_TOI()                 CLEAR_BIT(TSCR2, 7)
#define SET_TCRE()                  SET_BIT(TSCR2, 6)
#define CLEAR_TCRE()                CLEAR_BIT(TSCR2, 6)
#define SET_REGISTER(addr, value)   (*addr = value);


typedef enum {
    DISCONNECTED,
    TOGGLE,
    CLEAR,
    SET
} output_level;

typedef enum {
    DISABLE,
    RISING,
    FALLING,
    EITHER
} input_edge;

typedef enum {
    NONE,
    DIV_2,
    DIV_4,
    DIV_8,
    DIV_16,
    DIV_32,
    DIV_64,
    DIV_128
} clk_div;

void enableTimer();
void disableTimer();
void setOutputAction(int channel, output_level action);
void setInputCaptureEdge(int channel, input_edge edge);
void setTimPrescaler(clk_div divider);
void setOutputCompare(int channel, output_level action,
                        int IRQ_en, int value);
void setInputCapture(int channel, input_edge edge, int IRQ_en);
int getTimerCount();
void clearIRQ(int channel);

#endif
