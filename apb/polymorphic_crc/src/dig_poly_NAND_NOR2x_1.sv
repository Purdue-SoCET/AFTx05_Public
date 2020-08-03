/*
 John Martinuk
 jmartinu@purdue.edu
 */

module dig_poly_NAND_NOR2_x1 
  (
   input logic 	A, B, orient,
   output logic X
   );
   
   assign X = (orient) ? ~(A & B) : ~(A | B);
   
endmodule // POLI_standalone
