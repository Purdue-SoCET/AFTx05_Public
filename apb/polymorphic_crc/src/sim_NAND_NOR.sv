/*
 John Martinuk & Isaiah Grace
 
 This module simulates the behavior of a single NAND_NOR polymorphic cell
 */

module sim_NAND_NOR (
		     input logic  A, B, Vxx, Vyy,
		     output logic X
		     );

   assign X = (Vxx & ~Vyy) ? ~(A & B) : ~(A | B);

   /*
   assert (Vxx != Vyy)
     else $error("Vxx and Vyy cannot be equal: NAND_NOR");
   */
endmodule // sim_NAND_NOR

