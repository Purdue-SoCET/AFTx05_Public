// File name:   ahb2apb_if.vh
// Created:     9/10/2015
// Author:      Erin Rasmussen
// Version      1.0
// Description: Interface for AHB2APB

`ifndef AHB2APB_IF_VH
`define AHB2APB_IF_VH

`include "ahb_if.vh"
`include "apb_if.vh"

interface ahb2apb_if;
  parameter NUM_SLAVES = 2;
   
   // APB input
   logic [31:0] PRData_slave[NUM_SLAVES-1:0];
   
   logic [NUM_SLAVES-1:0]	PSEL_slave; //one hot select for apb slaves

   modport slave_decode (
     input PRData_slave,
     output PSEL_slave
   );
   
endinterface // ahb2apb_if

`endif //  `ifndef AHB2APB_IF_VH


   
   
