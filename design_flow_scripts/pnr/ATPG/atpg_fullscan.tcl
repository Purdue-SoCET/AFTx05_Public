##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################
-------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# INITIALIZE VARIABLES
#-------------------------------------------------------------------------------
# "set_db workdir" is recommended to be set first to initialize where the Database is to be located
set_db workdir STATIC_WORK_DIR;					# Specify the directory for the ATPG database

set_db stop_on_severity error;				#Stop the flow if any task produces an error

set STDLIB_PATH /package/asicfab/MITLL_90_Dec2019/MITLL90_STDLIB_8T/2019.12.20
set FIXED_IO_PATH ../../../fixed_io
#MIT Library

# For all commands that use this option use this value, unless specified directly on the command line.
set_option stdout all;				# Only print a summary for each command to the terminal
							# Logs contain the complete command output


file delete -force [get_db workdir]/tbdata;		# Delete Test Database
file delete -force [get_db workdir]/testresults;	# Delete Test Output Files/Logs


#-------------------------------------------------------------------------------
# BUILD THE LOGIC MODEL             ../PnR_top_chip_final/top_chip.nopower.v           ../PnR_top_chip_final/top_chip.nopower.LEC.v
#-------------------------------------------------------------------------------
# "-allowmissingmodules yes" allows undefined modules (black boxes) in the model
build_model \
     -cell           top_chip \
     -techlib        ${STDLIB_PATH}/MITLL90_STDLIB_8T.v,MITLL90_STDLIB_8T_defines.v,${FIXED_IO_PATH}/MITLL90_IOPads_5_1_1.v \
     -allowmissingmodules yes \
     -designsource ../PnR_top_chip_final/top_chip.cleaned.v \


#/package/asicfab/MITLL_90_Dec2019/MITLL90_IOPads_5_1_1/2020.01.27/MITLL90_IOPads_5_1_1.v
#-------------------------------------------------------------------------------
# BUILD, REPORT, & VERIFY THE TEST MODEL (CONFIGURATION/SETUP)
#-------------------------------------------------------------------------------
# "-delaymode zero" allows all clocks to be seen at the same time. This is typically desired.
# Some clock shaping networks or adders require unit delay simulation to ouput the correct value.
# Unit delay requires the user to correctly define the unit delay value for each clock tree element to simulate correctly.
build_testmode \
     -testmode   FULLSCAN \
     -modedef    FULLSCAN \
     -assignfile AFTx05.assignfile \
     -delaymode  zero \

#-------------------------------------------------------------------------------
# X sources are useful to check because X's impact test coverage.
verify_test_structures \
     -testmode       FULLSCAN \
     -xclockanalysis yes \
     -testxsource    yes \

#-------------------------------------------------------------------------------
report_test_structures \
     -testmode        FULLSCAN \
     -reportscanchain all \

#-------------------------------------------------------------------------------

#suspend

# "-delaymode zero" allows all clocks to be seen at the same time. This is typically desired.
# Some clock shaping networks or adders require unit delay simulation to ouput the correct value.
# Unit delay requires the user to correctly define the unit delay value for each clock tree element to simulate correctly.
#build_testmode \
#     -testmode   COMPRESSION \
#     -modedef    COMPRESSION \
#     -assignfile [get_db workdir]/../SOURCEFILES/top_level_bASIC.ASSUMED.pinassign \
#     -delaymode  zero \

#-------------------------------------------------------------------------------
# X sources are useful to check because X's impact test coverage.
#verify_test_structures \
#     -testmode       COMPRESSION \
#     -xclockanalysis yes \
#     -testxsource    yes \
#
#-------------------------------------------------------------------------------
#report_test_structures \
#     -testmode        COMPRESSION \
#     -reportscanchain all \

#-------------------------------------------------------------------------------

# "-delaymode zero" allows all clocks to be seen at the same time. This is typically desired.
# Some clock shaping networks or adders require unit delay simulation to ouput the correct value.
# Unit delay requires the user to correctly define the unit delay value for each clock tree element to simulate correctly.
#build_testmode \
#     -testmode   COMPRESSION_DECOMP \
#     -modedef    COMPRESSION_DECOMP \
#     -assignfile [get_db workdir]/../SOURCEFILES/top_level_bASIC.ASSUMED.pinassign \
#     -delaymode  zero \

#-------------------------------------------------------------------------------
# X sources are useful to check because X's impact test coverage.
#verify_test_structures \
#     -testmode       COMPRESSION_DECOMP \
#     -xclockanalysis yes \
#     -testxsource    yes \

#-------------------------------------------------------------------------------
#report_test_structures \
#     -testmode        COMPRESSION_DECOMP \
#     -reportscanchain all \

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# BUILD THE FAULT MODEL
#-------------------------------------------------------------------------------
# Generates default Industry Standard Cell Boundary Fault Model
# Other advanced fault models are available
# Static & Delay faults are included by default.
# If delay defects are not wanted they do not have to be targeted
# To remove delay faults from the model use "-includedynamic no"
build_faultmodel
#-------------------------------------------------------------------------------

# Generate Static ATPG tests and store them in experiment named "logic"
# Scan Chain Tests are automatically run first as part of logic tests if "-append yes" is not specified
create_logic_tests \
     -testmode   FULLSCAN \
     -experiment logic \
     -effort high \
     -maxglobalcoverage 98 \
     -maxcputime 30 \
     -maxelapsedtime 30 \


#-------------------------------------------------------------------------------
# ATPG - TEST GENERATION - IDDq
#-------------------------------------------------------------------------------
# Generate IDDq tests and store them in experiment named "iddq"
# Scan Chain Tests are automatically run first as part of logic tests if "-append yes" is not specified
# or if Scan Chain Test have not been commited to the testmode
create_iddq_tests \
     -testmode   FULLSCAN \
     -experiment iddq \

#-------------------------------------------------------------------------------
# ATPG - TEST GENERATION - SEQUENTIAL
#-------------------------------------------------------------------------------
#
# Generate Sequential ATPG tests and append them in experiment named "logic"
create_sequential_tests \
        -testmode       FULLSCAN \
        -experiment     logic \
        -append         yes\

#-------------------------------------------------------------------------------
# Optional - Save the tests in experiment "logic" to the Master Database
# Beneficial when running multiple ATPG runs or multiple testmodes
commit_tests \
     -testmode     FULLSCAN \
     -inexperiment logic \

#-------------------------------------------------------------------------------
# Optional - Save the tests in experiment "iddq" to the Master Database
# Beneficial when running multiple ATPG runs or multiple testmodes
commit_tests \
     -testmode     FULLSCAN \
     -inexperiment iddq \

write_vectors \
     -testmode   FULLSCAN \
     -language   verilog \
     -scanformat parallel \
     -exportdir  [get_db workdir]/testresults/verilog/FULLSCAN_PARALLEL \
     -logfile    [get_db workdir]/testresults/logs/log_write_vectors_verilog_parallel_FULLSCAN \

#-------------------------------------------------------------------------------
# VERILOG VECTORS - For SERIAL Simulation
#-------------------------------------------------------------------------------
# Serial simulation verifies the entire test process for each test.
# This takes a long time to shift through the entire scan chain for each test.
# Therefore serial simulation for a FULLSCAN testmode is much longer than a Compression testmode.
# Typically only a portion of test are serially simulated.
# In this case "testrange=1:10" specifies the first 10 tests will be written for serial simulation.
#-------------------------------------------------------------------------------
write_vectors \
     -testmode   FULLSCAN \
     -language   verilog \
     -scanformat serial \
     -testrange  1:10 \
     -exportdir  [get_db workdir]/testresults/verilog/FULLSCAN_SERIAL \
     -logfile    [get_db workdir]/testresults/logs/log_write_vectors_verilog_serial_FULLSCAN \

#-------------------------------------------------------------------------------
# STIL VECTORS - For Tester Application
#-------------------------------------------------------------------------------
write_vectors \
     -testmode  FULLSCAN \
     -language  stil \
     -exportdir [get_db workdir]/testresults/stil/FULLSCAN \
     -logfile   [get_db workdir]/testresults/logs/log_write_vectors_stil_FULLSCAN \

