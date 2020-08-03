/*
Encoder block for memory controller
Fall 2014
*/

//Interfaces
`include "memory_control_if.vh"

module encoder(memory_control_if.encoder mcif);

parameter N_SRAM = 1;
parameter INVERT_CE_EN = 0;

localparam SIZE_WORD = 2'h2;
localparam SIZE_HALF_WORD = 2'h1;
localparam SIZE_QUARTER_WORD = 2'h0;

//Internal Signals
logic [31:0] rData_in, word;
logic [15:0] half_word;
logic [7:0]  quarter_word;	
logic [3:0] byte_sel;
logic [N_SRAM : 0] rData_sel;
logic [3:0] lcv;
logic [31:0] bit_mask;


//Determine polarity of byte/sram enables
assign rData_sel = mcif.sram_en ^ INVERT_CE_EN;
assign lcv = mcif.latched_byte_en ^ INVERT_CE_EN;
assign bit_mask = {{8{lcv[3]}}, {8{lcv[2]}}, {8{lcv[1]}}, {8{lcv[0]}}};	//byte-enable used to mask latched data
		
assign mcif.rData = mcif.ram_rData[0];

//always_comb begin
//	//Set Defaults
//	rData_in = '0;
//	quarter_word = '0;
//	half_word = '0;
//	word = '0;
//
//
//	// Select appropriate SRAM input using the one-hot sram enable
//	for(int index = 0; index < N_SRAM; index++) begin
//		if(rData_sel == ((2'b1 << index)^INVERT_CE_EN)) begin
//			rData_in = mcif.ram_rData[index];	//default read data
//			if(mcif.latched_flag && ((mcif.latched_addr & 32'hFFFFFFFC) == mcif.read_addr)) begin
//				//latched data masked with latched byte enable, read fills in rest of 32 bits
//				rData_in = (mcif.latched_data & bit_mask) | (mcif.ram_rData[index] & ~bit_mask);
//			end
//		end
//	end
//
//	//Duplicate the bytes to fit ARM standard, based on the intended size
//	case(mcif.read_size)
//		SIZE_QUARTER_WORD	: begin	
//			byte_sel	 = 4'b1 << mcif.read_addr[1:0];
//		end
//		SIZE_HALF_WORD	: begin
//			byte_sel	 = 4'd3 << mcif.read_addr[1:0];
//		end
//		SIZE_WORD	: begin
//			byte_sel	 = 4'b1111;
//		end
//		default : begin
//			byte_sel	 = 4'b0;
//		end
//	endcase
//
//	//Select appropriate bytes (lanes) using the byte enable
//	case(byte_sel)
//		4'h1	:	quarter_word = rData_in[7:0];
//		4'h2	:	quarter_word = rData_in[15:8];
//		4'h4	:	quarter_word = rData_in[23:16];
//		4'h8	:	quarter_word = rData_in[31:24];
//		4'h3	:	half_word 	 = rData_in[15:0];
//		4'hC	:	half_word 	 = rData_in[31:16];
//		4'hF 	:	word 		     = rData_in;
//	endcase
//
//	//Duplicate the bytes to fit ARM standard, based on the intended size
//	case(mcif.read_size)
//		SIZE_QUARTER_WORD	: begin	
//			mcif.rData	 = {4{quarter_word}};
//		end
//		SIZE_HALF_WORD	: begin
//			mcif.rData	 = {2{half_word}};
//		end
//		SIZE_WORD	: begin
//			mcif.rData	 = word;
//		end
//		default : begin
//			mcif.rData 	 = 32'hBAD1BAD1;
//		end
//	endcase
//end

	

endmodule
