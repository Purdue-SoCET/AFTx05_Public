/*
  Vadim Nikiforov, 2019 
  
  Interface to the offchip memory for the SoC 
*/


`ifndef OFFCHIP_SRAM_IF_VH 
`define OFFCHIP_SRAM_IF_VH

interface offchip_sram_if (inout wire [31:0] external_bidir);

  logic nCE;
  logic nOE;
  logic [3:0] nWE;
  logic [3:0] WE;

  logic [3:0][7:0] external_rdata;
  logic [3:0][7:0] external_wdata;
  logic [18:0] external_addr;
  //wire [3:0][7:0] external_bidir;
 

  modport sram  (
    input nCE, nOE, nWE, external_wdata, external_addr,
    output external_rdata,
    inout external_bidir
  );

  modport controller (
    output nCE, nOE, nWE, WE, external_wdata, external_addr,
    input external_rdata,
    inout external_bidir
  );


endinterface

`endif // OFFCHIP_SRAM_VH
