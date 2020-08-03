#include "timer.h"

/*********************** EXTERNAL API METHODS FOLLOW *************************/
inline void enableTimer()
{
    SET_TCREN();
}

inline void disableTimer()
{
    CLEAR_TCREN();
}

inline void setOutputAction(int channel, output_level action)
{
    switch(action) {
        case DISCONNECTED:
            CLEAR_BIT(TCR, channel + OM_OFFSET);
            CLEAR_BIT(TCR, channel + OL_OFFSET);
            break;
        case TOGGLE:
            CLEAR_BIT(TCR, channel + OM_OFFSET);
            SET_BIT(TCR, channel + OL_OFFSET);
            break;
        case CLEAR:
            SET_BIT(TCR, channel + OM_OFFSET);
            CLEAR_BIT(TCR, channel + OL_OFFSET);
            break;
        case SET:
            SET_BIT(TCR, channel + OM_OFFSET);
            SET_BIT(TCR, channel + OL_OFFSET);
            break;
    }
}

inline void setInputCaptureEdge(int channel, input_edge edge)
{
    switch(edge) {
        case DISABLE:
            CLEAR_BIT(TCR, channel + EDGEA_OFFSET);
            CLEAR_BIT(TCR, channel + EDGEB_OFFSET);
            break;
        case RISING:
            SET_BIT(TCR, channel + EDGEA_OFFSET);
            CLEAR_BIT(TCR, channel + EDGEB_OFFSET);
            break;
        case FALLING:
            CLEAR_BIT(TCR, channel + EDGEA_OFFSET);
            SET_BIT(TCR, channel + EDGEB_OFFSET);
            break;
        case EITHER:
            SET_BIT(TCR, channel + EDGEA_OFFSET);
            SET_BIT(TCR, channel + EDGEB_OFFSET);
            break;
    }
}

inline void setTimPrescaler(clk_div divider)
{
    CLEAR_BIT(TSCR2, CLKDIV_OFFSET);
    CLEAR_BIT(TSCR2, CLKDIV_OFFSET+1);
    CLEAR_BIT(TSCR2, CLKDIV_OFFSET+2);
    switch(divider) {
        case NONE:
            break;
        case DIV_2:
            SET_BIT(TSCR2, CLKDIV_OFFSET);
            break;
        case DIV_4:
            SET_BIT(TSCR2, CLKDIV_OFFSET+1);
            break;
        case DIV_8:
            SET_BIT(TSCR2, CLKDIV_OFFSET);
            SET_BIT(TSCR2, CLKDIV_OFFSET+1);
            break;
        case DIV_16:
            SET_BIT(TSCR2, CLKDIV_OFFSET+2);
            break;
        case DIV_32:
            SET_BIT(TSCR2, CLKDIV_OFFSET);
            SET_BIT(TSCR2, CLKDIV_OFFSET+2);
            break;
        case DIV_64:
            SET_BIT(TSCR2, CLKDIV_OFFSET+1);
            SET_BIT(TSCR2, CLKDIV_OFFSET+2);
            break;
        case DIV_128:
            SET_BIT(TSCR2, CLKDIV_OFFSET);
            SET_BIT(TSCR2, CLKDIV_OFFSET+1);
            SET_BIT(TSCR2, CLKDIV_OFFSET+2);
            break;
    }
}

inline void setOutputCompare(int channel, output_level action,
                        int IRQ_en, int value)
{
    SET_IOS(channel);
    setOutputAction(channel, action);
    if(IRQ_en)
        SET_TIE(channel);
    else
        CLEAR_TIE(channel);
    SET_REGISTER((volatile int *)(TC0+channel), value);
}

inline void setInputCapture(int channel, input_edge edge, int IRQ_en)
{
    CLEAR_IOS(channel);
    setInputCaptureEdge(channel, edge);
    if(IRQ_en)
        SET_TIE(channel);
    else
        CLEAR_TIE(channel);
}

inline void clearIRQ(int channel)
{
    if(channel == TIMER)
        CLEAR_FLAG(FLG2, 7);
    else
        CLEAR_FLAG(FLG1, channel);
}

inline int getTimerCount()
{
    return *TCNT;
}

int main(void)
{
    setOutputAction(CHANNEL_2, DISCONNECTED);
    setInputCaptureEdge(CHANNEL_0, FALLING);
    setTimPrescaler(DIV_16);
    setOutputCompare(CHANNEL_3, SET, ENABLED, 0x42);
    setInputCapture(CHANNEL_4, RISING, DISABLED);
    getTimerCount();
    clearIRQ(TIMER);
    return 1;
}
