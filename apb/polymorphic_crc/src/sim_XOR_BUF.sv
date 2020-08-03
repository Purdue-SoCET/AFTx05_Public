/*
 Isaiah Grace
 igrace@purdue.edu

 This module simulates the behavior of a single XOR_BUF polymorphic cell
 */

module sim_XOR_BUF (
		    input logic A, B, Vxx, Vyy,
		    output logic X
		    );

   assign X = (Vxx & ~Vyy) ? A ^ B : A;

   //assert(Vxx == ~Vyy) else $error("Vxx and Vyy cannot be equal: XOR_BUF");

endmodule // sim_XOR_BUF
