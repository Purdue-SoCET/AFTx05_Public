/*
 Isaiah Grace
 igrace@purdue.edu
 */

module POLI_standalone 
  (
   input logic 	output_select, A, B, orient,
   output logic X
   );
   
   logic 	NAND_NOR_X;
   logic 	XOR_BUF_X;
   
   assign X = output_select ? XOR_BUF_X : NAND_NOR_X;
   
   dig_poly_NAND_NOR2x_1 A0 (           .A (A),
				     .B (B),
				     .orient (orient),
				     .X (NAND_NOR_X));
   
   dig_poly_XOR_BUF2_x1 A1 (          .A (A),
				   .B (B),
				   .orient (orient),
				   .X (XOR_BUF_X));
   
endmodule // POLI_standalone
