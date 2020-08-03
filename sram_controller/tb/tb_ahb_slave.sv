
module tb_ahb_slave ();

	parameter REG_WIDTH = 10;
	parameter BASE_ADDR = 0;

	localparam PERIOD = 20;
	localparam DELAY = 1;

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

	logic  HMASTLOCK, HWRITE, HSEL, HREADYIN, HREADYOUT, HRESP;
	logic [31:0] HADDR, HWDATA, HRDATA;
	logic [1:0] HTRANS;
	logic [2:0] HBURST, HSIZE;
	logic [3:0] HPROT;

	logic burst_cancel, slave_wait, r_prep, w_prep, wen, ren;
	logic [31:0] rdata, wdata, addr, prev_addr;
	logic [2:0] size, burst_type;
	logic [4:0] burst_count;
	logic clk;
	logic n_rst;
	logic [REG_WIDTH-1:0][31:0] register;
	int i;

	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst)
			register <= '0;
		else if (wen)
			register[prev_addr] <= wdata;

		if(~n_rst)
			prev_addr <= 0;
		else if(r_prep | w_prep)
			prev_addr <= addr;
	end

	assign rdata = ren ? register[prev_addr] : 32'hBAD1BAD1;


	ahb_slave #(.BASE_ADDRESS(BASE_ADDR), .NUMBER_ADDRESSES(REG_WIDTH)) S0 (
		//ahb signals
		.HCLK(clk),
		.HRESETn(n_rst),
		.HMASTLOCK(HMASTLOCK),
		.HWRITE(HWRITE),
		.HSEL(HSEL),
		.HREADYIN(HREADYIN),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HTRANS(HTRANS),
		.HBURST(HBURST),
		.HSIZE(HSIZE),
		.HPROT(HPROT),
		.HRDATA(HRDATA),
		.HREADYOUT(HREADYOUT),
		.HRESP(HRESP),

		//slave interface input to ahb
		.burst_cancel(burst_cancel),
		.slave_wait(slave_wait),
		.rdata(rdata),
		//slave interface output from ahb
		.wdata(wdata),
		.addr(addr),
		.r_prep(r_prep),
		.w_prep(w_prep),
		.wen(wen),
		.ren(ren),
		.size(size),
		.burst_count(burst_count),
		.burst_type(burst_type)
	);

	//clock generation
	assign HREADYIN = HREADYOUT;

	always begin
		clk = 1'b1;
		#(PERIOD/2);
		clk = 1'b0;
		#(PERIOD/2);
	end 

	initial begin
		n_rst = 1'b0;
		HMASTLOCK = 0;
		HWRITE = 1'b1;
		HSEL = 0;
		HADDR = 0;
		HWDATA = 0;
		HTRANS = TRANS_IDLE;
		HBURST = BURST_SINGLE;
		HSIZE = 0;
		HPROT = 0;

		burst_cancel = 0;
		slave_wait = 1'b1;

		@(negedge clk);
		n_rst = 1'b1;

		//successive writes
		for(i = 0; i < REG_WIDTH + 1; i++) begin
			@(posedge clk);
			HWRITE = 1;
			HSEL = 1;
			if (i >= REG_WIDTH) begin
				HSEL = 0;
				HADDR = 0;
			end
			HADDR = i + BASE_ADDR;
			HWDATA = i-1; //data variation
			HTRANS = TRANS_NONSEQ;
			HBURST = BURST_SINGLE;
		end 

		@(posedge clk);
		HSEL = 0;
		@(posedge clk);

		//test correctness of writes
		for(i = 0; i < REG_WIDTH; i++) begin
			if(register[i] == i)
				$display("Correct write for reg index %.0d", i);
			else
				$error("Incorrect write for reg index %.0d.  Received %h but Expected %h", i,register[i], i);
		end

		//successive reads
		for(i = 0; i < REG_WIDTH + 1; i++) begin
			@(posedge clk);
			HSEL = 1;
			HWRITE = 0; // read
			if (i >= REG_WIDTH) begin
				HSEL = 0;
				HADDR = 0;
			end
			HADDR = i + BASE_ADDR;
			HTRANS = TRANS_NONSEQ;
			HBURST = BURST_SINGLE;

			//check if read was correct
			#(DELAY);
			if (i > 0) begin
				if (HRDATA == register[i-1])
					$display("Correct HRDATA for reg index %.0d", i-1);
				else
					$error("Incorrect HRDATA for reg index %.0d, Received %h but Expected %h",i-1, HRDATA, register[i-1]);
			end
		end

		@(posedge clk);
		HSEL = 0;
		HTRANS = TRANS_IDLE;

		//test error response
		@(posedge clk);

		HSEL = 1;
		HTRANS = TRANS_NONSEQ;
		HADDR = BASE_ADDR + REG_WIDTH;

		@(posedge clk);
		#(DELAY);

		if((HREADYOUT == 1'b0) && (HRESP == RESP_ERROR))
			$display("Correct first error cycle for address out of range.");
		else
			$error("Incorrect first error cycle for address out of range.");

		@(posedge clk);
		#(DELAY);

		HTRANS = TRANS_IDLE;
		HSEL = 0;
		if((HREADYOUT == 1'b1) && (HRESP == RESP_ERROR))
			$display("Correct second error cycle for address out of range.");
		else
			$error("Incorrect first error cycle for address out of range.");

		@(posedge clk);
		#(DELAY);

		if(HRESP == RESP_OK) 
			$display("Correct return to ok response after erroring.");
		else
			$error("Incorrect return to ok response after erroring.");



	end

endmodule