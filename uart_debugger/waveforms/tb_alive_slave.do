onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_alive_slave/clk
add wave -noupdate /tb_alive_slave/n_Rst
add wave -noupdate /tb_alive_slave/data
add wave -noupdate /tb_alive_slave/i
add wave -noupdate /tb_alive_slave/rx
add wave -noupdate /tb_alive_slave/tx
add wave -noupdate -radix hexadecimal /tb_alive_slave/debugger_top/transmit/data_in
add wave -noupdate /tb_alive_slave/HREADY
add wave -noupdate -radix hexadecimal /tb_alive_slave/HRDATA
add wave -noupdate /tb_alive_slave/HWRITE
add wave -noupdate /tb_alive_slave/HSIZE
add wave -noupdate /tb_alive_slave/HBURST
add wave -noupdate /tb_alive_slave/HTRANS
add wave -noupdate -radix hexadecimal /tb_alive_slave/HADDR
add wave -noupdate -radix hexadecimal /tb_alive_slave/debugger_top/HADDR
add wave -noupdate -radix hexadecimal /tb_alive_slave/HWDATA
add wave -noupdate /tb_alive_slave/HPROT
add wave -noupdate /tb_alive_slave/HRESP
add wave -noupdate /tb_alive_slave/HSEL
add wave -noupdate /tb_alive_slave/HREADY_in
add wave -noupdate -radix unsigned /tb_alive_slave/ahb_gen_slave/state
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HADDR
add wave -noupdate /tb_alive_slave/ahb_gen_slave/ahb_ready
add wave -noupdate -radix unsigned /tb_alive_slave/ahb_gen_slave/ahb_addr_r
add wave -noupdate -radix unsigned /tb_alive_slave/ahb_gen_slave/ahb_resp
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/ahb_rdata
add wave -noupdate -radix unsigned /tb_alive_slave/ahb_gen_slave/ahb_addr
add wave -noupdate -divider {AHB SLAVE}
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HADDR
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HBURST
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HPROT
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HSIZE
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HTRANS
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HWDATA
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HWRITE
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HRDATA
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HREADY
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HRESP
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HSEL
add wave -noupdate -radix hexadecimal /tb_alive_slave/ahb_gen_slave/HREADY_in
add wave -noupdate -childformat {{{/tb_alive_slave/ahb_gen_slave/mem[7]} -radix hexadecimal} {{/tb_alive_slave/ahb_gen_slave/mem[1]} -radix hexadecimal} {{/tb_alive_slave/ahb_gen_slave/mem[0]} -radix hexadecimal}} -subitemconfig {{/tb_alive_slave/ahb_gen_slave/mem[7]} {-height 16 -radix hexadecimal} {/tb_alive_slave/ahb_gen_slave/mem[1]} {-height 16 -radix hexadecimal} {/tb_alive_slave/ahb_gen_slave/mem[0]} {-height 16 -radix hexadecimal}} /tb_alive_slave/ahb_gen_slave/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24992001100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 124
configure wave -valuecolwidth 171
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {31500 us}
