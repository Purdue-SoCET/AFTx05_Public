onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/clk
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/n_Rst
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/debug_rst
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/rx
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/tx
add wave -noupdate -divider {AHB SIGNALS}
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HREADY
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRESP
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWRITE
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HSIZE
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HBURST
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HTRANS
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HADDR
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWDATA
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRDATA
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HPROT
add wave -noupdate -divider FRBM
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HREADY_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRESP_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWRITE_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HSIZE_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HBURST_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HTRANS_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HADDR_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWDATA_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRDATA_M1
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HPROT_M1
add wave -noupdate -divider DEBUGGER
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HREADY_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWRITE_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HSIZE_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HBURST_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HTRANS_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HADDR_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HWDATA_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRDATA_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HPROT_M2
add wave -noupdate -radix hexadecimal /tb_core_wrapper/core_wrapper/HRESP_M2
add wave -noupdate -divider SLAVE
add wave -noupdate -radix hexadecimal -childformat {{{/tb_core_wrapper/ahb_gen_slave/mem[31]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[30]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[29]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[28]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[27]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[26]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[25]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[24]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[23]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[22]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[21]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[20]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[19]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[18]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[17]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[16]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[15]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[14]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[13]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[12]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[11]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[10]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[9]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[8]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[7]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[6]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[5]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[4]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[3]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[2]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[1]} -radix hexadecimal} {{/tb_core_wrapper/ahb_gen_slave/mem[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb_core_wrapper/ahb_gen_slave/mem[31]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[30]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[29]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[28]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[27]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[26]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[25]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[24]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[23]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[22]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[21]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[20]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[19]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[18]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[17]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[16]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[15]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[14]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[13]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[12]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[11]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[10]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[9]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[8]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[7]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[6]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[5]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[4]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[3]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[2]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[1]} {-radix hexadecimal} {/tb_core_wrapper/ahb_gen_slave/mem[0]} {-radix hexadecimal}} /tb_core_wrapper/ahb_gen_slave/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3099630996 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {15697894578 ps} {15698663926 ps}
