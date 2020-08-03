/*
:set expandtab
:set tabstop=4
:set shiftwidth=4
:retab

*/

`ifndef _AHBL_BUS_MUX_COMMON_VH
`define _AHBL_BUS_MUX_COMMON_VH

interface aphase_c #(parameter DW = 32);

    import ahbl_common::*;

    // Master Signals
    logic      [31:0] HADDR;
    logic      [ 2:0] HBURST;
    logic             HMASTLOCK;
    logic      [ 3:0] HPROT;
    logic      [ 2:0] HSIZE;
    logic      [ 1:0] HTRANS;
    logic             HWRITE;
    logic             HREADY;

    modport in (
    input  HADDR,
    input  HBURST,
    input  HMASTLOCK,
    input  HPROT,
    input  HSIZE,
    input  HTRANS,
    input  HWRITE,
    input  HREADY );

    modport out (
    output HADDR,
    output HBURST,
    output HMASTLOCK,
    output HPROT,
    output HSIZE,
    output HTRANS,
    output HWRITE,
    output HREADY );

endinterface : aphase_c

`endif
