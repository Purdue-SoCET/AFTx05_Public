/*
  John Skubic
  
  11/5/14

  Test bench for newly generalized APB Slave interface
*/
`timescale 1ns / 100ps

module tb_pwm();
  
  localparam DELAY = 1;
  localparam PERIOD = 20;
  localparam ADDRESS = 32'h80000000;
  localparam BYTES_PER_WORD = 4;
  localparam NUM_REGS = 28;

  localparam NUM_CHANNELS = 4;
  localparam NUM_REG_PER_CHAN = 3;
  localparam PERIOD_IND = 0;
  localparam DUTY_IND = 1;
  localparam COUNT_IND = 2;
  
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

  logic [NUM_CHANNELS-1:0] pwm_out;

  logic [NUM_CHANNELS-1:0][31:0] duty;
  logic [NUM_CHANNELS-1:0][31:0] period;
  logic [NUM_CHANNELS-1:0][31:0] control;

  assign duty = {
    32'h1, 32'h4, 32'h8, 32'ha
  };

  assign period = {
    32'h10, 32'h10, 32'h10, 32'h10
  };

  assign control = {
    32'b0001, 32'b0011, 32'b0101, 32'b0111
  };

  pwm #(.NUM_CHANNELS(NUM_CHANNELS)) DUT (
      .clk(clk),
      .n_rst(n_rst), 
      .paddr(PADDR), 
      .pwdata(PWDATA), 
      .psel(PSEL), 
      .penable(PENABLE), 
      .pwrite(PWRITE), 
      .prdata(PRDATA), 
      .pwm_out(pwm_out)
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
    
    
    //begin testing
    
    @(negedge clk);
    n_rst = 1'b1;
    
    //TEST1 - 6: write to address 1 - 6
    for(i = 0; i < NUM_CHANNELS; i ++) begin
      $info("Writing to PeriodAddr %h DutyAddr %h ControlAddr %h", 
        ((i * 3) + PERIOD_IND * 4), 
        ((i * 3) + DUTY_IND * 4), 
        ((i * 3) + COUNT_IND * 4));

      //write period
      @(posedge clk);
      //address phase
      PADDR = ((i * 3) + PERIOD_IND) * 4;
      PWDATA = period[i];
      PSEL = 1;
      PWRITE = 1;
      PENABLE = 0;
      @(posedge clk);
      //data phase
      PENABLE = 1;
      #(DELAY);

      //write duty
       @(posedge clk);
      //address phase
      PADDR = ((i * 3) + DUTY_IND) * 4;
      PWDATA = duty[i];
      PSEL = 1;
      PWRITE = 1;
      PENABLE = 0;
      @(posedge clk);
      //data phase
      PENABLE = 1;
      #(DELAY);

      //write control
       @(posedge clk);
      //address phase
      PADDR = ((i * 3) + COUNT_IND) * 4;
      PWDATA = control[i];
      PSEL = 1;
      PWRITE = 1;
      PENABLE = 0;
      @(posedge clk);
      //data phase
      PENABLE = 1;
      #(DELAY);

    end

    @(posedge clk);
    PSEL = 0;

    #(PERIOD * 16 * 4);
  end    

endmodule