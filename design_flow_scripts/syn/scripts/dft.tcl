##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################



if {$env(stage) == "begin"} {
## Select scan style (muxed_scan | clocked_lssd_scan)	
set_db dft_scan_style muxed_scan	
## Specify the pin used for shift_enable				
define_dft shift_enable -name scan_enable -active high -create_port scan_en 
## Specify the pin used for test mode	
## The test mode pin controls weather the device is used functionally or for test
## This can mean it controls if PIs are for scan or function
## It also can be used to control challenging circuitry		
define_dft test_mode -name test_signal -active high -create_port test_sig 
## Define the full scan test clock
#define_dft test_clock -period 100000 -name clk2 busclk JOHN CHANGED FOR HANDLER

define_dft test_clock -period 20000 -name clk2 clk; #-domain ai_mclk -controllable
#define_dft test_clock -period 100000 -name clk2 busclk -domain busclk -controllable



		
} elseif {$env(stage) == "rule_checker"} {
#############################################
## 8. Run DFT Rule Checker 
#############################################
## Identify uncontrollable clocks or asnychonous set/reset pins

set_db [vfind -hinst *Poli*] .dft_dont_scan true
check_dft_rules	> $OUT_DIR/logs/dft/$DESIGN_NAME.dft_rules.rpt	
## Report scanable status of flip-flops in design
report dft_registers > $OUT_DIR/logs/dft/$DESIGN_NAME.dft_registers.rpt	
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"				
echo "Review violations prior to continuing to Fix DFT Violations"
echo "Add to fix_dft_violations as needed."
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"


#############################################
## 9. Fix DFT Violations
#############################################
## Fixes violations reported in check_dft_rules - add more features as needed						
fix_dft_violations \
	-test_control test_signal \
	-async_reset \
	-clock \
	-scan_clock_pin clk \
	-async_set	
## Check if there are still violations								
#define_dft test_mode -name test_signal -active high -create_port test_sig 
#fix_dft_violations -clock -test_control test_signal -scan_clock_pin ai_mclk

# Just an example from cadence support
#define_test_mode -name tm -active high TM
#fix_dft_violations -clock -test_control tm -scan_clock_pin tclk 

report dft_violations >$OUT_DIR/logs/dft/$DESIGN_NAME.dft_violations.rpt					



echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "Are the violations gone?"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"					
#suspend

} elseif {$env(stage) == "mapped"} {
#############################################
## 11. Synthesize the Design 
#############################################
## Specify the scan-FF output pin {auto | non_inverted | inverted}
#Commented as not supported in genus
set_db common_ui false
set_attribute dft_scan_output_preference non_inverted $DESIGN_NAME  			
## Control the mapping of FFs to scan-FFs {tdrc_pass | force _all | preserve}
set_attribute dft_scan_map_mode tdrc_pass $DESIGN_NAME 				
## Specify scan data pins for mapping {floating | ground} default is loopback
#set_attr dft_connect_scan_data_pins_during_mapping		
## Specify shift enable pins for mapping {floating | ground} default is tieoff
#set_attr dft_connect_shift_enable_pins_during_mapping ##needs info	
#define_dft shift_register_segment ##needs info
set_attribute common_ui true
} elseif {$env(stage) == "synthesize"} {
#############################################
## 12. Analyze Testability 
#############################################
#analyze_testability

#############################################
## 13. Set DFT Configuration for Chains
#############################################
## Set the minimum number of scan chains 
set_db common_ui false
set_attribute dft_min_number_of_scan_chains 1 $DESIGN_NAME
set_attribute dft_max_length_of_scan_chains 20000 $DESIGN_NAME
## Create a prefix for scan ports and chains made by the RC-DFT engine
set_attribute dft_prefix DFT_
## Define top level scan chain

#for {set id 0} {$id < 8954} {incr $id} {

define_dft scan_chain -name scanchain_1 -create_ports -sdi scan_in_1 -sdo scan_out_1
set_attribute common_ui true

#}
## Preview the scan chain before it is created
#set_db dft_max_length_of_scan_chains 431 $DESIGN_NAME
connect_scan_chains -preview -auto_create_chains -pack
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "Is the reported scan chain acceptable?"
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"					
#suspend

#############################################
## 14. Connect Scan Chains
#############################################
##Connect the scan chains
connect_scan_chains -auto_create_chains
check_dft_rules > $OUT_DIR/logs/dft_violations_connect.rpt
report dft_chains > $RPT_DIR/$DESIGN_NAME.scan_chains.rpt
report dft_setup > $RPT_DIR/$DESIGN_NAME.dft_setup.rpt

}
