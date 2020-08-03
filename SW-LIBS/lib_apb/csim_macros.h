#ifndef __C_SIM_MACROS_H
#define __C_SIM_MACROS_H

#define SP_INIT asm volatile ("li sp, 0x000083FC;");
#define MAIN_INIT SP_INIT
#define MAIN_RETURN while(1);

#endif
