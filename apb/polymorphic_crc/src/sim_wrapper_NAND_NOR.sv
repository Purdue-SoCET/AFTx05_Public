/*
 John Martinuk
 
 This module simulates the behavior of an NAND_NOR cell with driving buffers to power polymorphic gates
 */

module sim_wrapper_NAND_NOR (
			     input logic  A, B, orient,
			     output logic X
			     );
   
   sim_NAND_NOR NAND_NOR (
			  .A(A),
			  .B(B),
			  .Vxx(orient),
			  .Vyy(~orient),
			  .X(X)
			  );

endmodule // sim_wrapper_NAND_NOR



