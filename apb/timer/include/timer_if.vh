/*
    Timer top level interface

    Author: Jacob R. Stevens
    Date: 1/26/2016
    Version: v1.0
*/

`ifndef TIMER_IF_VH
`define TIMER_IF_VH

interface timer_if(inout wire timer_bidir);

    parameter NUM_CHANNELS = 1;
    //parameter NUM_CHANNELS = 8;			JOHN CHANGED THIS 


    logic [NUM_CHANNELS :0] IRQ;
    logic [NUM_CHANNELS - 1:0] r_data, w_data, output_en;
    //wire timer_bidir [NUM_CHANNELS - 1: 0];

    modport timer(
        output IRQ, w_data, output_en, r_data,
        inout timer_bidir
    );

endinterface

`endif    
