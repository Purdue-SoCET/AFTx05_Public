/*
 Isaiah Grace
 igrace@purdue.edu
 
 This is the interface file for the CRC_generator
 */

`ifndef CRC_GENERATOR_IF_VH
 `define CRC_GENERATOR_IF_VH

// Includes
`include "POLI_types_pkg.vh"

interface crc_generator_if;

   // Import types
   import POLI_types_pkg::*;
   
   // Inputs
   logic [WORD_SIZE-1:0] crc_data_in;
   logic 		 crc_reset;
   logic 		 crc_start;
   logic [WORD_SIZE-1:0] crc_orient;
   
   // Outputs
   logic [WORD_SIZE-1:0] crc_data_out;
   logic 		 crc_ready;

   modport crc_generator (
			  input  crc_data_in, crc_reset, crc_start, crc_orient,
			  output crc_data_out, crc_ready
			  );
      
endinterface // crc_generator_if

`endif //  `ifndef CRC_GENERATOR_IF_VH
