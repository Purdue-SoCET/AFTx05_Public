/*
 Isaiah Grace
 igrace@purdue.edu
 
 This file describes the data types used in the project
 */

`ifndef POLI_TYPES_PKG_VH
 `define POLI_TYPES_PKG_VH

package POLI_types_pkg;
   
   // Parameters
   parameter WORD_SIZE = 32;
   
   // Address space
   parameter BASE_ADDR = 32'h80030000; // This is the base address of our peripheral as given to us in the AFTx05 Memory Map

   // NAND_NOR register addresses
   localparam NAND_NOR_CONTROL_ADDR = BASE_ADDR + 8'h00;
   localparam NAND_NOR_INPUT_ADDR   = BASE_ADDR + 8'h04;
   localparam NAND_NOR_OUTPUT_ADDR  = BASE_ADDR + 8'h08;

   // XOR_BUF register addresses
   localparam XOR_BUF_CONTROL_ADDR  = BASE_ADDR + 8'h0C;
   localparam XOR_BUF_INPUT_ADDR    = BASE_ADDR + 8'h10;
   localparam XOR_BUF_OUTPUT_ADDR   = BASE_ADDR + 8'h14;

   // CRC register addresses
   localparam CRC_CONTROL_ADDR      = BASE_ADDR + 8'h18;
   localparam CRC_CONFIG_ADDR       = BASE_ADDR + 8'h1C;
   localparam CRC_STATUS_ADDR       = BASE_ADDR + 8'h20;
   localparam CRC_INPUT_ADDR        = BASE_ADDR + 8'h24;
   localparam CRC_OUTPUT_ADDR       = BASE_ADDR + 8'h28;
      
     
   // register select type.
   // This enumerates the registers used in the control register module.
   typedef enum logic [3:0] {
			     BAD_ADDR,
			     
			     NAND_NOR_CONTROL,
			     NAND_NOR_INPUT,
			     NAND_NOR_OUTPUT,
   
			     XOR_BUF_CONTROL,
			     XOR_BUF_INPUT,
			     XOR_BUF_OUTPUT,
   
			     CRC_CONTROL,
			     CRC_CONFIG,
			     CRC_STATUS,
			     CRC_INPUT,
			     CRC_OUTPUT
			     } regsel_t;
   
endpackage // POLI_types_pkg
   
`endif //  `ifndef POLI_TYPES_PKG_VH
   
