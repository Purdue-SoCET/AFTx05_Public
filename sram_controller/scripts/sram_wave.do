onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sram_controller/MEMCTRL/mcif/HCLK
add wave -noupdate /tb_sram_controller/MEMCTRL/mcif/HRESETn
add wave -noupdate -expand -group AHB /tb_sram_controller/MEMCTRL/mcif/HWRITE
add wave -noupdate -expand -group AHB /tb_sram_controller/MEMCTRL/mcif/HREADY
add wave -noupdate -expand -group AHB /tb_sram_controller/MEMCTRL/mcif/HADDR
add wave -noupdate -expand -group AHB /tb_sram_controller/MEMCTRL/mcif/HWDATA
add wave -noupdate -expand -group AHB /tb_sram_controller/MEMCTRL/mcif/HRDATA
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/addr
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/ram_wData
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/ram_rData
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/byte_en
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/sram_en
add wave -noupdate -expand -group RAM /tb_sram_controller/MEMCTRL/mcif/wen
add wave -noupdate /tb_sram_controller/MEMCTRL/mcif/rData
add wave -noupdate -expand -group Latched /tb_sram_controller/MEMCTRL/mcif/latched_data
add wave -noupdate -expand -group Latched /tb_sram_controller/MEMCTRL/mcif/latched_flag
add wave -noupdate -expand -group Latched /tb_sram_controller/MEMCTRL/mcif/latched_size
add wave -noupdate -expand -group Latched /tb_sram_controller/MEMCTRL/mcif/latched_addr
add wave -noupdate /tb_sram_controller/MEMCTRL/encoder/rData_sel
add wave -noupdate /tb_sram_controller/MEMCTRL/encoder/rData_in
add wave -noupdate -expand /tb_sram_controller/MEMCTRL/mcif/ram_rData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 389
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {512696 ps}
