// $Id: $
// File name:   tb_flex_counter.sv
// Created:     9/18/2014
// Author:      Manik Singhal
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: testbench for a flexible counter

`timescale 1ns / 10ps

module tb_flex_counter();
  
  localparam clkprd = 2.5;
  
  reg tb_clk;
  reg tb_c_en;
  reg tb_nrst;
  reg tb_clr;
  reg [3:0] tb_roll_val;
  reg [3:0] tb_cout;
  reg tb_rover;
  
  
  flex_counter DUT(.clk(tb_clk),.n_rst(tb_nrst),.clear(tb_clr),.count_enable(tb_c_en),.rollover_val(tb_roll_val),.count_out(tb_cout),.rollover_flag(tb_rover));
  
  always 
    begin
      tb_clk = 1'b0;
		  #(clkprd/2.0);
		  tb_clk = 1'b1;
		  #(clkprd/2.0);
		end
	initial
	begin
	 tb_c_en = 0;
	 tb_nrst = 0;
	 tb_clr = 0;
	 tb_roll_val = 4'b1100;
	 #10 
	 tb_nrst = 1;
	 tb_c_en = 1;
	 #50
	 //tb_clr = 0;
	 tb_c_en = 0;
	 #10
	 tb_nrst = 0;
	 #10
	 tb_c_en = 1;
	 tb_nrst = 1;
	 #30
	 tb_c_en = 0;
	 
	end
	
	//checking for 14 rollover values
	/*genvar i;
	
	for (i = 2; i < 16; i = i + 1)
	 begin
	   tb_roll_val = i;
	   #(2.5*i);
	   assert (tb_rover == 1) $info("the %d rollover test: PASSED", i);
	   else $error("the %d rollover test: FAILED",i);
	 end*/
	 
	    
	   
	
	
	
endmodule
	
		  
   