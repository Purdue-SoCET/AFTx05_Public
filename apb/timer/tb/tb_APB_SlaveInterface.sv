/*
  John Skubic
  
  11/5/14

  Test bench for newly generalized APB Slave interface
*/
`timescale 1ns / 100ps

module tb_APB_SlaveInterface();
  
  localparam DELAY = 1;
  localparam PERIOD = 20;
  localparam ADDRESS = 32'h80000000;
  localparam BYTES_PER_WORD = 4;
  localparam NUM_REGS = 28;
  
  reg clk, n_rst;
  reg [31:0] PADDR, PWDATA;
  reg [NUM_REGS-1:0][31:0] read_data;
  reg PENABLE, PWRITE, PSEL;

  wire [NUM_REGS-1:0] w_enable;
  wire [NUM_REGS-1:0] r_enable;
  wire [31:0] PRDATA;
  wire pslverr;
  wire [31:0] w_data;
  
  integer i;
  
  APB_SlaveInterface  
  #(
    .NUM_REGS(NUM_REGS)
  )
  DUT (
    //inputs
    .clk(clk),
    .n_rst(n_rst),
    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .read_data(read_data), //num registers wide
    //outputs
    .w_enable(w_enable),
    .r_enable(r_enable),
    .PRDATA(PRDATA),
    .pslverr(pslverr),
    .w_data(w_data)
  );
  
   //clock generation
  always begin
    clk = 1'b0;
    #(PERIOD / 2);
    clk = 1'b1;
    #(PERIOD / 2);
  end
  
  initial begin
    //setup tb variables
    n_rst = 1'b0;
    PADDR = 0;
    PENABLE = 0;
    PWRITE = 0;
    PSEL = 0;
    PWDATA = 0;
    
    for(i = 0; i < NUM_REGS; i++) begin
      read_data[i] = $random;
    end
    
    //begin testing
    
    @(negedge clk);
    n_rst = 1'b1;
    
    //TEST1 - 6: write to address 1 - 6
    for(i = 0; i < NUM_REGS; i ++) begin
      @(posedge clk);
      //address phase
      PADDR = ADDRESS + (BYTES_PER_WORD * i);
      PWDATA = $random;
      PSEL = 1;
      PWRITE = 1;
      PENABLE = 0;
      @(posedge clk);
      //data phase
      PENABLE = 1;
      #(DELAY);
      if (w_enable == (1 << i)) 
	$display("Correct write enable for register %.0d",i);
      else
	$error("Incorrect write enable for register %.0d, received %h expected %h, address %h",i,w_enable, 1<<i, PADDR);
    
      if (PWDATA == w_data) 
	$display("Correct write data to register %.0d",i);
      else
	$error("Incorrect write data to register %.0d, expected %h received %h", i, PWDATA, w_data);
    end
    
    //reset the bus
    @(posedge clk);
    PADDR = 0;
    PSEL = 0;
    PWRITE = 0;
    PENABLE = 0;
    
    //TEST7-12 : Read from address 1 - 6
    for(i = 0; i < NUM_REGS; i ++) begin
      @(posedge clk);
      //address phase
      PADDR = ADDRESS + (BYTES_PER_WORD * i);
      PSEL = 1;
      PENABLE = 0;
      @(posedge clk);
      PENABLE = 1;
      #(DELAY);
      if(PRDATA == read_data[i]) 
	$display("Correct data read for register %.0d",i);
      else 
	$error("Incorrect data read for register %.0d, expected: %h received: %h",i , read_data[i], PRDATA);
    
      if (r_enable == (1 << i)) 
	$display("Correct read enable for register %.0d",i);
      else
	$error("Incorrect read enable for register %.0d, received %b, address %h",i,r_enable, PADDR);
    
    end
  end

endmodule