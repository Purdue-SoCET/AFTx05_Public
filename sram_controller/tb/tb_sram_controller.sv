// File name:   tb_sram_controller.sv
// Description: Test for SRAM memory controller using the file reading bus master as the AHB master 
// **Note: Run mectrl_testcmds.py to write commands for frbm into ".tic"

`timescale 1ns / 10ps
`include "memory_control_if.vh"
`include "sram_controller_if.vh"
`include "ahb_if.vh"

module tb_sram_controller();

// Define parameters
parameter CLK_PERIOD = 20;
parameter DELAY = 5;
parameter N_SRAM = 2;
parameter INVERT_CE_EN = 0;
parameter INVERT_BYTE_EN = 0;
parameter SRAM_WIDTH = 4;
parameter SRAM_DEPTH = 1024;


//HTRANS VALUES
localparam TRANS_IDLE =   2'b00;
localparam TRANS_BUSY =   2'b01;
localparam TRANS_NONSEQ = 2'b10;
localparam TRANS_SEQ =    2'b11;

//HBURST VALUES
localparam BURST_SINGLE = 3'b000;
localparam BURST_INCR =   3'b001; //undefined length
localparam BURST_WRAP4 =  3'b010;
localparam BURST_INCR4 =  3'b011;
localparam BURST_WRAP8 =  3'b100;
localparam BURST_INCR8 =  3'b101;
localparam BURST_WRAP16 = 3'b110;
localparam BURST_INCR16 = 3'b111;

//HRESP VALUES
localparam RESP_OK =    1'b0;
localparam RESP_ERROR = 1'b1;

//HSIZE
localparam SIZE8 = 3'b000;
localparam SIZE16 = 3'b001;
localparam SIZE32 = 3'b010;
localparam SIZE64 = 3'b011;

//--AHB Bus Signals--//

logic 	HCLK;
logic 	HRESETn;

int i;
ahb_if ahbif();

sram_controller_if #(.N_SRAM(N_SRAM)) sramif();

sram_controller #(.N_SRAM(N_SRAM), .INVERT_CE_EN(INVERT_CE_EN), .INVERT_BYTE_EN(INVERT_BYTE_EN), .SRAM_WIDTH(SRAM_WIDTH), .SRAM_DEPTH(SRAM_DEPTH)) MEMCTRL (
  .HCLK(HCLK), 
  .HRESETn(HRESETn), 
  .ahbif(ahbif),
  .sramif(sramif)
);


parameter NUM_TESTS = 9;
//tb inputs
logic [NUM_TESTS:0][31:0] tb_addr = {
	32'h0, 
	32'd4196, 
	32'h20, 
	32'h30, 
	32'h30, //write to read transition
	32'h40, 
	32'h30, 
	32'h50, //read to write transition
	32'h60,
	32'hDEADBEEF //dummy value not used
};

logic [NUM_TESTS:0][31:0] tb_wdata = {
	32'hDEADBEEF, 
	32'hDEADBEEF, 
	32'hDEADBEEF,
	32'h1, 
	32'h2,	//write to read transition
	32'hDEADBEEF, 
	32'hDEADBEEF, 
	32'hDEADBEEF, //read to write transition
	32'h3, 
	32'h4
};

logic [NUM_TESTS:0] tb_hwrite = {
	1'b0, 
	1'b0, 
	1'b1, 
	1'b1,
	1'b0, //write to read transition
	1'b0, 
	1'b0,
	1'b1, //read to write transition
	1'b1,
	1'b1 //dummy
};

logic [NUM_TESTS:0][31:0] tb_ramRdata = {
	32'hDEADBEEF, //dummy value not used
	32'h5, 
	32'h6,
	32'hDEADBEEF, 
	32'hDEADBEEF, //write to read transition
	32'hDEADBEEF, 
	32'h7, 
	32'hDEADBEEF, //read to write transition
	32'hDEADBEEF, 
	32'hDEADBEEF
};

//tb outputs
logic [NUM_TESTS:0][31:0] tb_hrdata = {
	32'hxxxxxxxx, //dummy value not used
	32'h5, 
	32'h6,
	32'hxxxxxxxx, 
	32'hxxxxxxxx, //write to read transition
	32'h2, 
	32'h7, 
	32'h2, //read to write transition
	32'hxxxxxxxx, 
	32'hxxxxxxxx	
};

logic [NUM_TESTS:0][31:0] tb_ramWdata = {
	32'hxxxxxxxx, 
	32'hxxxxxxxx, 
	32'hxxxxxxxx,
	32'h1, 
	32'hxxxxxxxx, //write to read transition
	32'hxxxxxxxx, 
	32'hxxxxxxxx, 
	32'h2, //read to write transition
	32'h3, 
	32'h4
};

logic [NUM_TESTS:0][N_SRAM-1:0] tb_ramEn = {
	2'b01, 
	2'b01, 
	2'b00,
	2'b01, 
	2'b01, //write to read transition
	2'b01, 
	2'b01, 
	2'b01, //read to write transition
	2'b01, 
	2'bxx
};

logic [NUM_TESTS:0]  tb_ramWen = {
	1'b0, 
	1'b0,
	1'bx, //read to write with no latched data, nothing to do
	1'b1, 
	1'b0, //write to read transition
	1'b0, 
	1'b0, 
	1'b1, //read to write transition
	1'b1, 
	1'bx
};

logic [NUM_TESTS:0][SRAM_WIDTH-1:0] tb_byteEn = {
	4'hF, 
	4'hF, 
	4'hX, 
	4'hF, 
	4'hF, //write to read transition
	4'hF, 
	4'hF, 
	4'hF, //read to write transition
	4'hF, 
	4'hx
};


// Clock Generation
always
begin : CLK_GEN
	HCLK = 1'b0;
	#(CLK_PERIOD / 2);
	HCLK = 1'b1;
	#(CLK_PERIOD / 2);
end

initial begin

	ahbif.HWRITE = 1'b1;
	ahbif.HSEL = 0;
	ahbif.HADDR = 0;
	ahbif.HWDATA = 0;
	ahbif.HTRANS = TRANS_IDLE;
	ahbif.HSIZE = SIZE32;


	HRESETn = 1'b0;
	@(negedge HCLK);
	HRESETn = 1'b1;
	@(posedge HCLK);
	ahbif.HTRANS = TRANS_NONSEQ;
	ahbif.HSEL = 1'b1;
	sramif.ram_rData[1] = 32'hBAD3BAD3;

	for (i = NUM_TESTS;i >= 0; i--) begin
		//set
		ahbif.HADDR = tb_addr[i];
		ahbif.HWDATA = tb_wdata[i];
		ahbif.HWRITE = tb_hwrite[i];
		sramif.ram_rData[0] = tb_ramRdata[i];

		#(DELAY);

		//test
		if((tb_ramWdata[i] != sramif.ram_wData) && (tb_ramWdata[i] != 32'hxxxxxxxx)) begin
			$error("ERROR with ramWriteData: Expected: %h Received %h", tb_ramWdata[i], sramif.ram_wData);
		end
		else if (tb_ramWdata[i] != 32'hxxxxxxxx) begin
			$info("CORRECT ramWriteData: Expected: %h Received %h", tb_ramWdata[i], sramif.ram_wData);
		end
		
		if ((tb_ramEn[i] != sramif.sram_en) && (tb_ramEn[i] != 2'bxx)) begin
			$error("ERROR with ramEn: Expected: %h Received %h", tb_ramEn[i], sramif.sram_en);
		end
		else if (tb_ramEn[i] != 2'bxx) begin
			$info("CORRECT ramEn: Expected: %h Received %h", tb_ramEn[i], sramif.sram_en);
		end
		
		if ((tb_ramWen[i] != sramif.wen) && (tb_ramWen[i] != 1'bx)) begin
			$error("ERROR with ramWen: Expected: %h Received %h", tb_ramWen[i], sramif.wen);
		end
		else if (tb_ramWen[i] != 1'bx) begin
			$info("CORRECT ramWen: Expected: %h Received %h", tb_ramWen[i], sramif.wen);
		end
		
		if ((tb_byteEn[i] != sramif.byte_en) && (tb_byteEn != 4'bxxxx)) begin
			$error("ERROR with byteEn: Expected: %h Received %h", tb_byteEn[i], sramif.byte_en);
		end
		else if (tb_byteEn != 4'bxxxx) begin
			$info("CORRECT byteEn: Expected: %h Received %h", tb_byteEn[i], sramif.byte_en);
		end

		if ((tb_hrdata[i] != ahbif.HRDATA) && (tb_hrdata[i] != 32'bxxxx)) begin
			$error("ERROR with HRDATA: Expected: %h Received %h", tb_hrdata[i], ahbif.HRDATA);
		end
		else if (tb_hrdata[i] != 32'bxxxx) begin
			$info("CORRECT HRDATA: Expected: %h Received %h", tb_hrdata[i], ahbif.HRDATA);
		end

		@(posedge HCLK);

	end



end

endmodule
