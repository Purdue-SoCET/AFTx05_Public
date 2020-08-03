##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################
# SoCET AFTx05 Makefile
# 
# Set tab spacing to 2 spaces per tab for best viewing results
##############################################################################

##############################################################################
# File Related Variables
##############################################################################

SOCROOT := $(shell pwd)
RAMROOT := 


# List internal component/block files here (separate the filenames with spaces)
# (do not include the source folder in the name)
INC_DIRS := $(SOCROOT)/RISCVBusiness/source_code/include/ $(SOCROOT)/RISCVBusiness/source_code/packages/ $(SOCROOT)/RISCVBusiness/source_code/packages/risc_mgmt/  $(SOCROOT)/uart_debugger/include/ $(SOCROOT)/ahb/ahb_interconnect/include/ $(SOCROOT)/ahb/apb_bridge/include/ $(SOCROOT)/amba_common/include/ $(SOCROOT)/apb/gpio/include/ $(SOCROOT)/apb/i2c/include/ $(SOCROOT)/sram_controller/include/ $(SOCROOT)/apb/polymorphic_crc/inc/ $(SOCROOT)/apb/timer/include/

# RISCVBusiness Variables
RISCV := $(SOCROOT)/RISCVBusiness/source_code
RISCV_CORE := $(RISCV)/standard_core
PIPELINE := $(RISCV)/pipelines
RISCV_PKGS := $(RISCV)/packages
RISC_MGMT := $(RISCV)/risc_mgmt
SPARCE := $(RISCV)/sparce
PRIVS := $(RISCV)/privs
BRANCH_PREDICT := $(RISCV)/branch_predictors
CACHES := $(RISCV)/caches
RISCV_BUS := $(RISCV)/bus_bridges
RISC_MGMT_FILES := $(RISC_MGMT)/risc_mgmt_wrapper.sv $(RISC_MGMT)/tspp/tspp_risc_mgmt.sv
RISC_EXT_FILES := $(RISC_MGMT)/extensions/template/template_decode.sv $(RISC_MGMT)/extensions/template/template_execute.sv $(RISC_MGMT)/extensions/template/template_memory.sv
CORE_PKG_FILES := $(RISCV_PKGS)/rv32i_types_pkg.sv $(RISCV_PKGS)/alu_types_pkg.sv $(RISCV_PKGS)/risc_mgmt/template_pkg.sv $(RISCV_PKGS)/risc_mgmt/crc32_pkg.sv $(RISCV_PKGS)/risc_mgmt/rv32m_pkg.sv $(RISCV_PKGS)/risc_mgmt/test_pkg.sv $(RISCV_PKGS)/machine_mode_types_1_11_pkg.sv $(RISCV_PKGS)/machine_mode_types_pkg.sv
CORE_FILES := $(RISCV_CORE)/alu.sv  $(RISCV_CORE)/branch_res.sv  $(RISCV_CORE)/control_unit.sv  $(RISCV_CORE)/dmem_extender.sv  $(RISCV_CORE)/endian_swapper.sv  $(RISCV_CORE)/jump_calc.sv  $(RISCV_CORE)/memory_controller.sv  $(RISCV_CORE)/RISCVBusiness.sv  $(RISCV_CORE)/rv32i_reg_file.sv $(SOCROOT)/top_level/src/core_wrapper.sv
PIPELINE_FILES := $(PIPELINE)/pipeline_wrapper.sv $(PIPELINE)/tspp/tspp_execute_stage.sv  $(PIPELINE)/tspp/tspp_fetch_stage.sv  $(PIPELINE)/tspp/tspp_hazard_unit.sv  $(PIPELINE)/tspp/tspp.sv
SPARCE_FILES := $(SPARCE)/sparce_wrapper.sv $(SPARCE)/sparce_disabled/sparce_disabled.sv $(SPARCE)/sparce_enabled/sparce_cfid.sv  $(SPARCE)/sparce_enabled/sparce_enabled.sv  $(SPARCE)/sparce_enabled/sparce_psru.sv  $(SPARCE)/sparce_enabled/sparce_sasa_table.sv  $(SPARCE)/sparce_enabled/sparce_sprf.sv  $(SPARCE)/sparce_enabled/sparce_svc.sv
PREDICTOR_FILES := $(BRANCH_PREDICT)/branch_predictor_wrapper.sv $(BRANCH_PREDICT)/nottaken_predictor/nottaken_predictor.sv
PRIV_FILES := $(PRIVS)/priv_wrapper.sv  $(PRIVS)/priv_1_11/priv_1_11_block.sv  $(PRIVS)/priv_1_11/priv_1_11_control.sv  $(PRIVS)/priv_1_11/priv_1_11_csr_rfile.sv  $(PRIVS)/priv_1_11/priv_1_11_pipeline_control.sv
CACHE_FILES := $(CACHES)/caches_wrapper.sv $(CACHES)/pass_through/pass_through_cache.sv $(CACHES)/separate_caches.sv
RISCV_BUS_FILES := $(RISCV_BUS)/ahb.sv

#UART Debugger files
DEBUGGER_FILES := $(SOCROOT)/uart_debugger/src/uart.sv $(SOCROOT)/uart_debugger/src/buffer.v $(SOCROOT)/uart_debugger/src/debugger.sv $(SOCROOT)/uart_debugger/src/rcu.v $(SOCROOT)/uart_debugger/src/start_bit_det.v $(SOCROOT)/uart_debugger/src/stop_bit_chk.v $(SOCROOT)/uart_debugger/src/tcu.v $(SOCROOT)/uart_debugger/src/timer.v $(SOCROOT)/uart_debugger/src/transmit.v $(SOCROOT)/uart_debugger/src/debugger_top.sv $(SOCROOT)/uart_debugger/src/AHB_Lite_Mux.v 

# AHB Files
AHB2APB_FILES := $(SOCROOT)/ahb/apb_bridge/src/APB_Bridge.sv  $(SOCROOT)/ahb/apb_bridge/src/APB_Decoder.sv $(SOCROOT)/ahb/apb_bridge/src/ahb2apb.sv  

# Peripheral Files
GPIO_FILES := $(SOCROOT)/apb/gpio/src/GPIO_SlaveInterface.sv $(SOCROOT)/apb/gpio/src/edge_detector.sv $(SOCROOT)/apb/gpio/src/Gpio.sv
POLYMORPHIC_CRC_FILES := $(SOCROOT)/apb/polymorphic_crc/src/apb_slave.sv  $(SOCROOT)/apb/polymorphic_crc/src/control_register.sv  $(SOCROOT)/apb/polymorphic_crc/src/poly_crc32.sv  $(SOCROOT)/apb/polymorphic_crc/src/dig_poly_NAND_NOR2x_1.sv  $(SOCROOT)/apb/polymorphic_crc/src/dig_poly_XOR_BUF2_x1.sv   $(SOCROOT)/apb/polymorphic_crc/src/POLI_top_level.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_NAND_NOR.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_wrapper_NAND_NOR.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_wrapper_XOR_BUF.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_XOR_BUF.sv
POLYMORPHIC_CELLS := $(SOCROOT)/apb/polymorphic_crc/src/dig_poly_NAND_NOR2x_1.sv  $(SOCROOT)/apb/polymorphic_crc/src/dig_poly_XOR_BUF2_x1.sv   $(SOCROOT)/apb/polymorphic_crc/src/sim_NAND_NOR.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_wrapper_NAND_NOR.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_wrapper_XOR_BUF.sv  $(SOCROOT)/apb/polymorphic_crc/src/sim_XOR_BUF.sv
PWM_FILES :=  $(SOCROOT)/apb/pwm/source/APB_SlaveInterface_general.sv  $(SOCROOT)/apb/pwm/source/flex_counter.sv  $(SOCROOT)/apb/pwm/source/pwmchannel.sv  $(SOCROOT)/apb/pwm/source/pwm.sv
TIMER_FILES := $(SOCROOT)/apb/timer/src/APB_SlaveInterface_timer.sv  $(SOCROOT)/apb/timer/src/clock_divider.sv  $(SOCROOT)/apb/timer/src/edge_detector_timer.sv  $(SOCROOT)/apb/timer/src/Timer.sv

# SRAM Files
SRAM_CONTROLLER_FILES := $(SOCROOT)/sram_controller/src/sram_controller.sv $(SOCROOT)/sram_controller/src/ahb_slave.sv $(SOCROOT)/sram_controller/src/encoder.sv $(SOCROOT)/sram_controller/src/decoder.sv $(SOCROOT)/sram_controller/src/sram_ahb_slave.sv $(SOCROOT)/sram_controller/src/SOC_RAM.sv  $(SOCROOT)/sram_controller/src/endian_swapper_ram.sv $(SOCROOT)/sram_controller/src/Memory_RAO.sv $(SOCROOT)/sram_controller/src/memory_blocks.sv $(SOCROOT)/sram_controller/src/offchip_sram_controller.sv $(SOCROOT)/sram_controller/src/offchip_sram_simulator.sv $(SOCROOT)/sram_controller/src/SOC_ROM.sv $(SOCROOT)/sram_controller/src/SOC_RAM_wrapper.sv

# Component File Aggregation (Note, has ram model files removed)
COMPONENT_FILES_V := $(CORE_PKG_FILES) $(SOCROOT)/top_level/src/top_level_bASIC.sv $(RISC_MGMT_FILES) $(RISC_EXT_FILES) $(CORE_FILES) $(PIPELINE_FILES) $(SPARCE_FILES) $(PREDICTOR_FILES) $(PRIV_FILES) $(CACHE_FILES) $(RISCV_BUS_FILES) $(DEBUGGER_FILES) $(AHB2APB_FILES) $(GPIO_FILES) $(SRAM_CONTROLLER_FILES) $(POLYMORPHIC_CRC_FILES) $(PWM_FILES) $(TIMER_FILES) 

MIT_LIB_V := /package/asicfab/MITLL_90_Dec2019/MITLL90_STDLIB_8T/2019.12.20/MITLL90_STDLIB_8T.v # $(SOCROOT)/fixed_io/MITLL90_IOPads_5_1_1.v
NETLIST_FILES_V := $(SOCROOT)/design_flow_scripts/syn/out/top_level_bASIC/top_level_bASIC.v
PNR_FILES_V := $(SOCROOT)/design_flow_scripts/pnr/out/top_chip.cleaned.v
SDF_DIR := $(SOCROOT)/design_flow_scripts/pnr/out/

# Specify the filepath of the test bench you want to use (ie. source/tb_top_level.vhd)
TEST_BENCH	:= tb_top_level_bASIC.sv

# Get the test_bench entity name
TOP_ENTITY	:= $(basename $(TOP_LEVEL_FILE))

#Header Files
HEADER_FILES := -incdir ./src -incdir ./include -incdir $(SOCROOT)/RISCVBusiness/source_code/include/ -incdir $(SOCROOT)/RISCVBusiness/source_code/packages/ -incdir $(SOCROOT)/RISCVBusiness/source_code/packages/risc_mgmt/ -incdir $(SOCROOT)/m0/include/ -incdir $(SOCROOT)/uart_debugger/include/ -incdir $(SOCROOT)/ahb/ahb_interconnect/include/ -incdir $(SOCROOT)/ahb/apb_bridge/include/ -incdir $(SOCROOT)/amba_common/include/ -incdir $(SOCROOT)/apb/gpio/include/ -incdir $(SOCROOT)/apb/i2c/include/ -incdir $(SOCROOT)/sram_controller/include/ -incdir $(SOCROOT)/apb/polymorphic_crc/inc/ -incdir $(SOCROOT)/apb/timer/include/ -incdir $(RAMROOT)/cypress_ram_sim/include/

##############################################################################
# Usage Definition
##############################################################################

define USAGE
@echo "----------------------------------------------------------------"
@echo "Administrative targets:"
@echo "  clean         - removes the temporary files"
@echo	"  print_vars  - prints the contents of the variables"
@echo
@echo "Simulation targets:"
@echo "  source     - compiles and simulates the source version"
@echo "----------------------------------------------------------------"
endef

##############################################################################
# Designate targets that do not correspond directly to files so that they are
# run every time they are called
##############################################################################
.phony: default clean 
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
	@rm -rf INCA_libs/
	@rm -f analyzed/*
	@rm -f schematic/*
	@rm -f *.wlf *.svf transcript
	@rm -f *.tran
	@rm -f *.comp
	@rm -f mmmc.view
	@rm -f *.rpt
	@rm -f *.cmd*
	@rm -f *.log*
	@rm -f *.rpt.old
	@rm -f irun.*
	@rm -f $(TOP_ENTITY).io
	@rm -f $(TOP_ENTITY).checkPlace
	@rm -f $(TOP_ENTITY)*.v
	@rm -rf waves.shm
	@echo -e "Done\n\n"
	
print_vars:
	@echo -e "Component Files: \n $(foreach file, $(COMPONENT_FILES_VHD) $(COMPONENT_FILES_V), $(file)\n)"
	@echo -e "Top level File: $(TOP_LEVEL_FILE)"
	@echo -e "Arch to mapp: $(MAPPED_ARCH)"
	@echo -e "Testbench: $(TEST_BENCH)"


##############################################################################
# Synthesis Target
##############################################################################

sim_source:
	@irun -v200x -gui -input ./waveform_scripts/final_integration.tcl -delay_trigger -access +rwc -linedebug  $(SOCROOT)/top_level/tb/tb_top_level_bASIC.sv $(MIT_LIB_V) $(COMPONENT_FILES_V) $(HEADER_FILES)

sim_mapped:
	@irun -v200x -gui -input gls_test.tcl -delay_trigger +acc -access +rwc -linedebug $(SOCROOT)/top_level/tb/tb_top_level_bASIC_gls.sv $(MIT_LIB_V) $(NETLIST_FILES_V) $(SOCROOT)/sram_controller/src/offchip_sram_simulator.sv -incdir $(SOCROOT)/sram_controller/include/ 

sim_pnr:
	@irun -v200x -gui -input ./waveform_scripts/full_chip.tcl -delay_trigger +acc -access +rwc -linedebug  $(SOCROOT)/top_level/tb/tb_top_chip.sv $(MIT_LIB_V) $(POLYMORPHIC_CELLS) $(PNR_FILES_V) $(SOCROOT)/sram_controller/src/offchip_sram_simulator.sv -incdir $(SOCROOT)/sram_controller/include/ 

sim_pnr_sdf:
	@ncsdfc $(SOCROOT)/design_flow_scripts/PnR_x05/PnR_top_chip_16/top_chip.sdf -output top_chip.sdf.X
	@irun -v200x -gui -input ./waveform_scripts/full_chip.tcl -delay_trigger +acc -access +rwc -sdf_verbose $(SOCROOT)/top_level/tb/tb_top_chip.sv $(MIT_LIB_V) $(POLYMORPHIC_CELLS) $(PNR_FILES_V) $(SOCROOT)/sram_controller/src/offchip_sram_simulator.sv -incdir $(SOCROOT)/sram_controller/include/ 

filelist:
	@echo $(COMPONENT_FILES_V) $(HEADER_FILES) > top_level_BASIC.f
