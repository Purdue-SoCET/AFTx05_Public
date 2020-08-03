
##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################


set sdc_version 1.7

set_units -capacitance 1.0fF
set_units -time 1.0ps

current_design top_level_bASIC

create_clock -name clock1 -add -period 20000.0 -waveform {0.0 10000.0} [get_ports clk]

set_max_capacitance 200 [get_ports *]

set_driving_cell -lib_cell inv_8x -pin X [ all_inputs ]
set_input_delay -add_delay -clock clock1 1000 [all_inputs -no_clocks]
set_output_delay -add_delay -clock clock1 1000 [all_outputs]

#                                           OFFCHIP_SRAM_WRITE CYCLE
#
#                 _______________________________                                  _______________
# CLK    ________/                               \________________________________/
#        __________________ __________________________________________________________________ ___
# ADDR   __________________X__________________________________________________________________X___
#                |---6ns---|-3ns-|---------------------11ns-----------------------|-3ns-|-3ns-|
#        ________________________                                                        _________
# nWE                            \______________________________________________________/
#        _________________________________________________________________________________________
# nOE    ////////////
#                |----------11ns----------|-------------------12ns----------------------|
#        ___________                       ___________________________________________________
# D(W)   ___________>---------------------<___________________________________________________>---
#
#
#                                           OFFCHIP_SRAM_READ CYCLE
#
#                 _______________________________                                  _______________
# CLK    ________/                               \________________________________/
#        __________________ ________________________________________________________________ _____
# ADDR   __________________X________________________________________________________________X_____
#                |---6ns---|--------------------------11ns------------------------|---6ns---|
#        __________________                                                                  _____
# nOE                      \________________________________________________________________/
#                          |-----5ns------|
#        ___________                       ___________________________________________________
# D(R)   ___________>---------------------<___________________________________________________>---
#
#

 # set delays for write enable pins
 # The write enable signal should fall after the address changes, and rise before the address changes
 # Make sure to invert the rules for the inverted signal (used for the bidir pins)
 
 # nWE + WE (to RAM)

set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[0] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[1] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[2] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[3] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[4] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[5] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[6] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[7] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[8] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[9] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[10]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[11]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[12]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[13]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[14]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[15]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[16]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[17]
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_addr[18]
                   
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_nOE

set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[0] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[1] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[2] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[3] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[4] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[5] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[6] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[7] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[8] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[9] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[10] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[11] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[12] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[13] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[14] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[15] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[16] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[17] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[18] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[19] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[20] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[21] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[22] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[23] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[24] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[25] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[26] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[27] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[28] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[29] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[30] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_external_bidir[31] 
                                              
set_max_delay 8000 -rise_from [get_clocks clock1] -fall_to offchip_sramif_nWE_out[0] 
set_max_delay 8000 -rise_from [get_clocks clock1] -fall_to offchip_sramif_nWE_out[1] 
set_max_delay 8000 -rise_from [get_clocks clock1] -fall_to offchip_sramif_nWE_out[2] 
set_max_delay 8000 -rise_from [get_clocks clock1] -fall_to offchip_sramif_nWE_out[3] 
             
set_min_delay 14000 -rise_from [get_clocks clock1] -rise_to offchip_sramif_nWE_out[0] 
set_min_delay 14000 -rise_from [get_clocks clock1] -rise_to offchip_sramif_nWE_out[1] 
set_min_delay 14000 -rise_from [get_clocks clock1] -rise_to offchip_sramif_nWE_out[2] 
set_min_delay 14000 -rise_from [get_clocks clock1] -rise_to offchip_sramif_nWE_out[3] 

set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_WE_out[0] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_WE_out[1] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_WE_out[2] 
set_min_delay 11000 -rise_from [get_clocks clock1] -to offchip_sramif_WE_out[3] 


                                        
                                        


