##############################################################################
# ECE 337 General Makefile
# 
# Set tab spacing to 2 spaces per tab for best viewing results
##############################################################################

##############################################################################
# File Related Variables
##############################################################################

# List internal component/block files here (separate the filenames with spaces)
# (do not include the source folder in the name)
COMPONENT_FILES_V := buffer.v debugger.v rcu.v start_bit_det.v stop_bit_chk.v tcu.v timer.v transmit.v debugger_top.v AHB_Lite_Mux.v

# Specify the name of the top level file (do not include the source folder in the name)
TOP_LEVEL_FILE	    := core_wrapper.v

AHB_FILE 	    := ../ahb/frbm/src/ahb_frbm.sv ../ahb/slave/src/ahb_gen_slave.sv

# Extract and use the first architecture name in the top level file for synthesis
MAPPED_ARCH := $(word 2,$(shell grep -i -m 1 -s '^[[:space:]]*architecture' source/$(TOP_LEVEL_FILE)))

# Specify the filepath of the test bench you want to use (ie. source/tb_top_level.vhd)
TEST_BENCH	:= tb_core_wrapper.sv

# Get the test_bench entity name
TB_ENTITY		:= $(notdir $(basename $(TEST_BENCH)))
TOP_ENTITY	:= $(basename $(TOP_LEVEL_FILE))

# Standard Cell Libraries
OSU_STD_CELL := osu05_stdcells.v

# SRAM Module
SRAM := SRAM.vhd

# Automatically handle runing on the grid
ifeq ($(shell hostname),ecegrid-lnx.ecn.purdue.edu)
LIB_CREATE	:= grid vlib
COMPILE_VHD 		:= grid vcom +acc
COMPILE_V 		:= grid vlog +acc
SIMULATE		:= grid vsim
DC_SHELL		:= grid dc_shell-t
MODEL_SCR               := do
else
LIB_CREATE	:= vlib
COMPILE_VHD 		:= vcom +acc
COMPILE_V 		:= vlog +acc
SIMULATE		:= vsim
DC_SHELL		:= dc_shell-t
MODEL_SCR               := do
endif


##############################################################################
# Usage Definition
##############################################################################

define USAGE
@echo "----------------------------------------------------------------"
@echo "Administrative targets:"
@echo "  clean         - removes the temporary files"
@echo	"  veryclean   - removes the mapped files as well"
@echo	"  print_vars  - prints the contents of the variables"
@echo
@echo "DO Scripts (Run in Modelsim):"
@echo "  do wave_top.do     - display signals in Modelsim"
@echo 
@echo "Compilation targets:"
@echo "  comp_source     - compiles the source version"
@echo "  comp_mapped     - compiles the mapped TI version"
@echo 
@echo "Simulation targets:"
@echo "  sim_source     - compiles and simulates the source version"
@echo "  sim_mapped_osu - compiles and simulates the mapped OSU version"
@echo "  sim_mapped_ti  - compiles and simulates the mapped TI version"
@echo 
@echo "Synthesis targets:"
@echo "  syn_mapped   - synthesizes the mapped version using TI Cells"
@echo "----------------------------------------------------------------"
endef

##############################################################################
# Designate targets that do not correspond directly to files so that they are
# run every time they are called
##############################################################################
.phony: default clean veryclean
.phony: sim_source sim_mapped_ti sim_mapped_osu
.phony: syn_mapped

##############################################################################
# Make the default target (the one called when no specific one is invoked) to
# output the proper usage of this makefile
##############################################################################
default:
	$(USAGE)

##############################################################################
# Administrative Targets
##############################################################################

clean:
	@echo -e "Removing temporary files"
	@rm -rf source_work mapped_work
	@rm -rf analyzed/ARCH analyzed/ENTI
	@rm -f analyzed/*
	@rm -f schematic/*
	@rm -f *.wlf *.svf transcript
	@rm -f *.tran
	@rm -f *.comp
	@echo -e "Done\n\n"
	
veryclean:
	@$(MAKE) --no-print-directory clean
	@echo -e "Removing synthesized files, synthesis logs, and synthesis reports"
	@rm -f mapped/*
	@rm -f reports/*
	@rm -f *.log
	@echo -e "Done\n\n"

print_vars:
	@echo -e "Component Files: \n $(foreach file, $(COMPONENT_FILES_VHD) $(COMPONENT_FILES_V), $(file)\n)"
	@echo -e "Top level File: $(TOP_LEVEL_FILE)"
	@echo -e "Arch to mapp: $(MAPPED_ARCH)"
	@echo -e "Testbench: $(TEST_BENCH)"

##############################################################################
# Compilation Targets
##############################################################################

comp_source:
	@rm -rf source_work
	@$(LIB_CREATE) source_work
	
	@echo -e "Compiling: \n $(foreach file, $(COMPONENT_FILES_VHD) $(COMPONENT_FILES_V) $(TOP_LEVEL_FILE), $(file)\n)"
	@$(COMPILE_VHD) -work source_work $(addprefix source/, $(COMPONENT_FILES_VHD)) > source.comp
	@$(COMPILE_V) -work source_work $(addprefix source/, $(COMPONENT_FILES_V)) > source.comp
	@$(COMPILE_V) -work source_work $(addprefix source/, $(TOP_LEVEL_FILE)) >> source.comp

comp_mapped:
	@rm -rf mapped_work
	@$(LIB_CREATE) mapped_work

	@echo -e "Compiling Mapped design"
	@$(COMPILE_V) -work mapped_work $(addprefix mapped/, $(TOP_LEVEL_FILE)) > mapped.comp
	@$(COMPILE_VHD) -work mapped_work $(addprefix source/, $(SRAM)) > mapped.comp
	
##############################################################################
# Simulation Targets
##############################################################################

define CONSOLE_SIM_CMDS
"run 15 us;	\
 quit -f"
endef

sim_source:
	@rm -rf source_work
	@$(LIB_CREATE) source_work
	
	@echo -e "Compiling: \n $(foreach file, $(COMPONENT_FILES_VHD) $(COMPONENT_FILES_V) $(TOP_LEVEL_FILE) $(TEST_BENCH), $(file)\n)"
	@$(COMPILE_VHD) -work source_work $(addprefix source/, $(COMPONENT_FILES_VHD)) > source.comp
	@$(COMPILE_V) -work source_work $(AHB_FILE) > source.comp
	@$(COMPILE_V) -work source_work $(addprefix source/, $(COMPONENT_FILES_V)) > source.comp
	@$(COMPILE_V) -work source_work $(addprefix source/, $(TOP_LEVEL_FILE)) >> source.comp
	@$(COMPILE_V) -work source_work $(addprefix source/, $(TEST_BENCH)) >> source.comp
	@$(COMPILE_VHD) -work source_work source/goldFifo.vhd > source.comp

	@echo -e "Simulating Source Design"
# Uncomment below if you want to just run the simulation as a console command
# using the commands listed in the CONSOLE_SIM_CMDS definition above instead of 
# .do file and have the transcript contents to be saved to a file
#	@$(SIMULATE) -c -t ps -do $(CONSOLE_SIM_CMDS) source_work.$(TB_ENTITY) > source.tran

# Uncomment below if you want run the simulation the normal way and have it
# run the specified .do file
#	@$(SIMULATE) -t ps -do s_waves.do source_work.$(TB_ENTITY)

# This way just runs it like normal and only sets up the simulation but doesn't
# run it or add any waveforms
	@$(SIMULATE) -i -t ps source_work.$(TB_ENTITY)

	@echo -e "Done simulating the source design\n\n"
	
sim_mapped_osu: mapped/$(TOP_LEVEL_FILE)
	@rm -rf mapped_work
	@$(LIB_CREATE) mapped_work

	@echo -e "Compiling Mapped design and the test bench"
	@$(COMPILE_V) -work mapped_work $(AHB_FILE) > mapped.comp
	#@$(COMPILE_V) -work mapped_work $(addprefix mapped/, $(OSU_STD_CELL)) > mapped.comp
	@$(COMPILE_V) -work mapped_work $(addprefix mapped/, $(TOP_LEVEL_FILE)) > mapped.comp
	#@$(COMPILE_VHD) -work mapped_work $(addprefix source/, $(SRAM)) > mapped.comp
	@$(COMPILE_V) -work mapped_work $(addprefix source/, $(TEST_BENCH)) >> mapped.comp

	@echo -e "Simulating Mapped Design"
	@$(SIMULATE) -i -t ps mapped_work.$(TB_ENTITY)

	@echo -e "Done simulating the mapped design\n\n"

sim_mapped_ti: mapped/$(TOP_LEVEL_FILE)
	@rm -rf mapped_work
	@$(LIB_CREATE) mapped_work

	@echo -e "Compiling Mapped design and the test bench"
	@$(COMPILE_V) -work mapped_work $(addprefix mapped/, $(TOP_LEVEL_FILE)) > mapped.comp
	@$(COMPILE_VHD) -work mapped_work $(addprefix source/, $(SRAM)) > mapped.comp
	@$(COMPILE_V) -work mapped_work $(addprefix source/, $(TEST_BENCH)) >> mapped.comp

	@echo -e "Simulating Mapped Design"
	@$(SIMULATE) -i -t ps mapped_work.$(TB_ENTITY)

	@echo -e "Done simulating the mapped design\n\n"

##############################################################################
# Define the synthesis commands to use
##############################################################################
	
define SYN_CMDS
'# Step 1:  Read in the source file                                                     \n\
analyze -format vhdl -lib WORK {$(COMPONENT_FILES_VHD)} \n\
analyze -format verilog -lib WORK {$(COMPONENT_FILES_V) $(TOP_LEVEL_FILE)}                   \n\
elaborate $(TOP_ENTITY) -arch "$(MAPPED_ARCH)" -lib WORK -update                        \n\
                                                                                        \n\
uniquify                                                                                \n\
# Step 2: Set design constraints                                                        \n\
# Uncomment below to set timing, area, power, etc. constraints                          \n\
# set_max_delay <delay> -from "<input>" -to "<output>"                                  \n\
# set_max_area 800000                                                                   \n\
# set_max_total_power <power> mW                                                        \n\
                                                                                        \n\
# Step 3: Compile the design                                                            \n\
compile -map_effort high                                                              \n\
                                                                                        \n\
# Step 4: Output reports                                                                \n\
report_timing -path full -delay max -max_paths 1 -nworst 1 > reports/$(TOP_ENTITY).rep  \n\
report_area >> reports/$(TOP_ENTITY).rep                                                \n\
report_power -hier >> reports/$(TOP_ENTITY).rep                                         \n\
                                                                                        \n\
# Step 5: Output final VHDL and Verilog files                                           \n\
write -format vhdl -hierarchy -output "mapped/$(TOP_ENTITY).vhd"                        \n\
write -format verilog -hierarchy -output "mapped/$(TOP_ENTITY).v"                       \n\
echo "\\nScript Done\\n"                                                                \n\
echo "\\nChecking Design\\n"                                                            \n\
check_design                                                                            \n\
exit'
endef

##############################################################################
# Synthesis Target
##############################################################################

mapped/$(TOP_LEVEL_FILE):
	@$(MAKE) --no-print-directory syn_mapped MAPPED_ARCH='$(MAPPED_ARCH)' TOP_LEVEL_FILE='$(TOP_LEVEL_FILE)' COMPONENT_FILES='$(COMPONENT_FILES_V) $(COMPONENT_FILES_VHD)'

syn_mapped:
	@echo -e "Synthesizing design: $(TOP_LEVEL_FILE)($(MAPPED_ARCH))"
	@echo -e $(SYN_CMDS) | $(DC_SHELL) > syn_mapped.log
	@echo -e "Done\n\n"
