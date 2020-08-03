/*	
  John Skubic

  Internal interface for the sram controller module
  This sets up connections between the encoder, decoder, and ahb slave modules	
*/

`ifndef MEMORY_CONTROLLER_IF_VH
`define MEMORY_CONTROLLER_IF_VH

interface memory_control_if();

parameter N_SRAM = 2;
parameter INVERT_CE_EN = 0;
parameter INVERT_BYTE_EN = 0;
parameter SRAM_WIDTH = 4;
parameter SRAM_DEPTH = 1024;

//AHB signals
logic HCLK, HRESETn, HWRITE, HSEL, HREADY, HRESP;
logic [1:0] HTRANS;
logic [2:0] HSIZE;
logic [31:0] HADDR, HWDATA, HRDATA;

//SRAM
logic [31:0] ram_wData;
logic [N_SRAM - 1 : 0] [31 : 0] ram_rData;
logic [3 : 0] byte_en;
logic [N_SRAM - 1 : 0] sram_en;
logic wen;
logic [31:0] ram_addr;
logic sram_wait;

//decode
logic [31:0] addr;
logic [1:0] size, latched_size, read_size; //0 -> 1byte, 1 -> 2 byte, 2 -> 4 byte

//encoder
logic [31:0] rData, latched_data, latched_addr;
logic [3:0] latched_byte_en;
logic latched_flag;
logic [31:0] read_addr;

//Memory Rom and Ram
logic [31:0] RAO_w_data,RAO_r_data,RAO_RAM_val;
logic [11:0] RAO_addr,RAO_RAM_addr;
logic RAO_w_en;



modport ahb_slave(
	input HCLK, HRESETn, HWRITE, HSEL, HTRANS, HSIZE, HADDR, HWDATA, rData, sram_wait,
	output HREADY, HRDATA, HRESP, size, wen, ram_wData, addr, ram_addr, latched_data, latched_addr, latched_flag, latched_size,
	read_addr, read_size
);

modport decoder(
	input size, addr, latched_size, latched_addr,
	output byte_en, sram_en, latched_byte_en
);

modport encoder(
	input size, sram_en, byte_en, ram_rData, latched_byte_en, latched_data, latched_flag, latched_addr, ram_addr, read_addr, read_size,
	output rData
);

modport tb(
	output HCLK, HRESETn, HWRITE, HSEL, HTRANS, HSIZE, HADDR, HWDATA, 
	input HREADY, HRDATA, HRESP 
);


endinterface

`endif //MEMORY_CONTROLLER_IF_VH
