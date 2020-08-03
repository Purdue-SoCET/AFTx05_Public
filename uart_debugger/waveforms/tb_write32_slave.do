onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TESTBENCH
add wave -noupdate -radix hexadecimal /tb_write32_slave/clk
add wave -noupdate -radix hexadecimal /tb_write32_slave/n_Rst
add wave -noupdate -radix hexadecimal /tb_write32_slave/data
add wave -noupdate -radix hexadecimal /tb_write32_slave/count
add wave -noupdate -radix hexadecimal /tb_write32_slave/addr
add wave -noupdate -radix hexadecimal /tb_write32_slave/write_data
add wave -noupdate -divider UART
add wave -noupdate -radix hexadecimal /tb_write32_slave/rx
add wave -noupdate -radix hexadecimal /tb_write32_slave/tx
add wave -noupdate -divider DEBUGGER
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/byte_rcv
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/state
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/set_count_state
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/set_addr_state
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/write32_state
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/rcv_x_byte_state
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/crc_reg
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/rcv_x_byte_reg
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/count_reg
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/write_ctr
add wave -noupdate -radix hexadecimal /tb_write32_slave/debugger_top/debugger/addr_reg
add wave -noupdate -divider SLAVE
add wave -noupdate -radix hexadecimal /tb_write32_slave/HREADY
add wave -noupdate -radix hexadecimal /tb_write32_slave/HRDATA
add wave -noupdate -radix hexadecimal /tb_write32_slave/HWRITE
add wave -noupdate -radix hexadecimal /tb_write32_slave/HSIZE
add wave -noupdate -radix hexadecimal /tb_write32_slave/HBURST
add wave -noupdate -radix hexadecimal /tb_write32_slave/HTRANS
add wave -noupdate -radix hexadecimal /tb_write32_slave/HADDR
add wave -noupdate -radix hexadecimal /tb_write32_slave/HWDATA
add wave -noupdate -radix hexadecimal /tb_write32_slave/HPROT
add wave -noupdate -radix hexadecimal /tb_write32_slave/HRESP
add wave -noupdate -radix hexadecimal /tb_write32_slave/HSEL
add wave -noupdate -radix hexadecimal /tb_write32_slave/HREADY_in
add wave -noupdate -radix hexadecimal -childformat {{{/tb_write32_slave/ahb_gen_slave/mem[31]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[30]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[29]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[28]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[27]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[26]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[25]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[24]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[23]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[22]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[21]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[20]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[19]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[18]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[17]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[16]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[15]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[14]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[13]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[12]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[11]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[10]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[9]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[8]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[7]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[6]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[5]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[4]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[3]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[2]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[1]} -radix hexadecimal} {{/tb_write32_slave/ahb_gen_slave/mem[0]} -radix hexadecimal}} -subitemconfig {{/tb_write32_slave/ahb_gen_slave/mem[31]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[30]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[29]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[28]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[27]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[26]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[25]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[24]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[23]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[22]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[21]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[20]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[19]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[18]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[17]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[16]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[15]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[14]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[13]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[12]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[11]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[10]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[9]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[8]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[7]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[6]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[5]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[4]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[3]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[2]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[1]} {-height 16 -radix hexadecimal} {/tb_write32_slave/ahb_gen_slave/mem[0]} {-height 16 -radix hexadecimal}} /tb_write32_slave/ahb_gen_slave/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12366236162 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {26250 us}
