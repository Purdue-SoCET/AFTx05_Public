#include "../pwm.h"
#include "../csim_macros.h"

int main() {
  MAIN_INIT;
  
  pwm_disable(PWMN(0));
  pwm_set_frequency(PWMN(0), 25000000);
  pwm_enable(PWMN(0));
  
  pwm_disable(PWMN(0));
  pwm_set_frequency(PWMN(0), 12500000);
  pwm_enable(PWMN(0));
  
  pwm_disable(PWMN(0));
  pwm_set_frequency(PWMN(0), 10000000);
  pwm_enable(PWMN(0));
  
  pwm_disable(PWMN(0));
  pwm_set_frequency(PWMN(0), 5000000);
  pwm_enable(PWMN(0));
  
  MAIN_RETURN;
}
