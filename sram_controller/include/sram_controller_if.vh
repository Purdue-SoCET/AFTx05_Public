/*
  John Skubic
  
  Interface for i/o of the sram controller top level
  Includes interface to ram and interface to ahb
*/


`ifndef SRAM_CONTROLLER_IF_VH
`define SRAM_CONTROLLER_IF_VH

interface sram_controller_if ();
  parameter   N_SRAM           = 1;

  logic wen;
  logic [N_SRAM-1:0][31:0] ram_rData;
  logic [31:0] ram_wData, addr;
  logic [3:0] byte_en;
  logic [N_SRAM-1:0] sram_en;

  logic sram_wait;

  modport controller (
    output wen, ram_wData, addr, byte_en, sram_en,
    input ram_rData, sram_wait
  );

  modport sram (
    input wen, ram_wData, addr, byte_en, sram_en,
    output ram_rData, sram_wait
  );

endinterface

`endif //SRAM_CONTROLLER_IF_VH
