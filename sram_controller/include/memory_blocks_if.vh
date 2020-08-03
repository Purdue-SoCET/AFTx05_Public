/*
  Vadim Nikiforov, 2019 
  
  Interface to different forms of memory found in the SoC
*/


`ifndef MEMORY_BLOCKS_IF_VH
`define MEMORY_BLOCKS_IF_VH

interface memory_blocks_if;

  logic wen;
  logic [31:0] sram_rdata;
  logic [31:0] ram_rdata;
  logic [31:0] rom_rdata;
  logic [31:0] rdata;

  logic [31:0] wdata, addr;
  logic [3:0] byte_en;

  logic sram_wait;
  logic ram_wait;
  logic rom_wait;
  logic mem_wait;

  logic sram_active;
  logic ram_active;
  logic rom_active;


  modport soc_memory (
    output wen, wdata, addr, byte_en, mem_wait,
    input  rdata, sram_rdata, sram_wait, ram_rdata, ram_wait, rom_rdata, rom_wait, sram_active, ram_active, rom_active
  );

  modport sram (
    input wen, wdata, addr, byte_en,
    output sram_rdata, sram_wait, sram_active
  );

  modport ram (
    input wen, wdata, addr, byte_en,
    output ram_rdata, ram_wait, ram_active
  );

  modport rom (
    input addr, byte_en,
    output rom_rdata, rom_wait, rom_active
  );


endinterface

`endif //MEMORY_BLOCKS_IF_VH
