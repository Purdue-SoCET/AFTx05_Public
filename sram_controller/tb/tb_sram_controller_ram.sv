// File name:   tb_sram_controller.sv
// Description: Test for SRAM memory controller using the file reading bus master as the AHB master 
// **Note: Run mectrl_testcmds.py to write commands for frbm into ".tic"

`timescale 1ns / 10ps
`include "sram_controller_if.vh"

module tb_sram_controller_ram();

//memory_control_if mcif();

// Define parameters
parameter CLK_PERIOD = 20;
parameter N_SRAM = 1;
parameter INVERT_CE_EN = 0;
parameter INVERT_BYTE_EN = 0;
parameter SRAM_WIDTH = 4;
parameter SRAM_DEPTH = 1024;

//--AHB Bus Signals--//

logic 	HCLK;
logic 	HRESETn;

//unused ahb signals needed for frbm
logic [3:0] HPROT;
logic HLOCK, HBUSREQ;

//-- Sram controller if--//
sram_controller_if #(.N_SRAM(N_SRAM)) sramif();
ahb_if ahbif();

//-------------------------------------------------PORT MAP-----------------------------------------------------------//
ahb_frbm
#(
	.TIC_CMD_FILE("/local/scratch/a/socet02/SoCET_Public/sram_controller/scripts/test.tic")
) ahb_frbm (

	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.HADDR(ahbif.HADDR),
	.HBURST(ahbif.HBURST),
	.HPROT(HPROT),
	.HSIZE(ahbif.HSIZE),
	.HTRANS(ahbif.HTRANS),
	.HWDATA(ahbif.HWDATA),
	.HWRITE(ahbif.HWRITE),
	.HRDATA(ahbif.HRDATA),
	.HREADY(ahbif.HREADY),
	.HRESP(ahbif.HRESP),
	.HBUSREQ(HBUSREQ),
	.HLOCK(HLOCK),
	.HGRANT(1'b1)
);

sram_controller #(.N_SRAM(N_SRAM), .INVERT_CE_EN(INVERT_CE_EN), .INVERT_BYTE_EN(INVERT_BYTE_EN), .SRAM_WIDTH(SRAM_WIDTH), .SRAM_DEPTH(SRAM_DEPTH)) MEMCTRL (
  .HCLK(HCLK), 
  .HRESETn(HRESETn), 
  .ahbif(ahbif),
  .sramif(sramif)  
);

//always high, frbm doesn't have this signal
assign ahbif.HSEL = 1'b1;

/*
ram1 RAM1 (
	.address(sramif.addr[9:0]),
	.byteena(sramif.byte_en),
	.clken(sramif.sram_en),
	.clock(HCLK),
	.data(sramif.ram_wData),
	.wren(sramif.wen),
	.q(sramif.ram_rData[0])
);
*/

onchip_sram onchip_sram(
	.clk(HCLK),
	.sramif(sramif)
);


// Clock Generation
always
begin : CLK_GEN
	HCLK = 1'b0;
	#(CLK_PERIOD / 2);
	HCLK = 1'b1;
	#(CLK_PERIOD / 2);
end

initial begin
  HRESETn = 1'b0;
  @(negedge HCLK);
  HRESETn = 1'b1;
end

endmodule
