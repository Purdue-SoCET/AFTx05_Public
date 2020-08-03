// File name:   ahb2apb.sv
// Created:     6/18/2014
// Author:      Xin Tze Tee
// Version:     1.0 
// Description: AHB to APB Bridge wrapper that contains 
//              FSM and Address Decoder.


//Interfaces
`include "ahb2apb_if.vh"
`include "ahb_if.vh"
`include "apb_if.vh"


module ahb2apb
(
	input logic clk, n_rst,
	
	ahb_if.ahb_s ahbif,
	apb_if.apb_m apbif,
	ahb2apb_if.slave_decode slaveif
);

parameter NUM_SLAVES = 2;

wire [31:0] PRDATA_PSlave;

APB_Bridge APB_Bridge
(
	.clk(clk), .n_rst(n_rst),
	.HTRANS(ahbif.HTRANS),
	.HWRITE(ahbif.HWRITE),
	.HADDR(ahbif.HADDR),
	.HWDATA(ahbif.HWDATA),
	.PRDATA(PRDATA_PSlave),
	.HREADY(ahbif.HREADYOUT),  
	.HRESP(ahbif.HRESP),
	.HRDATA(ahbif.HRDATA),
	.PWDATA(apbif.PWDATA),
	.PADDR(apbif.PADDR),
	.PWRITE(apbif.PWRITE),
	.PENABLE(apbif.PENABLE),
	.psel_en(apbif.PSEL)
);

APB_Decoder #(.NUM_SLAVES(NUM_SLAVES)) APB_Decoder 
(
	.PADDR(apbif.PADDR),
	.psel_en(apbif.PSEL),
	.PRData_in(slaveif.PRData_slave),
	.PRDATA_PSlave(PRDATA_PSlave), 
	.PSEL_slave(slaveif.PSEL_slave)
);

endmodule
