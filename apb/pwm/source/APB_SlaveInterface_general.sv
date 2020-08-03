// File name:   APB_SlaveInterface.sv
// Created:     6/26/2014
// Author:      Xin Tze Tee
// Version:     1.1 
// Description: APB Slave Interface which sits between APB Bridge and Registers in the slave.
//				This module interacts with serial port registers
//				Can be duplicated and used for other slaves (eg. GPIO, etc)
//
//Edit (John Skubic) on 11/5/14: Added generizability for number of regs and base address
//				seperate register enable for reads and writes

module APB_SlaveInterface_general
#(
	parameter NUM_REGS = 2, 
	parameter ADDR_OFFSET = 11'h0 //offset of the first slave
)
(
	input wire clk, n_rst,
	// inputs from APB Bridge
	input wire [31:0] PADDR,
	input wire [31:0] PWDATA,
	input wire PENABLE,
	input wire PWRITE,
	input wire PSEL,
	// output to APB Bridge
	output wire [31:0] PRDATA,
	output wire pslverr,
 
 	// input data from slave registers
	input wire [NUM_REGS-1 : 0][31:0] read_data,
	// output to slave registers
	output wire [NUM_REGS-1 : 0] w_enable,
	output wire [NUM_REGS-1 : 0] r_enable,
	output wire [31:0] w_data
);

parameter NUM_REGS_WIDTH =  $clog2(NUM_REGS);//number of bits needed to select each register
parameter BYTES_PER_WORD = 4;

//Encoding for State Machine
typedef enum{ 
    IDLE,ACCESS, ERROR
} APB_STATE;
		  
APB_STATE state, nextstate;
reg [NUM_REGS:0] w_enable_reg;
reg [NUM_REGS:0] r_enable_reg;
reg [31:0] prdata_reg;
reg pslverr_reg;
reg address_match;
reg [NUM_REGS-1:0] address_sel;
reg [NUM_REGS_WIDTH-1 : 0] address_index;
reg [NUM_REGS-1:0] i;
wire [11:0]slave_reg;

assign w_enable = w_enable_reg;
assign r_enable = r_enable_reg;
assign PRDATA = prdata_reg;
assign pslverr = pslverr_reg;
assign w_data = PWDATA; //passthrough
assign slave_reg = PADDR[11:0];

//check if the given address matches one in the slaves address space
always_comb
begin
  address_match = 1'b0;
  address_sel = 0;
  address_index = 0;
  
  for(i = 0; i < NUM_REGS; i ++) begin 	
    if(slave_reg == ((i * BYTES_PER_WORD) + ADDR_OFFSET)) begin
      address_match = 1'b1;
      address_sel = (1 << i);
      address_index = i;
    end
  end
end

// State Machine Register
always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		state <= IDLE;
	end else begin
		state <= nextstate;
	end
end

// Next State Logic
always_comb
begin
  case (state)
	IDLE: begin
	  if (PSEL == 1) begin
		//if address matches any owned addresses, access it
		if(address_match) 
		  nextstate = ACCESS;
		else 
		  nextstate = ERROR;
	  end 
	  else begin
	    nextstate = IDLE;
	  end
	end
	
	ACCESS: begin
	  nextstate = IDLE;
	end

	ERROR: begin
	  nextstate = IDLE;
	end

	default: begin
	  nextstate = IDLE;
	end
  endcase
end

// Output Logic
always_comb
begin
	case (state)
		IDLE: begin
		  w_enable_reg = 0;
		  r_enable_reg = 0;
		  prdata_reg = 0;
		  pslverr_reg = 1'b0;
		end
		
		ACCESS: begin
		  if (PWRITE == 1) begin		// write
			w_enable_reg = address_sel;
			r_enable_reg = 0;
			prdata_reg = 0;
			pslverr_reg = 0;
		  end else begin				// read
			w_enable_reg = 0;
			r_enable_reg = address_sel;
			prdata_reg = read_data[address_index];
			pslverr_reg = 1'b0;		
		  end
		end
		
		ERROR: begin
			w_enable_reg = 0;
			r_enable_reg = 0;
			prdata_reg = 32'hbad1bad1;
			pslverr_reg = 1'b1;
		end
		
		default: begin
			w_enable_reg = 0;
			r_enable_reg = 0;
			prdata_reg = 0;
			pslverr_reg = 0;
		end
	endcase
end

endmodule
