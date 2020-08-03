
##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################


set DESIGN_NAME top_level_bASIC
set SYN_DIR ./
set PDK_PATH ../../../MITLL_90_Dec2019/MITLL_PDK
set STDLIB_PATH ../../../MITLL_90_Dec2019/MITLL90_STDLIB_8T/2019.12.20
set MMMC_PATH $SYN_DIR/scripts/mmmc.tcl
set SDC_PATH $SYN_DIR/scripts
set OUT_DIR $SYN_DIR/out/$DESIGN_NAME
set LEC_DIR $SYN_DIR/lec/$DESIGN_NAME
set RPT_DIR $SYN_DIR/out/$DESIGN_NAME/reports
set PNR_DIR $SYN_DIR/out/$DESIGN_NAME/pnr
set sdc_mode tt1p2v25c
set SYN_NETLIST $OUT_DIR/$DESIGN_NAME.v
# LEF path for additional LEFS provided for PnR
set LEF_PATH $SYN_DIR/LEF
set time_unit {1ps}
set process {90}
set cap_unit {1ff}
set min_route_layer {1}
set max_route_layer {5}
set CLK {clk}
# Same as in MMMC file
###################################################
#Track all the hard macro IPs in use in this block
#Initialize the list with IP defined for this step.
###################################################
set ip_list [ list \
MITLL90_STDLIB_8T]

