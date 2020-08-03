onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HCLK
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HRESETn
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/HADDR
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/HRDATA
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HREADY
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HRESP
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HSEL
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HSIZE
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HTRANS
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/HWDATA
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/HWRITE
add wave -noupdate -divider RAM
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/addr
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/byte_en
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/ram_rData
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/ram_wData
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/sram_en
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/wen
add wave -noupdate -divider encoder
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/encoder/rData_in
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/rData
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/ram_addr
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/encoder/bit_mask
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/latched_byte_en
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/sram_ahb_slave/latched_addr
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/sram_ahb_slave/latched_data
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/sram_ahb_slave/latched_flag
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/sram_ahb_slave/latched_size
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/size
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/encoder/byte_sel
add wave -noupdate -radix hexadecimal /tb_sram_controller_ram/MEMCTRL/mcif/read_addr
add wave -noupdate /tb_sram_controller_ram/MEMCTRL/mcif/read_size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138571 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 175
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {262408 ps}
