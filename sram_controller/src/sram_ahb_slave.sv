/*
	John Skubic
	11/14/14

	Synchronous SRAM controller AHB Slave interface
	Provides an interface with AHB that eliminates the need for wait states when 
	switching between bus writes and bus reads

	NOTES:
	Pending Write signals get generated when a write is followed by a read.  The read takes precedence so there are no bubbles in the bus.
	The pending write is held in pwrite_addr and pwrite_data

	Pending Reads occur if the bus master requests busy cycles.
*/

//`include "source/sram_controller/memory_control_if.vh"
`include "memory_control_if.vh"

module sram_ahb_slave (
	memory_control_if.ahb_slave mcif
);

	parameter BASE_ADDRESS = 0;
	parameter NUM_BYTES = 24; 

	typedef enum {
		IDLE, WRITE, READ
	} rwstate;

	logic [31:0] sl_wdata, sl_addr, last_addr;
	logic sl_rprep, sl_wprep, sl_wen, sl_ren;
	logic [4:0] sl_bcount;//not used
	logic [2:0] sl_btype;//not used
	logic [2:0] size, last_size;
	logic [31:0] addr;

	//latch logic
	logic latched_flag;
	logic [2:0] latched_size;
	logic [31:0] latched_addr;
	logic [31:0] latched_data;

	rwstate current;
	rwstate next;

	logic latch_en, latch_clr, wen;
	
	//for convinience
	logic n_rst;
	logic clk;
	assign clk = mcif.HCLK;
	assign n_rst = mcif.HRESETn;
	
	assign mcif.ram_addr = addr & 32'hFFFFFFFC;
	assign mcif.addr = addr;

	ahb_slave #(.BASE_ADDRESS(BASE_ADDRESS), .NUMBER_ADDRESSES(NUM_BYTES)) AHBS0 (
		.HCLK(mcif.HCLK), 
		.HRESETn(mcif.HRESETn), 
		.HMASTLOCK(1'b0), //not used
		.HWRITE(mcif.HWRITE), 
		.HSEL(mcif.HSEL), 
		.HREADYIN(1'b1), //set high for test
    	.HADDR(mcif.HADDR), 
    	.HWDATA(mcif.HWDATA),
    	.HTRANS(mcif.HTRANS),
    	.HBURST(3'b0), 
    	.HSIZE(mcif.HSIZE),
    	.HPROT(4'b0),//not used
    	.HRDATA(mcif.HRDATA),
    	.HREADYOUT(mcif.HREADY), 
    	.HRESP(mcif.HRESP), 

    	.burst_cancel(1'b0),//not used       
    	.slave_wait(mcif.sram_wait), //not used         
    	.rdata(mcif.rData),       //read data

    	//output of slave
    	.wdata(sl_wdata),
    	.addr(sl_addr), 
    	.r_prep(sl_rprep), 
    	.w_prep(sl_wprep), //read/write data needs to be provided next cycle corresponding to the current addr
    	.wen(sl_wen), 
    	.ren(sl_ren),    //write or read data should be valid, this is needed in case wait states are after a prep
    	.size(size),  //size of the data according to AHB spec (passthrough of HSIZE)
    	.burst_count(sl_bcount),  //current beat count, count increments after the trans data phase, can be safely ignored
    	.burst_type(sl_btype)
	);

	//state machine for read/write
	//this catches the cases where data needs to be latched on a w->r transition
	//next state logic
	always_comb begin 
		if(sl_rprep)
			next = READ;
		else if(sl_wprep)
			next = WRITE;
		else if(sl_wen)
			next = IDLE;
		else if(sl_ren)
			next = IDLE;
		else
			next = IDLE;
	end 

	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst) 
			current <= IDLE;
		else
			current <= next;
	end 
	//output logic
	assign wen = (current == WRITE) ? sl_wen : 1'b0;
	assign latch_en = (current == WRITE) ? sl_rprep : 1'b0; 

	//hold the last addr
	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst) begin
			last_size <= '0;
			last_addr <= '0;
		end
		else if (sl_wprep | sl_rprep) begin //if there is a new address phrase
			last_size <= size;
			last_addr <= sl_addr;
		end 
	end 

	//latched data logic
	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst) begin
			latched_flag <= '0;
			latched_size <= '0;
			latched_addr <= '0;
			latched_data <= '0;
		end 
		else if(latch_en) begin
			latched_flag <= 1'b1;
			latched_size <= last_size;
			latched_addr <= last_addr;
			latched_data <= sl_wdata;
		end
		else if(latch_clr) begin
			latched_flag <= 1'b0;
		end
	end 

	//SRAM output logic
	//assign  signals to interface
	assign mcif.latched_data = latched_data;
	assign mcif.latched_addr = latched_addr;
	assign mcif.latched_flag = latched_flag;
	assign mcif.latched_size = latched_size;
	assign mcif.read_size = last_size;
	assign mcif.read_addr = last_addr;

	always_comb begin
		mcif.wen = '0;
		mcif.ram_wData = '0;
		addr = 32'hBAD1BAD1;
		mcif.size = '0;
		latch_clr = '0;

		if(latched_flag) begin
			mcif.ram_wData = latched_data;
			//if not currently in a read phase
			if(sl_rprep || ((current == READ) && !sl_wprep)) begin 
				mcif.wen = 1'b0;
				latch_clr = 1'b0;
				addr = sl_addr;
				mcif.size = size;
			end 
			else begin 
				mcif.wen = 1'b1;
				latch_clr = 1'b1;
				addr = latched_addr;
				mcif.size = latched_size;
			end
		end 
		else if (sl_rprep || ((current == READ) && !sl_wprep))begin 
			mcif.wen = 1'b0;
			addr = sl_addr;
			mcif.size = size;
		end 
		else begin 
			mcif.wen = wen;
			mcif.ram_wData = sl_wdata;
			addr = last_addr;
			mcif.size = last_size;
			latch_clr = 1'b0;
		end 
	end  

  //assign addr = last_addr;

	




endmodule
	
