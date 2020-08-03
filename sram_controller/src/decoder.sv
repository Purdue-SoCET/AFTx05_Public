/*
Decoder block for memory controller
Fall 2014
*/

//Interfaces
//`include "source/sram_controller/memory_control_if.vh"
`include "memory_control_if.vh"

module decoder(memory_control_if.decoder mcif);

localparam SIZE_WORD = 2'h2;
localparam SIZE_HALF_WORD = 2'h1;
localparam SIZE_QUARTER_WORD = 2'h0;

logic [3:0] quarter_word, half_word, word, byte_en_in;
logic [3:0] latched_quarter_word, latched_half_word, latched_word, latched_byte_en_in;

always_comb begin
	
	//Set Defaults
	quarter_word = '0;
	half_word = '0;
	word = '0;
	byte_en_in = '0;
	mcif.sram_en = 2'b01;	//By default will use SRAM #1

	//Latched defaults
	latched_quarter_word = '0;
	latched_half_word = '0;
	latched_word = '0;
	latched_byte_en_in = '0;

	//Enable the appropriate bits (lanes) for byte enable
	case(mcif.addr[1:0])
		2'h0	:	begin
						quarter_word = 4'h1; //E.g. Address ending in 0 selects the rightmost lane
						word 		 = 4'hF;
						half_word	 = 4'h3;
					end

		2'h1	:	begin
						quarter_word = 4'h2;
					end

		2'h2	:	begin
						quarter_word = 4'h4;
						half_word	 = 4'hC;
					end

		2'h3	:	begin
						quarter_word = 4'h8;
					end
	endcase

	//Choose byte enable based on intended size
	case(mcif.size)
		SIZE_QUARTER_WORD	:	byte_en_in	 = quarter_word;
		SIZE_HALF_WORD  	:	byte_en_in	 = half_word;
		SIZE_WORD        	:	byte_en_in   = word;
	endcase

	//Handles the latched signals in case they are used
	//Enable the appropriate bits (lanes) for byte enable
	case(mcif.latched_addr[1:0])
		2'h0	:	begin
						latched_quarter_word = 4'h1; //E.g. Address ending in 0 selects the rightmost lane
						latched_half_word	 = 4'h3;
						latched_word 		 = 4'hF;
					end

		2'h1	:	begin
						latched_quarter_word = 4'h2;
						
					end

		2'h2	:	begin
						latched_quarter_word = 4'h4;
						latched_half_word	 = 4'hC;
					end

		2'h3	:	begin
						latched_quarter_word = 4'h8;
						
					end
	endcase

	//Latched byte enable selection
	case(mcif.latched_size)
		SIZE_QUARTER_WORD 	:	latched_byte_en_in	 = latched_quarter_word;
		SIZE_HALF_WORD    	:	latched_byte_en_in	 = latched_half_word;
		SIZE_WORD          	:	latched_byte_en_in   = latched_word;
	endcase		

	//Set polarity of byte enable
	mcif.byte_en = byte_en_in ^ mcif.INVERT_BYTE_EN; 
	mcif.latched_byte_en = latched_byte_en_in ^ mcif.INVERT_BYTE_EN; 
	
	//Determine which SRAM chip to use based on address, same for both latched and non-latched
	for(int sram_num = 0; sram_num < mcif.N_SRAM; sram_num++) begin
	if(($unsigned(mcif.addr) >= $unsigned(sram_num * ( mcif.SRAM_DEPTH) * mcif.SRAM_WIDTH))
		&& ($unsigned(mcif.addr) < $unsigned((sram_num+1) * (mcif.SRAM_DEPTH) * mcif.SRAM_WIDTH)))
		mcif.sram_en = (2'b1 << (sram_num))^mcif.INVERT_CE_EN;	
	end
end

endmodule

