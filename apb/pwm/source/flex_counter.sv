// $Id: $
// File name:   flex_counter.sv
// Created:     9/18/2014
// Author:      Manik Singhal
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: flexible n bit counter with defined rollover

module flex_counter
#(parameter NUM_CNT_BITS = 4)
( 
  input wire clk,
  input wire n_rst,
  input wire clear,
  input wire count_enable,
  input wire [NUM_CNT_BITS - 1 : 0] rollover_val,
  output wire [NUM_CNT_BITS - 1 :0] count_out,
  output reg rollover_flag
);

  reg [NUM_CNT_BITS - 1 : 0] temp_counter;
  reg [NUM_CNT_BITS - 1 :0] next_state;
  reg rollover_flag_c;

  //state_register
  always_ff @(posedge clk, negedge n_rst)
  begin
    if (!n_rst)
      begin
        temp_counter <= 0;
        rollover_flag <= 0;
      end
    else
      begin
        temp_counter <= next_state;
        rollover_flag <= rollover_flag_c ;
      end
  end
  
  //next _state logic
  always_comb
  begin
    next_state = (clear) ? ('0) : (!count_enable) ? temp_counter :(temp_counter == rollover_val) ? 1: temp_counter + 1;
     
        
        
    //if (temp_counter == rollover_val - 1)
    if (next_state == rollover_val)  
      begin
        rollover_flag_c = 1;
      end
    else
      begin
        rollover_flag_c = 0;
      end
  end
    
//output logic
  assign count_out = temp_counter;
  
endmodule

      
        
          
            
          
  
  
  

  