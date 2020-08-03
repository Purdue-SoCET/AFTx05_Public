
`include "memory_control_if.vh"

module tb_sram_ahb_slave();

	parameter DELAY = 1;
	parameter PERIOD = 20;

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

	memory_control_if mcif();

	logic CLK, n_rst;

	sram_ahb_slave #(.BASE_ADDRESS(0), .NUM_BYTES(24)) DUT (
		.mcif(mcif)
	);

	logic [31:0] rdata;
	int i;

	assign mcif.HRESETn = n_rst;
	assign mcif.HCLK = CLK;
	assign mcif.rData = rdata;

	//clock generation
	always begin
		CLK = 1'b0;
		#(PERIOD);
		CLK = 1'b1;
		#(PERIOD);
	end

	initial begin
		n_rst = 1'b0;
		mcif.HWRITE = 1'b1;
		mcif.HSEL = 0;
		mcif.HADDR = 0;
		mcif.HWDATA = 0;
		mcif.HTRANS = TRANS_IDLE;
		mcif.HSIZE = 0;
		rdata = 0;
		
		@(posedge CLK);
		n_rst = 1;

		mcif.HSEL = 1'b1;
		mcif.HTRANS = TRANS_NONSEQ;
		mcif.HWRITE = 1'b1;

		//check mcif.ram_wData, wen, addr

		for (i = 0; i < 8; i++) begin
			@(posedge CLK);
			mcif.HADDR = mcif.HADDR + 1;
			mcif.HWDATA = mcif.HWDATA + 1;
			#(DELAY);
			if ((mcif.ram_wData != mcif.HWDATA) | (mcif.wen != 1'b1) | (mcif.addr != i))
				$error("ERROR: Incorrect Write output for iter %.0d, received %h, expected %h", i, mcif.ram_wData, mcif.HWDATA);
			else
				$display("CORRECT write output for iter %.0d.", i);
		end
		
		//HADDR and HWDATA are 8

		@(posedge CLK);
		//wdata should be valid here for HADDR 8, data will be 9
		mcif.HWDATA = 9;

		//create a read
		mcif.HWRITE = 0; //read
		mcif.HADDR = 16;

		//ram read should immediately be on the bus
		@(negedge CLK);
		if ((mcif.wen == 1) | (mcif.addr != mcif.HADDR))
			$error("ERROR: Read should have been on the bus.  Expected addr %h, received %h", mcif.HADDR, mcif.addr);
		else
			$display("Correct bus read activity.");

		
		//check read data and 
		//previous write should complete
		@(posedge CLK);
		rdata = 32'hDEADBEEF;
		mcif.HWRITE = 1;
		#(DELAY);
		//check read data
		if (mcif.HRDATA != rdata)
			$error("ERROR: read data did not come back correctly. Expected %h, Received %h.", rdata, mcif.HRDATA);
		else 
			$display("CORRECT read data received.");

		if ((mcif.ram_wData != mcif.HWDATA) && (mcif.addr != 8) && (mcif.wen != 1))
			$error("ERROR: Write Expected for data %h /(%h/) at address %h /(%h/).", mcif.HWDATA, mcif.ram_wData, 8, mcif.addr);
		else
			$display("Correct write after read.");


		//test latched data read with a read in between
		@(posedge CLK);
		mcif.HADDR = 32'h4;
		mcif.HSIZE = 1;
		mcif.HWDATA = 32'hDEAD1234;
		rdata = 32'hBAD1BAD1;
		mcif.HWRITE = 1;

		@(posedge CLK);
		//read generation
		mcif.HWRITE = 0;
		mcif.HSIZE = 1;
		mcif.HADDR = 32'h2;
		@(posedge CLK);
		//read generation
		mcif.HWRITE = 0;
		mcif.HSIZE = 0;
		mcif.HADDR = 32'h4;
		@(negedge CLK);
		if (mcif.latched_size != 2'b01)
			$error("Incorrect latch_size during read.");
		else 
			$display("Correct latch_size during read.");

		if (mcif.latched_data != 32'hDEAD1234)
			$error("Incorrect latch_data during read.");
		else
			$display("Correct latch_data during read.");

		if (mcif.latched_flag != 1'b1)
			$error("Error: Latch Flag not set.");
		else
			$display("CORRECT Latch flag was set.");

		if (mcif.latched_addr != mcif.HADDR)
			$error("ERROR: Incorrect latch_addr.");
		else
			$display("CORRECT: latch_addr.");

		if (mcif.size != mcif.HSIZE)
			$error("Incorrect HSIZE during read.");
		else
			$display("CORRECT HSIZE during read.");


		//test latched data read without a read in between
		@(posedge CLK);
		mcif.HADDR = 32'h4;
		mcif.HSIZE = 1;
		mcif.HWDATA = 32'hDEAD1234;
		rdata = 32'hBAD1BAD1;
		mcif.HWRITE = 1;

		@(posedge CLK);
		//read generation
		mcif.HWRITE = 0;
		mcif.HSIZE = 0;
		mcif.HADDR = 32'h4;
		@(negedge CLK);

		if (mcif.latched_size != 2'b01)
			$error("Incorrect latch_size during read.");
		else 
			$display("Correct latch_size during read.");

		if (mcif.latched_data != 32'hDEAD1234)
			$error("Incorrect latch_data during read.");
		else
			$display("Correct latch_data during read.");

		if (mcif.latched_flag != 1'b1)
			$error("Error: Latch Flag not set.");
		else
			$display("CORRECT Latch flag was set.");

		if (mcif.latched_addr != mcif.HADDR)
			$error("ERROR: Incorrect latch_addr.");
		else
			$display("CORRECT: latch_addr.");

		if (mcif.size != mcif.HSIZE)
			$error("Incorrect HSIZE during read.");
		else
			$display("CORRECT HSIZE during read.");


	end 

endmodule
