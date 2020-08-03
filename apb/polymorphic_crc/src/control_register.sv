/* 
 Isaiah Grace
 igrace@purdue.edu
 
 This module controls the orientation and status of the test structures
 */

// Includes
`include "POLI_types_pkg.vh"
`include "control_register_if.vh"

module control_register (
			 input logic CLK,
			 input logic nRST,
			 control_register_if.control crif
			 );
   // Import types
   import POLI_types_pkg::*;

   logic 			     next_crc_start;
   logic 			     next_crc_reset;

   // Logic to pulse the start and reset flags, the crc32 module expects them to be high for only one clock cycle 
   always_comb
     begin
	if (crif.crc_start)
	  next_crc_start = 1'b0;
	else
	  next_crc_start = crif.write_enable && crif.register_select == CRC_CONTROL ? crif.write_data[0] : crif.crc_start;

	if (crif.crc_reset)
	  next_crc_reset = 1'b0;
	else
	  next_crc_reset = crif.write_enable && crif.register_select == CRC_CONTROL ? crif.write_data[1] : crif.crc_reset;
     end // always_comb
   
   // combinational logic for read_data
   always_comb
     begin
	casez (crif.register_select)
	  BAD_ADDR:         crif.read_data = 32'hbad1bad1;
	  NAND_NOR_CONTROL: crif.read_data = {31'b0, crif.NAND_NOR_orient};
	  NAND_NOR_INPUT:   crif.read_data = {30'b0, crif.NAND_NOR_b, crif.NAND_NOR_a};
	  NAND_NOR_OUTPUT:  crif.read_data = {31'b0, crif.NAND_NOR_out};
	  XOR_BUF_CONTROL:  crif.read_data = {31'b0, crif.XOR_BUF_orient};
	  XOR_BUF_INPUT:    crif.read_data = {30'b0, crif.XOR_BUF_b, crif.XOR_BUF_a};
	  XOR_BUF_OUTPUT:   crif.read_data = {31'b0, crif.XOR_BUF_out};
	  CRC_CONTROL:      crif.read_data = {30'b0, crif.crc_reset, crif.crc_start};
	  CRC_CONFIG:       crif.read_data = crif.crc_orient;
	  CRC_STATUS:       crif.read_data = {31'b0, crif.crc_ready};
	  CRC_INPUT:        crif.read_data = crif.crc_data_in;
	  CRC_OUTPUT:       crif.read_data = crif.crc_data_out;
	  default:          crif.read_data = 32'hbad2bad2;
	endcase // casez (register_select)
     end // always_comb
   
   // sequential logic for registers and write_data
   always_ff @(posedge CLK, negedge nRST)
     begin
	if (!nRST)
	  begin
	     crif.crc_data_in     <= '0;
	     crif.crc_reset       <= '0;
	     crif.crc_start       <= '0;
	     crif.crc_orient      <= '0;
	     crif.NAND_NOR_a      <= '0;
	     crif.NAND_NOR_b      <= '0;
	     crif.NAND_NOR_orient <= '0;
	     crif.XOR_BUF_a       <= '0;
	     crif.XOR_BUF_b       <= '0;
	     crif.XOR_BUF_orient  <= '0;
	  end // if (!nRST)
	else
	  begin
	     crif.crc_data_in     <= crif.write_enable && crif.register_select == CRC_INPUT        ? crif.write_data    : crif.crc_data_in;
	     crif.crc_start       <= next_crc_start;
	     crif.crc_reset       <= next_crc_reset;
	     crif.crc_orient      <= crif.write_enable && crif.register_select == CRC_CONFIG       ? crif.write_data    : crif.crc_orient;
	     crif.NAND_NOR_a      <= crif.write_enable && crif.register_select == NAND_NOR_INPUT   ? crif.write_data[0] : crif.NAND_NOR_a;
	     crif.NAND_NOR_b      <= crif.write_enable && crif.register_select == NAND_NOR_INPUT   ? crif.write_data[1] : crif.NAND_NOR_b;
	     crif.NAND_NOR_orient <= crif.write_enable && crif.register_select == NAND_NOR_CONTROL ? crif.write_data[0] : crif.NAND_NOR_orient;
	     crif.XOR_BUF_a       <= crif.write_enable && crif.register_select == XOR_BUF_INPUT    ? crif.write_data[0] : crif.XOR_BUF_a;
	     crif.XOR_BUF_b       <= crif.write_enable && crif.register_select == XOR_BUF_INPUT    ? crif.write_data[1] : crif.XOR_BUF_b;
	     crif.XOR_BUF_orient  <= crif.write_enable && crif.register_select == XOR_BUF_CONTROL  ? crif.write_data[0] : crif.XOR_BUF_orient;
	  end // else: !if(!nRST)
     end // always_ff @ (posedge CLK, negedge nRST)
endmodule // control_register

     
