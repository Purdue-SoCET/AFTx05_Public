
module SOC_RAM 
#( 	parameter integer ADDRBIT = 16,
	parameter integer DATABIT = 32,
	parameter integer BOTTOMADDR = 0,
	parameter integer TOPADDR = 65535)
(
	input wire clk,
	input wire n_rst,
	input wire [DATABIT - 1:0] w_data,
	input wire [ADDRBIT - 1:0] addr,
	input wire w_en,
  input wire [3:0] byte_en,
	output reg [DATABIT - 1:0] r_data
);
	reg [DATABIT - 1:0] RAM[TOPADDR:BOTTOMADDR];
	reg [ADDRBIT - 1:0] address_reg;

	
	always_ff @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0)
			RAM[0] <= 32'b0;
		else begin
		  if(w_en) begin
			  RAM[addr][7:0] <= (byte_en[0]) ?  w_data[7:0] : RAM[addr][7:0]; 
			  RAM[addr][15:8] <= (byte_en[1]) ?  w_data[15:8] : RAM[addr][15:8]; 
			  RAM[addr][23:16] <= (byte_en[2]) ?  w_data[23:16] : RAM[addr][23:16]; 
			  RAM[addr][31:24] <= (byte_en[3]) ?  w_data[31:24] : RAM[addr][31:24]; 
      end
		  address_reg <= addr; 
    end
	end

	assign r_data = RAM[addr];


endmodule


