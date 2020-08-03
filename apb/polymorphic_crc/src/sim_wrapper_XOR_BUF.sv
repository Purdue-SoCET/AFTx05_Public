/*
 Isaiah Grace
 igrace@purdue.edu
 
 This module simulates the behavior of an XOR_BUF cell with driving buffers to power polymorphic gates
 */

module sim_wrapper_XOR_BUF (
			    input logic A, B, orient,
			    output logic X
			    );

   sim_XOR_BUF XOR_BUF (
			.A(A),
			.B(B),
			.Vxx(orient),
			.Vyy(~orient),
			.X(X)
			);
   
endmodule // sim_wrapper_XOR_BUF
