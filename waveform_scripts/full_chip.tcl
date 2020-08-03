
# NC-Sim Command File
# TOOL:	ncsim(64)	15.20-s030
#
#
# You can restore this configuration with:
#
#      irun -v200x -input ./waveform_scripts/full_chip.tcl -delay_trigger +acc -access +rwc -linedebug /package/asicfab/RAM/cypress_ram_sim/include/package_timing.vhd /package/asicfab/RAM/cypress_ram_sim/include/package_utility.vhd /package/asicfab/RAM/cypress_ram_sim/include/print_str.vhd /local/scratch/a/socet02/SoCET_Public/top_level/tb_top_chip.sv /package/asicfab/MITLL_90_Dec2019/MITLL90_STDLIB_8T/2019.12.20/MITLL90_STDLIB_8T.v /local/scratch/a/socet02/SoCET_Public/fixed_io/MITLL90_IOPads_5_1_1.v /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/dig_poly_NAND_NOR2x_1.sv /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/dig_poly_XOR_BUF2_x1.sv /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/sim_NAND_NOR.sv /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/sim_wrapper_NAND_NOR.sv /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/sim_wrapper_XOR_BUF.sv /local/scratch/a/socet02/SoCET_Public/apb/polymorphic_crc/src/sim_XOR_BUF.sv /local/scratch/a/socet02/SoCET_Public/design_flow_scripts/PnR_x05/PnR_top_chip_4/top_chip.nopower.v /local/scratch/a/socet02/SoCET_Public/sram_controller/src/offchip_sram_simulator.sv /package/asicfab/RAM/cypress_ram_sim/src/cy7c1049bn.vhd -incdir /local/scratch/a/socet02/SoCET_Public/sram_controller/include/ -incdir /package/asicfab/RAM/cypress_ram_sim/include/ -input /local/scratch/a/socet02/SoCET_Public/waveform_scripts/full_chip.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves tb_top_chip.rx_i tb_top_chip.tx_o
probe -create -database waves tb_top_chip.offchip_sramif.sram.external_addr
probe -create -database waves tb_top_chip.offchip_sramif.sram.external_rdata tb_top_chip.offchip_sramif.sram.external_wdata tb_top_chip.offchip_sramif.sram.nCE tb_top_chip.offchip_sramif.sram.nOE tb_top_chip.offchip_sramif.sram.nWE
probe -create -database waves tb_top_chip.cypress_srams.genblk1[0].cypress_ram0:A tb_top_chip.cypress_srams.genblk1[0].cypress_ram0:CE_b tb_top_chip.cypress_srams.genblk1[0].cypress_ram0:OE_b tb_top_chip.cypress_srams.genblk1[0].cypress_ram0:WE_b tb_top_chip.cypress_srams.genblk1[1].cypress_ram0:WE_b tb_top_chip.cypress_srams.genblk1[2].cypress_ram0:WE_b tb_top_chip.cypress_srams.genblk1[3].cypress_ram0:WE_b tb_top_chip.cypress_srams.genblk1[0].cypress_ram0:DQ tb_top_chip.cypress_srams.genblk1[1].cypress_ram0:DQ tb_top_chip.cypress_srams.genblk1[2].cypress_ram0:DQ tb_top_chip.cypress_srams.genblk1[3].cypress_ram0:DQ
probe -create -database waves tb_top_chip.aftx05.asyncrst_n_pad tb_top_chip.aftx05.clk_pad tb_top_chip.aftx05.gpio_pad tb_top_chip.aftx05.mem_data_pad tb_top_chip.aftx05.offchip_sramif_external_addr_pad tb_top_chip.aftx05.tx_pad tb_top_chip.aftx05.rx_pad tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.@{\fetch_ex_if_fetch_ex_reg[pc] } tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.@{\fetch_ex_if_fetch_ex_reg[pc4] } tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.@{\fetch_ex_if_fetch_ex_reg[instr] } tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.cu.cu_if_branch tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.cu.cu_if_jump tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.cu.cu_if_dren tb_top_chip.aftx05.bASIC.corewrap_RISCVBusiness.execute_stage_i.cu.cu_if_dwen
probe -create -database waves tb_top_chip.gpio0_sel_out tb_top_chip.gpio_data
probe -create -database waves tb_top_chip.offchip_sramif_external_bidir

simvision -input ./waveform_scripts/full_chip.tcl.svcf
