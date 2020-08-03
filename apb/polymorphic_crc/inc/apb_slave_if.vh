/*
 Isaiah Grace
 igrace@purdue.edu
 git: igrace
 
 This is the interface for the APB slave module to interface witht the APB bus, and the control registers module

*/

`ifndef APB_SLAVE_IF_VH
 `define APB_SLAVE_IF_VH

// includes:
 `include "POLI_types_pkg.vh"

interface apb_slave_if;
   
   // Import types
   import POLI_types_pkg::*;
   
   // APB related signals
   // Slave Inputs
   logic [WORD_SIZE-1:0] PWDATA; // Data Input
   logic [WORD_SIZE-1:0] PADDR;  // Address Input
   //logic 		 PCLK;    // TODO: Get confirmation that this is not necessary as we will have a single clock domain for the entitre chip
   logic 		 PWRITE;  // HIGH = write operation, LOW = read operation
   logic 		 PSEL;    // HIGH = module selected, LOW = module NOT selected, ignore all other signals
   logic 		 PENABLE; // HIGH = read/write phase of transaction. NOT address phase
   
   // Slave Outputs:
   logic 		 PREADY;  // HIGH = PRDATA is valid or write has completed. This will tell the APB Master to terminate the transaction
   logic [WORD_SIZE-1:0] PRDATA;  // Data Output
   //logic 		 PSLVERR; // Indicates an error has occured, only valid while PREADY is also high. TODO: Do we need this signal?
   
   // Control register related signals
   // Slave Inputs
   logic [WORD_SIZE-1:0] read_data;

   // Slave Outputs
   logic [WORD_SIZE-1:0] write_data;
   logic 		 write_enable;
   regsel_t              register_select; // Check POLI_types_pkg.vh for enumeration definition
   
   
   // controller ports to ram and caches
   modport slave (
		  input  PWDATA, PADDR, PWRITE, PSEL, PENABLE,
		  input  read_data, 
		  output PREADY, PRDATA,
		  output write_data, write_enable, register_select
		  );

endinterface // apb_slave_if

`endif //  `ifndef APB_SLAVE_IF_VH

