/*
 Isaiah Grace
 igrace@purdue.edu
 
 This interface file specifies the connections between:
 
 control_register <-> abp_slave
 control_register <-> CRC32
 control_register <-> NAND_NOR
 control_register <-> XOR_BUF
 */

`ifndef CONTROL_REGISTER_IF_VH
 `define CONTROL_REGISTER_IF_VH

// Includes:
 `include "POLI_types_pkg.vh"

interface control_register_if;

   // Import types
   import POLI_types_pkg::*;

   // APB_slave related signals
   // Outputs
   logic [WORD_SIZE-1:0] read_data;

   // Inputs
   logic [WORD_SIZE-1:0] write_data;
   logic 		 write_enable;
   regsel_t              register_select; // Check POLI_types_pkg.vh for enumeration definition

   // CRC32 related signals
   // TODO: finalize interfaces for CRC32 signals
   // Outputs
   logic [WORD_SIZE-1:0] crc_data_in;
   logic 		 crc_reset;
   logic 		 crc_start;
   logic [WORD_SIZE-1:0] crc_orient;
   
   // Inputs
   logic [WORD_SIZE-1:0] crc_data_out;
   logic 		 crc_ready;
   	       
   // NAND_NOR related signals
   // Inputs
   logic 		 NAND_NOR_out;

   // Outputs
   logic 		 NAND_NOR_a;
   logic 		 NAND_NOR_b;
   logic 		 NAND_NOR_orient;
   
   // XOR_BUF related signals
   // Inputs
   logic 		 XOR_BUF_out;

   // Outputs
   logic 		 XOR_BUF_a;
   logic 		 XOR_BUF_b;
   logic 		 XOR_BUF_orient;

   modport control (
		    input  write_data, write_enable, register_select,
		    output read_data,
   
		    input  crc_data_out, crc_ready,
		    output crc_data_in, crc_reset, crc_start, crc_orient,
   
		    input  NAND_NOR_out,
		    output NAND_NOR_a, NAND_NOR_b, NAND_NOR_orient,
   
		    input  XOR_BUF_out,
		    output XOR_BUF_a, XOR_BUF_b, XOR_BUF_orient
		    );

endinterface // control_register_if

`endif //  `ifndef CONTROL_REGISTER_IF_VH
