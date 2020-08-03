// File name:   edge_detector.sv
// Created:     4/16/2015
// Author:      John Skubic
// Version:     1.0 
// Description: Edge detector 
//	

module edge_detector #(
		parameter WIDTH = 1
	)
	(
		input logic clk, n_rst, 
		input logic [WIDTH - 1:0] signal,
		output logic [WIDTH - 1:0] pos_edge, neg_edge
	);

	logic [WIDTH - 1 : 0] signal_r;

	//flip flop behavior
	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst)
			signal_r <= '0;
		else 
			signal_r <= signal;
	end

	//output logic
	assign pos_edge = signal & ~signal_r;
	assign neg_edge = ~signal & signal_r;

endmodule
