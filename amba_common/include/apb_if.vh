// File name:   apb_if.vh
// Created:     9/10/2015
// Author:      Erin Rasmussen
// Version      1.0
// Description: Interface for APB

`ifndef APB_IF_VH
`define APB_IF_VH

interface apb_if;
   logic [31:0] PRDATA;
   logic [31:0] PWDATA;
   logic [31:0] PADDR;
   logic 	PWRITE, PENABLE, PSEL;
   
   modport apb_m (
     input PRDATA,
     output PWDATA, PADDR, PWRITE, PENABLE, PSEL
   );
  
   modport apb_s (
     input PWDATA, PADDR, PWRITE, PENABLE, PSEL,
     output PRDATA
   );


endinterface // apb_if

`endif //  `ifndef APB_IF_VH

