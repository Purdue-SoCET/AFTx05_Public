`timescale 1ns/1ns

`include "memory_control_if.vh"

module tb_encoder();

memory_control_if mcif();

encoder encoder(mcif);

initial begin
	mcif.size = 1;
	mcif.sram_en   = 2'b10;
	mcif.byte_en = 4'h3;
	mcif.ram_rData[0] = 32'hAAAABBBB;
	mcif.ram_rData[1] = 32'h44445555;
end

endmodule

