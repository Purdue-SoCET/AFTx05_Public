/*
:set expandtab
:set tabstop=4
:set shiftwidth=4
:retab

*/

`include "ahbl_defines.vh"
`include "ahbl_bus_mux_defines.vh"

import ahbl_common::*;
import ahbl_bus_mux_common::*;

module APhase_cache ( 
    input HCLK,
    input HRESETn,
    input ARB_SEL,
    
    aphase_c.in m_in, 
    aphase_c.out m_out );

    logic valid;

    always_ff @(posedge HCLK or negedge HRESETn)
    begin : latch
        if (!HRESETn) begin
           valid <= 0; 
 /*       end else begin
            if(m_in.HTRANS != 0) */
        end
    end : latch

    assign m_out.HADDR = m_in.HADDR;

endmodule : APhase_cache

 
