#####################################################################################################################################

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#####################################################################################################################################

set sdc_version 2.0

set_units -capacitance 1.0fF
set_units -time 1.0ps

# Set the current design
current_design top_chip

create_clock -name "clock1" -period 20000.0 -waveform {0.0 10000.0} [get_ports clk_pad]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports nRST_pad]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports clear_pad]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports enable_pad]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {rollover_pad[3]}]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {rollover_pad[2]}]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {rollover_pad[1]}]
set_input_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {rollover_pad[0]}]
set_output_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {count_pad[3]}]
set_output_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {count_pad[2]}]
set_output_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {count_pad[1]}]
set_output_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports {count_pad[0]}]
set_output_delay -clock [get_clocks clock1] -add_delay 1000.0 [get_ports flag_pad]
set_max_fanout 30.000 [get_ports clk_pad]
set_max_fanout 30.000 [get_ports nRST_pad]
set_max_fanout 30.000 [get_ports clear_pad]
set_max_fanout 30.000 [get_ports enable_pad]
set_max_fanout 30.000 [get_ports {rollover_pad[3]}]
set_max_fanout 30.000 [get_ports {rollover_pad[2]}]
set_max_fanout 30.000 [get_ports {rollover_pad[1]}]
set_max_fanout 30.000 [get_ports {rollover_pad[0]}]
set_max_capacitance 200.0 [get_ports clk_pad]
set_max_capacitance 200.0 [get_ports nRST_pad]
set_max_capacitance 200.0 [get_ports clear_pad]
set_max_capacitance 200.0 [get_ports enable_pad]
set_max_capacitance 200.0 [get_ports {rollover_pad[3]}]
set_max_capacitance 200.0 [get_ports {rollover_pad[2]}]
set_max_capacitance 200.0 [get_ports {rollover_pad[1]}]
set_max_capacitance 200.0 [get_ports {rollover_pad[0]}]
set_max_capacitance 200.0 [get_ports {count_pad[3]}]
set_max_capacitance 200.0 [get_ports {count_pad[2]}]
set_max_capacitance 200.0 [get_ports {count_pad[1]}]
set_max_capacitance 200.0 [get_ports {count_pad[0]}]
set_max_capacitance 200.0 [get_ports flag_pad]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports clk_pad]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports nRST_pad]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports clear_pad]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports enable_pad]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports {rollover_pad[3]}]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports {rollover_pad[2]}]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports {rollover_pad[1]}]
set_driving_cell -lib_cell inv_8x -pin "X" [get_ports {rollover_pad[0]}]
