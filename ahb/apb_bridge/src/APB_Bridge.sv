// File name:   APB_Bridge.sv
// Created:     6/18/2014
// Author:      Xin Tze Tee
// Version:     1.0 
// Description: FSM for AHB to APB Bridge.

module APB_Bridge
(
	input wire clk, n_rst,
	// AHB input
	input wire [1:0] HTRANS,
	input wire HWRITE,
	input wire [31:0] HADDR,
	input wire [31:0] HWDATA,
	// APB input
	input wire [31:0] PRDATA,
	// AHB output
	output wire HREADY,  
	output wire HRESP,
	output wire [31:0] HRDATA,
	// APB output
	output wire [31:0] PWDATA,
	output wire [31:0] PADDR,
	output PWRITE,
	output wire PENABLE,
	output wire psel_en
);

reg psel_en_reg;
reg penable_reg;   
reg hready_reg;
reg [2:0] current_state, next_state, pre_state;
reg iwrite;
reg [31:0] haddr_reg, wdata_reg, iwdata, addr_reg, rdata_reg, new_haddr;
wire valid;

//Encoding for State Machine
parameter [2:0] ST_IDLE = 3'b000,        // IDLE
			 	ST_READ = 3'b001,        // READ SETUP
			 	ST_RENABLE = 3'b010,     // READ ENABLE
			 	ST_WWAIT = 3'b011,       // WRITE LATCH
			 	ST_WRITE = 3'b100,       // WRITE SETUP
			 	ST_WRITEP = 3'b101,      // MULTIWRITE SETUP
			 	ST_WENABLE = 3'b110,     // WRITE ENABLE
			 	ST_WENABLEP = 3'b111;    // MULTIWRITE ENABLE

//HTRANS type
parameter [1:0] TR_IDLE = 2'b00,
			 	TR_BUSY = 2'b01,
			 	TR_NONSEQ = 2'b10,
			 	TR_SEQ = 2'b11;

// valid checks for HTRANS signals and specific HADDR range [14:12] for the peripherals data transaction
assign valid = (((HTRANS == TR_NONSEQ) | (HTRANS == TR_SEQ)) && HADDR[31:28] == 4'h8 ) ? 1 : 0;

// HWRITE Register
/*
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
      hwritereg <= 1'b1;
  end else begin
      hwritereg <= HWRITE;
  end
end
*/

// State Register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
      pre_state <= ST_IDLE;
      current_state <= ST_IDLE;
  end else begin
      pre_state <= current_state;
      current_state <= next_state;
  end
end 

// Next State Logic
always_comb
begin
  if (n_rst == 0) begin
	next_state = ST_IDLE;
  end else begin
  case (current_state)
	ST_IDLE: begin
		if (valid == 1) begin
			if (HWRITE == 1) next_state = ST_WWAIT;
			else next_state = ST_READ;
 		end else begin
			next_state = ST_IDLE;
 		end
	end
	ST_READ: begin
		next_state = ST_RENABLE;  
	end
	ST_RENABLE: begin
		if (valid == 1) begin 
			if (HWRITE == 1) next_state = ST_WWAIT;
			else next_state = ST_READ;
		end else begin
			next_state = ST_IDLE;
		end
	end
	ST_WWAIT: begin
		if (valid == 1) next_state = ST_WRITEP;
		else next_state = ST_WRITE;
	end
	ST_WRITE: begin
		if(valid == 1) next_state = ST_WENABLEP;
		else next_state = ST_WENABLE;
	end
	ST_WRITEP: begin
		next_state = ST_WENABLEP;
	end
	ST_WENABLE: begin
		if (valid == 1) begin
			if(HWRITE == 1) next_state = ST_WWAIT;
			else next_state = ST_READ;
		end else begin
			next_state = ST_IDLE;
		end
	end
	ST_WENABLEP: begin
    if (valid == 1) begin
      if (HWRITE == 1) next_state = ST_WRITEP;
      else next_state = ST_READ;
    end else begin
      next_state = ST_IDLE;
    end
/*    
		if (HWRITE == 1) begin
			if (valid == 1) next_state = ST_WRITEP;
			else next_state = ST_WRITE;
		end else begin
			next_state = ST_READ;
		end
		//next_state = ST_IDLE;
    */
	end
	default: begin
		next_state = ST_IDLE;
	end
  endcase
  end //else block
end

// detect HADDR change
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    new_haddr <= 32'h00000000;
  // grabs the latest HADDR after Read or single write is completed
  end else if (next_state == ST_WWAIT) begin
    new_haddr <= HADDR;
  end else begin
    new_haddr <= new_haddr;
  end
end

// HADDR Register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    haddr_reg <= 32'h00000000;
  end else if (current_state == ST_WWAIT) begin
    haddr_reg <= new_haddr;
  // grabs the latest HADDR for consecutive writes/reads
  end else if (((next_state == ST_READ) | (next_state == ST_WRITE) | (next_state == ST_WRITEP )) && (pre_state != ST_WWAIT)) begin
    haddr_reg <= HADDR;
  end else begin
    haddr_reg <= haddr_reg;
  end
end

// HWDATA Register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    iwdata <= 32'h00000000;
  end else if ((next_state == ST_WRITE) | (next_state == ST_WRITEP)) begin  
    iwdata <= HWDATA;
  end else begin
    iwdata <= iwdata;
  end
end  


assign HRDATA = (current_state == ST_RENABLE) ? PRDATA : 32'h00000000;

// Output Logic
always_comb
begin
  if (n_rst == 0) begin
	psel_en_reg = 1'b0;
	penable_reg = 1'b0;
	hready_reg = 1'b0;
  	iwrite = 1'b1;  
	addr_reg = 32'h00000000;
	wdata_reg = 32'h00000000;
  end else begin
  case (current_state)
  ST_IDLE: begin
      psel_en_reg = 1'b0;
      penable_reg = 1'b0;
      hready_reg = 1'b1; 
      iwrite = 1'b0;
      addr_reg = haddr_reg; //Added
      wdata_reg = iwdata; //Added
  end
  ST_READ: begin
      psel_en_reg = 1'b1;
      penable_reg = 1'b0;
      hready_reg = 1'b0;
      iwrite = 1'b0;
      addr_reg = haddr_reg;
      wdata_reg = iwdata; //Added
  end
  ST_WWAIT: begin
      psel_en_reg = 1'b0;
      penable_reg = 1'b0;
      hready_reg = 1'b0; 
      iwrite = 1'b1;  //Added  
      addr_reg = haddr_reg;
      wdata_reg = iwdata; //Added
  end
  ST_WRITE: begin
     if (pre_state == ST_WWAIT) begin
         psel_en_reg = 1'b1;
         penable_reg = 1'b0;
         hready_reg = 1'b0;  
         iwrite = 1'b1;
         addr_reg = new_haddr;
         wdata_reg = iwdata;
     end else begin
         psel_en_reg = 1'b1;
         penable_reg = 1'b0;
         hready_reg = 1'b0;
         iwrite = 1'b1;
         addr_reg = haddr_reg;
         wdata_reg = HWDATA;
     end
  end
  ST_WRITEP: begin
    if (pre_state == ST_WWAIT) begin
        psel_en_reg = 1'b1;
        penable_reg = 1'b0;
        hready_reg = 1'b0;
        iwrite = 1'b1;
        addr_reg = new_haddr;
        wdata_reg = iwdata;
    end else begin
        psel_en_reg = 1'b1;
        penable_reg = 1'b0;
        hready_reg = 1'b0;
        iwrite = 1'b1;
        addr_reg = haddr_reg;
        wdata_reg = HWDATA;
    end
  end
  ST_RENABLE: begin
      psel_en_reg = 1'b1;
      penable_reg = 1'b1;
      hready_reg = 1'b1;
      iwrite = 1'b0;
      addr_reg = haddr_reg;
      wdata_reg = iwdata; //Added
  end
  ST_WENABLE: begin
      psel_en_reg = 1'b1;
      penable_reg = 1'b1;
      hready_reg = 1'b1;
      iwrite = 1'b1;
      addr_reg = haddr_reg;
      wdata_reg = iwdata;
  end
  ST_WENABLEP: begin
      psel_en_reg = 1'b1;
      penable_reg = 1'b1;
      hready_reg = 1'b1;
      iwrite = 1'b1;
      addr_reg = haddr_reg;
      wdata_reg = HWDATA;
      //wdata_reg = iwdata;
  end
  default: begin
      psel_en_reg = 1'b0;
      penable_reg = 1'b0;
      hready_reg = 1'b1; 
      iwrite = 1'b1;   
      wdata_reg = 32'h00000000;
      addr_reg = 32'h00000000;
  end
  endcase
  end //else block
end

assign psel_en = psel_en_reg;
assign PENABLE = penable_reg;
assign PADDR = addr_reg;
assign PWDATA = wdata_reg;
assign PWRITE = iwrite;
//assign HRDATA = rdata_reg;
assign HREADY = hready_reg;
assign HRESP = 1'b0;
//assign state = current_state;

endmodule
