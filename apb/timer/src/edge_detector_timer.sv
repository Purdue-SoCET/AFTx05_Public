// File name:   edge_detector.sv
// Created:     4/16/2015
// Last Updated:1/26/2016
// Authors:     John Skubic
//              Jacob R. Stevens
// Version:     2.0 
// Description: Edge detector. Specialized for use in the timer by introducing
//              two signals to control what edge to detect and a single signal
//              for indicated a detected edge. 
//	

module edge_detector_timer #(
		parameter WIDTH = 8
	)
	(
		input logic clk, n_rst, 
		input logic [WIDTH - 1:0] signal,
        input logic [WIDTH - 1:0] EDGEnA, EDGEnB,
		output logic [WIDTH - 1:0] edge_detected
	);

	logic [WIDTH - 1 : 0] signal_r;
    logic [WIDTH - 1 : 0] pos_edge, neg_edge;

	//flip flop behavior
	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst)
			signal_r <= '0;
		else 
			signal_r <= signal;
	end

	// output logic
    // EDGEnB   EDGEnA  Detection
    //  0           0       Disabled
    //  0           1       Rising Edge
    //  1           0       Falling Edge
    //  1           1       Either Edge

	assign pos_edge = signal & ~signal_r & EDGEnA;
	assign neg_edge = ~signal & signal_r & EDGEnB;

    assign edge_detected = pos_edge | neg_edge;

endmodule
