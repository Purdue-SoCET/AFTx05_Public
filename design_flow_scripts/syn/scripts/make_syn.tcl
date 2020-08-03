#############################################
## Written by Jacob Covey - jcovey@purdue.edu
#############################################

#############################################
## How to use...
##
#############################################

#############################################
## Synthesis Flow
## 1. Begin Setup
## 2. ead Target Libraries
## 3. Read HDL
## 4. Set Timing and Design Constraints
## 5. Set Optimization Directives
## 6. Setup DFT Rule Checker
## 7. Synthesize the Design 
## 8. Run DFT Rule Checker 
## 9. Fix DFT Violations
## 10. Add Testability Logic
## 11. Synthesize the Design 
## 12. Analyze Testability
## 13. Set DFT Configuration for Chains
## 14. Connect Scan Chains
## 15. Reporting
#############################################
			

source ./scripts/setup.tcl
if {$env(stage) == "begin"} {
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                            STAGE: BEGIN"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"



set_db information_level 11
set_db lib_search_path $STDLIB_PATH
set_db hdl_undriven_output_port_value 0
set_db use_tiehilo_for_const duplicate

read_mmmc $MMMC_PATH

################################################################
#Create the list of .lef files for all IP needed in this block.
################################################################
set_db / .lef_library $ip_lefs

################################################
#Read in the verilog and elaborate the design
################################################

set_db hdl_search_path { ../../top_level/src/ ../../sram_controller/include/ ../../amba_common/include/ ../../RISCVBusiness/source_code/include/ ../../RISCVBusiness/source_code/packages/ ../../uart_debugger/src/ ../../RISCVBusiness/source_code/standard_core/ ../../RISCVBusiness/source_code/pipelines/tspp/ ../../RISCVBusiness/source_code/branch_predictors/ ../../RISCVBusiness/source_code/privs/ ../../RISCVBusiness/source_code/privs/priv_1_11/ ../../RISCVBusiness/source_code/risc_mgmt/ ../../RISCVBusiness/source_code/risc_mgmt/tspp/ ../../RISCVBusiness/source_code/caches/ ../../RISCVBusiness/source_code/caches/direct_mapped_tpf/ ../../RISCVBusiness/source_code/sparce/ ../../RISCVBusiness/source_code/sparce/sparce_enabled/ ../../RISCVBusiness/source_code/bus_bridges/ ../../uart_debugger/include/ ../../apb/polymorphic_crc/src/ ../../apb/polymorphic_crc/inc/ ../../sram_controller/src/ ../../apb/timer/include/ ../../ahb/apb_bridge/include/ ../../ahb/apb_bridge/src/ ../../apb/gpio/src/ ../../apb/gpio/include/ ../../apb/pwm/source/ ../../apb/timer/src/ ../../RISCVBusiness/source_code/risc_mgmt/extensions/template/ ../../RISCVBusiness/source_code/packages/risc_mgmt/ ../../RISCVBusiness/source_code/branch_predictors/nottaken_predictor/ ../../RISCVBusiness/source_code/risc_mgmt/extensions/crc32/ ../../RISCVBusiness/source_code/caches/pass_through/}  

read_hdl -sv template_pkg.sv crc32_pkg.sv timer_types_pkg.vh POLI_types_pkg.vh alu_types_pkg.sv machine_mode_types_1_11_pkg.sv rv32i_types_pkg.sv ahb_slave.sv sram_ahb_slave.sv encoder.sv memory_control_if.vh decoder.sv flex_counter.sv edge_detector_timer.sv sram_controller.sv clock_divider.sv Timer.sv pwmchannel.sv pwm.sv gpio_if.vh GPIO_SlaveInterface.sv edge_detector.sv Gpio.sv APB_Decoder.sv APB_Bridge.sv ahb2apb.sv APB_SlaveInterface_general.sv APB_SlaveInterface_timer.sv sram_controller_if.vh ahb2apb_if.vh timer_if.vh SOC_RAM.sv SOC_RAM_wrapper.sv SOC_ROM.sv offchip_sram_controller.sv memory_blocks.sv sim_XOR_BUF.sv sim_wrapper_XOR_BUF.sv sim_NAND_NOR.sv sim_wrapper_NAND_NOR.sv crc32.sv crc32_memory.sv crc32_execute.sv crc32_decode.sv control_register.sv apb_slave.sv crc_generator_if.vh poly_crc32.sv control_register_if.vh apb_slave_if.vh POLI_top_level.sv debugger_if.vh uart.sv template_memory.sv template_decode.sv template_execute.sv debugger.sv debugger_top.sv ahb.sv sparce_sasa_table.sv sparce_cfid.sv sparce_psru.sv pass_through_cache.sv sparce_sprf.sv sparce_svc.sv sparce_internal_if.vh sparce_enabled.sv sparce_wrapper.sv memory_controller.sv direct_mapped_tpf_cache.sv separate_caches.sv nottaken_predictor.sv risc_mgmt_macros.vh tspp_risc_mgmt.sv risc_mgmt_wrapper.sv priv_1_11_pipeline_control.sv priv_1_11_control.sv priv_1_11_csr_rfile.sv priv_1_11_internal_if.vh priv_1_11_block.sv priv_wrapper.sv branch_predictor_wrapper.sv tspp_hazard_unit.sv dmem_extender.sv endian_swapper.sv endian_swapper_ram.sv branch_res.sv jump_calc.sv alu.sv rv32i_reg_file.sv control_unit.sv branch_res_if.vh jump_calc_if.vh alu_if.vh rv32i_reg_file_if.vh control_unit_if.vh tspp_execute_stage.sv tspp_fetch_stage.sv tspp_hazard_unit_if.vh tspp_fetch_execute_if.vh sparce_pipeline_if.vh cache_control_if.vh  prv_pipeline_if.vh predictor_pipeline_if.vh component_selection_defines.vh risc_mgmt_if.vh RISCVBusiness.sv AHB_Lite_Mux.v generic_bus_if.vh core_wrapper.sv memory_blocks_if.vh apb_if.vh ahb_if.vh offchip_sram_if.vh top_level_bASIC.sv 

elaborate $DESIGN_NAME
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "End of read_hdl and eleaborate. The design will be checked next."	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
init_design
check_design > ./logs/${DESIGN_NAME}_check_summary.log
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "Resume if check_design shows no issues."
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
#############################################
## 4. Set Timing and Design Constraints
#############################################
## Definition of varaible clock

# Commented this as adding sdc file in mmmc.tcl
#set clock [define_clock -period 100000 -name clock1 [clock_ports]]
## Specifies 50000ps of input delay on all bits of a port relative to clock1	
#external_delay -input 50000 -clock $clock /designs/*/ports_in/* 	
## Specifies 50000ps of output delay on all bits of a port relative to clock1
#external_delay -output 50000 -clock $clock /designs/*/ports_out/*	

#############################################
## 5. Set Optimization Directives
#############################################
##Ties constants to netlist tie high/low cells
add_tieoffs -high tiehi_1x \
   -low tielo_1x -max_fanout 1 \
   -verbose



#############################################
## 6. Setup DFT Rule Checker
#############################################
source $SYN_DIR/scripts/dft.tcl

####################################################################################################
#Create local copies of all HDL files used in this run.
#This ensures that if the source files are modified, these local copies will be preserved.
#hdl_all_filelist is a genus design attribute that includes not just the files but 
#also the compiler directives and directories. Entry 3 in this list _should_ be the verilog files.
#This also creates a paper-trail of where these files were copied from.
####################################################################################################
file mkdir lec/$DESIGN_NAME/golden
set outfile [open "lec/$DESIGN_NAME/golden/$DESIGN_NAME.list" w]
foreach item [lindex [lindex [get_db design:$DESIGN_NAME .hdl_all_filelist] 0] 3] {
    file copy -force $item ./lec/$DESIGN_NAME/golden/
    puts $outfile $item
}
close $outfile

#######################
#Synthesize the design
#######################
set_db / .syn_global_effort high

#############################################
## 7. Synthesize the Design to Generic Logic
#############################################
## Removes don't care logic create by elaborate
synthesize -to_generic
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "The designed has been synthesized to generic. Next the DFT setup will be reported."
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
report dft_setup
## Stores current session which can be reloaded with read_db
write_db $DESIGN_NAME \
	-to_file $OUT_DIR/${DESIGN_NAME}_begin.db 

# End of env(stage) begin
} elseif {$env(stage) == "rule_checker"} {

echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                            STAGE: RULE_CHECKER"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"



read_db $OUT_DIR/${DESIGN_NAME}_begin.db
source $SYN_DIR/scripts/dft.tcl

#############################################
## 10. Add Testability Logic
#############################################

## Stores current session which can be reloaded with read_db
write_db $DESIGN_NAME -to_file $OUT_DIR/${DESIGN_NAME}_rulechecker.db 

} elseif {$env(stage) == "mapped"} {
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                            STAGE: MAPPED"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"

read_db $OUT_DIR/${DESIGN_NAME}_rulechecker.db

source $SYN_DIR/scripts/dft.tcl
echo ""
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "Are there any warnings or errors?"
echo "If no resume else exit."	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"	
set_db / .syn_global_effort medium
synthesize -effort medium -to_mapped
	

# for lec do file and RTL to mapped lec
write_hdl -lec > $OUT_DIR/${DESIGN_NAME}_mapped.v
write_do_lec -revised_design ${OUT_DIR}/${DESIGN_NAME}_mapped.v > $LEC_DIR/${DESIGN_NAME}_lec_rtl2mapped_dofile



set_db / .syn_global_effort high
synthesize -to_mapped -effort high -incremental 

write_db $DESIGN_NAME -to_file $OUT_DIR/${DESIGN_NAME}_mapped.db 

} elseif {$env(stage) == "synthesize"} {
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                            STAGE: SYNTHESIZE"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"



read_db $OUT_DIR/${DESIGN_NAME}_mapped.db
source $SYN_DIR/scripts/dft.tcl

set_db common_ui false
report area  > $RPT_DIR/$DESIGN_NAME.area.rpt
report gates  > $RPT_DIR/$DESIGN_NAME.gates.rpt
report power  > $RPT_DIR/$DESIGN_NAME.power.rpt
report qor  > $RPT_DIR/$DESIGN_NAME.qor.rpt
report summary  > $RPT_DIR/$DESIGN_NAME.summary.rpt

#note: report timing will insert loop breakers back into the design so we do it after writing the rest of the design data.
report timing -lint  > $RPT_DIR/$DESIGN_NAME.timing.lint.rpt
file delete $RPT_DIR/$DESIGN_NAME.timing.rpt
report timing -cost_group clock1  -num_paths 10 >> $RPT_DIR/$DESIGN_NAME.timing.rpt
file delete $RPT_DIR/$DESIGN_NAME.timing.controls.rpt
              
              
              
              
              
############# ##########
#Loop breaker handling
#######################
report cdn_loop_breaker  > $RPT_DIR/$DESIGN_NAME.loops.rpt
remove_cdn_loop_breaker



########################################
#Output verilog and various reports
########################################
## Write HDL and SDC mapped files
write_hdl > $OUT_DIR/$DESIGN_NAME.v
set_attribute common_ui true
write_design -basename $OUT_DIR/$DESIGN_NAME

create_floorplan -height 2500 -width 2500 $DESIGN_NAME; ########  likely will have to edit later in PnR
write_def > $OUT_DIR/$DESIGN_NAME.def
write_spef > $OUT_DIR/$DESIGN_NAME.spef


foreach View $sdc_mode {
write_sdc -view $View > $OUT_DIR/$DESIGN_NAME.sdc_gen
}
write_do_lec -revised_design ${OUT_DIR}/${DESIGN_NAME}.v  > $LEC_DIR/${DESIGN_NAME}_lec_rtl2final_dofile

write_do_lec -golden_design ${OUT_DIR}/${DESIGN_NAME}_mapped.v -revised_design ${OUT_DIR}/${DESIGN_NAME}.v  > $LEC_DIR/${DESIGN_NAME}_lec_mapped2final_dofile


write_dft_abstract_model > $OUT_DIR/$DESIGN_NAME.DFT_Abstract_Model
write_scandef > $OUT_DIR/$DESIGN_NAME.scandef
write_sdf -setuphold split -recrem split  > $OUT_DIR/$DESIGN_NAME.sdf

write_db $DESIGN_NAME -to_file $OUT_DIR/${DESIGN_NAME}_$env(stage).db


echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                           DONE SYNTHESIZING"
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"


 

} elseif {$env(stage) == "ilm_generate"} {

echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"
echo "                            STAGE: ILM_GENERATION"	
echo "----------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------"


read_db $OUT_DIR/${DESIGN_NAME}_synthesize.db

check_design
generate_ilm -preview 
generate_ilm -gzip -basename  $OUT_DIR/${DESIGN_NAME}_ilm/$DESIGN_NAME
}
shell touch ./run/$env(stage)
exit
