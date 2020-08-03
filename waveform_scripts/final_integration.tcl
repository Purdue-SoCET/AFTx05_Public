
# NC-Sim Command File
# TOOL:	ncsim(64)	15.20-s030
#
#
# You can restore this configuration with:
#
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
probe -create -database waves tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.if_ex_enable tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.pc tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.rd tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.rdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.sasa_addr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.sasa_data tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.sasa_wen tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.skipping tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.sparce_target tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.wb_data tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.sparce_if.pipeline.wb_en
probe -create -database waves tb_top_level_bASIC.rx_i tb_top_level_bASIC.tx_o
probe -create -database waves tb_top_level_bASIC.bASIC.gpioIf0.en_data tb_top_level_bASIC.bASIC.gpioIf0.r_data
probe -create -database waves tb_top_level_bASIC.offchip_sramif.sram.external_addr
probe -create -database waves tb_top_level_bASIC.bASIC.blkif.soc_memory.sram_active tb_top_level_bASIC.bASIC.blkif.soc_memory.rom_active tb_top_level_bASIC.bASIC.blkif.soc_memory.ram_active
probe -create -database waves tb_top_level_bASIC.bASIC.RAM.TOPRAM.RAM tb_top_level_bASIC.bASIC.RAM.TOPRAM.addr tb_top_level_bASIC.bASIC.RAM.TOPRAM.byte_en tb_top_level_bASIC.bASIC.RAM.TOPRAM.w_en tb_top_level_bASIC.bASIC.RAM.TOPRAM.r_data tb_top_level_bASIC.bASIC.RAM.TOPRAM.w_data
probe -create -database waves tb_top_level_bASIC.bASIC.corewrap.debugger_top.debugger.state tb_top_level_bASIC.bASIC.corewrap.debugger_top.debugger.alive_state tb_top_level_bASIC.bASIC.corewrap.debugger_top.debugger.crc_reg tb_top_level_bASIC.bASIC.corewrap.debugger_top.debugger.data_in tb_top_level_bASIC.bASIC.corewrap.debugger_top.debugger.data_send
probe -create -database waves tb_top_level_bASIC.bASIC.gpioIf0.w_data tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.priv_wrapper_i.priv_block_i.prv_control_i.nRST tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.priv_wrapper_i.priv_block_i.prv_control_i.CLK tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.priv_wrapper_i.priv_block_i.prv_control_i.exception tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.priv_wrapper_i.priv_block_i.prv_control_i.ex_src tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.tspp_dcache_gen_bus_if.addr[1:0] tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.mc.current_state tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.mc.next_state tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.mc.rdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.mc.wdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.addr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.busy tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.byte_en tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.rdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.ren tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.wdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.dcache_mc_if.generic_bus.wen tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.addr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.busy tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.byte_en tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.rdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.ren tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.wdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.icache_mc_if.generic_bus.wen tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.addr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.busy tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.byte_en tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.rdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.ren tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.wdata tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.pipeline_trans_if.cpu.wen tb_top_level_bASIC.bASIC.sram_controller.sram_ahb_slave.AHBS0.next tb_top_level_bASIC.bASIC.sram_controller.sram_ahb_slave.AHBS0.current tb_top_level_bASIC.bASIC.sramIf_ahbif.HADDR tb_top_level_bASIC.bASIC.sramIf_ahbif.HRDATA tb_top_level_bASIC.bASIC.sramIf_ahbif.HWDATA tb_top_level_bASIC.bASIC.sramIf_ahbif.HWRITE tb_top_level_bASIC.bASIC.sramIf_ahbif.HTRANS tb_top_level_bASIC.bASIC.sramIf_ahbif.HSIZE tb_top_level_bASIC.bASIC.sramIf_ahbif.HSEL tb_top_level_bASIC.bASIC.sramIf_ahbif.HRESP tb_top_level_bASIC.bASIC.sramIf_ahbif.HREADYOUT tb_top_level_bASIC.bASIC.sramIf_ahbif.HREADY tb_top_level_bASIC.bASIC.sram_controller.mcif.encoder.byte_en tb_top_level_bASIC.bASIC.sram_controller.mcif.encoder.sram_en tb_top_level_bASIC.bASIC.sram_controller.mcif.encoder.latched_flag tb_top_level_bASIC.bASIC.sram_controller.encoder.rData_in tb_top_level_bASIC.bASIC.sram_controller.mcif.encoder.ram_rData tb_top_level_bASIC.bASIC.sram_controller.mcif.encoder.rData tb_top_level_bASIC.bASIC.sram_controller.mcif.ahb_slave.HRDATA tb_top_level_bASIC.bASIC.sram_controller.mcif.ahb_slave.rData tb_top_level_bASIC.bASIC.sramIf.controller.addr tb_top_level_bASIC.bASIC.sramIf.controller.byte_en tb_top_level_bASIC.bASIC.sramIf.controller.ram_rData tb_top_level_bASIC.bASIC.sramIf.controller.ram_wData tb_top_level_bASIC.bASIC.sramIf.controller.sram_en tb_top_level_bASIC.bASIC.sramIf.controller.sram_wait tb_top_level_bASIC.bASIC.sramIf.controller.wen tb_top_level_bASIC.bASIC.blkif.sram.addr tb_top_level_bASIC.bASIC.blkif.sram.byte_en tb_top_level_bASIC.bASIC.blkif.sram.sram_active tb_top_level_bASIC.bASIC.blkif.sram.sram_rdata tb_top_level_bASIC.bASIC.blkif.sram.sram_wait tb_top_level_bASIC.bASIC.blkif.sram.wdata tb_top_level_bASIC.bASIC.blkif.sram.wen tb_top_level_bASIC.offchip_sramif.controller.external_rdata tb_top_level_bASIC.offchip_sramif.controller.external_wdata tb_top_level_bASIC.offchip_sramif.controller.nCE tb_top_level_bASIC.offchip_sramif.controller.nOE tb_top_level_bASIC.offchip_sramif.controller.nWE tb_top_level_bASIC.bASIC.offchip_sram.active
probe -create -database waves tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.fetch_stage_i.instr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.fetch_stage_i.pc tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.instr tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.opcode tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.load_type tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.alu_op tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.jump tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.branch tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.branch_type tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.dren tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.cu_if.control_unit.dwen tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.execute_stage_i.rf.registers tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.hazard_if.mal_insn tb_top_level_bASIC.bASIC.corewrap.RISCVBusiness.hazard_if.illegal_insn
probe -create -database waves tb_top_level_bASIC.cypress_srams.genblk1[0].cypress_ram0:A tb_top_level_bASIC.cypress_srams.genblk1[0].cypress_ram0:CE_b tb_top_level_bASIC.cypress_srams.genblk1[0].cypress_ram0:OE_b tb_top_level_bASIC.cypress_srams.genblk1[0].cypress_ram0:WE_b tb_top_level_bASIC.cypress_srams.genblk1[0].cypress_ram0:DQ tb_top_level_bASIC.cypress_srams.genblk1[1].cypress_ram0:DQ tb_top_level_bASIC.cypress_srams.genblk1[2].cypress_ram0:DQ tb_top_level_bASIC.cypress_srams.genblk1[3].cypress_ram0:DQ
probe -create -database waves tb_top_level_bASIC.cypress_srams.genblk1[1].cypress_ram0:WE_b tb_top_level_bASIC.cypress_srams.genblk1[2].cypress_ram0:WE_b tb_top_level_bASIC.cypress_srams.genblk1[3].cypress_ram0:WE_b
probe -create -database waves tb_top_level_bASIC.offchip_sramif.controller.external_bidir

simvision -input ./waveform_scripts/final_integration.tcl.svcf
