set PDK_PATH    ../../../MITLL_90_Dec2019/MITLL_PDK
set STDLIB_PATH ../../../MITLL_90_Dec2019/MITLL90_STDLIB_8T/2019.12.20
set IOLIB_PATH ../../../MITLL_90_Dec2019/MITLL90_IOPads_5_1_1/2020.01.27

set designName    top_chip
set init_top_cell top_chip
set init_verilog  prePnR_netlist/top_chip.v
set init_io_file  ./scripts/top_chip.io

set ip_libs [list ]
lappend ip_libs ${STDLIB_PATH}/MITLL90_STDLIB_8T.tt1p2v25c.lib 
lappend ip_libs ${IOLIB_PATH}/MITLL90_IOPads_5_1_1.tt1p2v25c.lib


set cap_table ${PDK_PATH}/MITLL090nm/mitll090nm_T1M5_1_1.capTbl
