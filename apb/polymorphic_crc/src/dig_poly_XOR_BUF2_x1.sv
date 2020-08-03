/*
 John Martinuk
 jmartinu@purdue.edu
 */

module dig_poly_XOR_BUF2_x1 
  (
   input logic 	A, B, orient,
   output logic X
   );
   
   assign X = (orient) ? (A ^ B) : A;
   
endmodule // POLI_standalone
