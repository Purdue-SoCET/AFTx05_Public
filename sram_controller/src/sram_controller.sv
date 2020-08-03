// Top level Memory Controller
`include "memory_control_if.vh"
`include "sram_controller_if.vh"
`include "ahb_if.vh"

module sram_controller (
  input logic HCLK, HRESETn,
  ahb_if.ahb_s ahbif,
  sram_controller_if.controller sramif
);

parameter   N_SRAM            = 1;
parameter   INVERT_CE_EN      = 0;
parameter   INVERT_BYTE_EN    = 0;
parameter   SRAM_WIDTH        = 4;
parameter   SRAM_DEPTH       = 32'h0000_3fff;

memory_control_if #(.N_SRAM(N_SRAM), .INVERT_CE_EN(INVERT_CE_EN), .INVERT_BYTE_EN(INVERT_BYTE_EN), .SRAM_WIDTH(SRAM_WIDTH), .SRAM_DEPTH(SRAM_DEPTH)) mcif ();

encoder #(.N_SRAM(N_SRAM), .INVERT_CE_EN(INVERT_CE_EN)) encoder(mcif);
decoder decoder(mcif);
sram_ahb_slave #(.NUM_BYTES(N_SRAM * SRAM_WIDTH * SRAM_DEPTH)) sram_ahb_slave(mcif);

// input for top level
assign mcif.HCLK = HCLK;
assign mcif.HRESETn = HRESETn;
assign mcif.HWRITE = ahbif.HWRITE;
assign mcif.HSEL = ahbif.HSEL;
assign mcif.HTRANS = ahbif.HTRANS;
assign mcif.HSIZE = ahbif.HSIZE;
assign mcif.HADDR = ahbif.HADDR;
assign mcif.HWDATA = ahbif.HWDATA;
assign mcif.ram_rData = sramif.ram_rData;
assign mcif.sram_wait = sramif.sram_wait;

// output for top level
assign ahbif.HREADYOUT = mcif.HREADY;
assign sramif.wen = mcif.wen;
assign ahbif.HRESP = mcif.HRESP;
assign ahbif.HRDATA = mcif.HRDATA;
assign sramif.ram_wData = mcif.ram_wData;
assign sramif.addr = mcif.ram_addr;
assign sramif.byte_en = mcif.byte_en;
assign sramif.sram_en = mcif.sram_en;

endmodule
