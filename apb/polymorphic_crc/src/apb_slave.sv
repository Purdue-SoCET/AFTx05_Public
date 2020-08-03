/*
 Isaiah Grace
 Igrace@purdue.edu
 
  This module is the APB slave that arbitrates bus operations and translates them to the register control module
 
 */

// Inlcude data types and interfaces
`include "POLI_types_pkg.vh"
`include "apb_slave_if.vh"

module apb_slave (
		  input CLK,
		  input nRST,
		  apb_slave_if.slave apbif
		  );
   // Import types
   import POLI_types_pkg::*;

   // Local signals and registers
   //logic [WORD_SIZE-1:0] data_buff;
   logic 		 nxt_PREADY;
   
   
   // PRDATA can always be the data in the output buffer, It doesn't matter if it's garbage when PSEL is LOW
   assign apbif.PRDATA = apbif.PREADY ? apbif.read_data : 32'hbad5bad5;
   //data_buff;

   // write_data can be wired to PWDATA all the time, we will only assert the control signals when appropriate
   assign apbif.write_data = apbif.PWDATA;

   // This is an EXTREEMLY simple state machine that makes PREADY high for the second cycle of a transfer
   // NOTE: This assumes NO wait states
   assign nxt_PREADY = apbif.PSEL & ~apbif.PREADY;

   // write_enable to the control_register should only be high is the Access phase of a write transfer
   assign apbif.write_enable = apbif.PREADY & apbif.PWRITE;

   always_comb
     begin
	// Register select logic
	// Maps the APB bus addresses to the regsel_t type to pass on to control register
	casez (apbif.PADDR)
	  NAND_NOR_CONTROL_ADDR: apbif.register_select = NAND_NOR_CONTROL;
	  NAND_NOR_INPUT_ADDR:   apbif.register_select = NAND_NOR_INPUT;
	  NAND_NOR_OUTPUT_ADDR:  apbif.register_select = NAND_NOR_OUTPUT;
	  
	  XOR_BUF_CONTROL_ADDR:  apbif.register_select = XOR_BUF_CONTROL;
	  XOR_BUF_INPUT_ADDR:    apbif.register_select = XOR_BUF_INPUT;
	  XOR_BUF_OUTPUT_ADDR:   apbif.register_select = XOR_BUF_OUTPUT;

	  CRC_CONTROL_ADDR:      apbif.register_select = CRC_CONTROL;
	  CRC_CONFIG_ADDR:       apbif.register_select = CRC_CONFIG;
	  CRC_STATUS_ADDR:       apbif.register_select = CRC_STATUS;
	  CRC_INPUT_ADDR:        apbif.register_select = CRC_INPUT;
	  CRC_OUTPUT_ADDR:       apbif.register_select = CRC_OUTPUT;
	  
	  default:               apbif.register_select = BAD_ADDR;
	endcase // casez (apbif.PADDR)
     end // always_comb

   
   always_ff @(posedge CLK, negedge nRST)
     begin
	if (nRST == 1'b0)
	  begin
	     //data_buff <= 0;
	     apbif.PREADY <=0;
	  end
	else
	  begin
	     //data_buff <= apbif.read_data;
	     apbif.PREADY <= nxt_PREADY;
	  end
     end // always_ff @ (posedge CLK, negedge nRST)
endmodule // apb_slave

