/*
  John Skubic
  
  11/5/14

  Test bench for gpio

*/

`timescale 1ns / 100ps
`include "apb_if.vh"
`include "gpio_if.vh"

module tb_Gpio();
  
  localparam DELAY = 1;
  localparam PERIOD = 20;
  
  localparam DATA_ADDRESS = 32'h80001000;
  localparam EN_ADDRESS = 32'h80001004;
  localparam INTR_EN_ADDR = 32'h80001008;
  localparam POS_EN_ADDR = 32'h8000100C;
  localparam NEG_EN_ADDR = 32'h80001010;
  localparam INTR_CLR_ADDR = 32'h80001014;
  localparam INTR_STAT_ADDR = 32'h80001018;
  
  
  gpio_if #(.NUM_PINS(8)) gpioif();
  apb_if apbif();
 
  reg clk, n_rst;
  //reg [31:0] PADDR, PWDATA;
  //reg PENABLE, PWRITE, PSEL;
  //wire [31:0] PRDATA;
  wire pslverr;
  wire [7:0]pins;
  reg pin_control;
  reg [7:0] pin_w_data;
  //wire [7:0] gpio_r;
  //wire [7:0] gpio_w;
  //wire [7:0] gpio_en;
  //wire interrupt;

  genvar i;
  
  Gpio  DUT (
    //inputs
    .clk(clk),
    .n_rst(n_rst),
    .apbif(apbif),
    .gpioif(gpioif)     

  );

   //clock generation
  always begin
    clk = 1'b0;
    #(PERIOD / 2);
    clk = 1'b1;
    #(PERIOD / 2);
  end

  generate for(i = 0; i <= 7; i = i + 1) begin : gen_block_gpio
    assign pins[i] = (gpioif.en_data[i] == 1) ? gpioif.w_data[i] : pin_w_data[i];
    assign gpioif.r_data[i] = pins[i];
  end
  endgenerate
  
  initial begin
    //setup tb variables
    n_rst = 1'b0;
    apbif.PADDR = 0;
    apbif.PENABLE = 0;
    apbif.PWRITE = 0;
    apbif.PSEL = 0;
    apbif.PWDATA = 0;
    pin_control = 0;
        
    //begin testing
    
    @(negedge clk);
    n_rst = 1'b1;
    
    //write to gpio
    @(posedge clk);
    apbif.PWDATA = 32'hAA;
    apbif.PADDR = DATA_ADDRESS;
    apbif.PSEL = 1'b1;
    apbif.PWRITE = 1'b1;
    
    @(posedge clk);
    apbif.PENABLE = 1'b1;
    
    //write to ddr
    @(posedge clk);
    apbif.PENABLE = 0;
    apbif.PADDR = EN_ADDRESS;
    apbif.PWDATA = 32'hFF;
    @(posedge clk);
    apbif.PENABLE = 1;

    //allow synchronizers to catch up
    @(posedge clk);
    apbif.PSEL = 0;
    apbif.PENABLE = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    
    //read from gpio (should be previously written data)
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PENABLE = 0;
    apbif.PWRITE = 0;
    apbif.PADDR = DATA_ADDRESS;
    
    @(posedge clk);
    apbif.PENABLE = 1'b1;
    #(DELAY);
    if(apbif.PRDATA[7:0] == 8'hAA)
      $display("Correct gpio read.");
    else
      $error("Incorrect gpio read, expected %h but received %h.", 8'hAA, apbif.PRDATA[7:0]);
    
    
    //write to ddr pins
    @(posedge clk);
    apbif.PENABLE = 0;
    apbif.PWRITE = 1;
    apbif.PADDR = EN_ADDRESS;
    apbif.PWDATA = 8'h00;
    
    @(posedge clk);
    apbif.PENABLE = 1;

    //allow synchronizers to catch up
    @(posedge clk);
    apbif.PSEL = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    //read from pins
    @(posedge clk);
    //write to pins directly and read
    pin_control = 1'b1;
    pin_w_data = 8'h55;

    //allow synchronizers to catch up
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PENABLE = 0;
    apbif.PWRITE = 0;
    apbif.PADDR = DATA_ADDRESS;
    
    @(posedge clk);
    apbif.PENABLE = 1;
    #(DELAY);
    if(apbif.PRDATA[7:0] == 8'h55)
      $display("Correct gpio read.");
    else
      $error("Incorrect gpio read, expected %h but received %h.", 8'h55, apbif.PRDATA[7:0]);
    
    
    @(posedge clk);
    apbif.PADDR = 0;
    apbif.PENABLE = 0;
    apbif.PWRITE = 0;
    apbif.PSEL = 0;
    apbif.PWDATA = 0;
    pin_w_data = '0;

    //check interrupt functionality

    @(posedge clk);
    @(posedge clk);

    //setup all pins as inputs
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = EN_ADDRESS;
    apbif.PWDATA = 32'h00;
    @(posedge clk);
    apbif.PENABLE = 1;

    //ENABLE INTERRUPTS 
     @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = INTR_EN_ADDR;
    apbif.PWDATA = 32'h055; //0101 0101
    @(posedge clk);
    apbif.PENABLE = 1;

    //ASSIGN POSEDGE 
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = POS_EN_ADDR;
    apbif.PWDATA = 32'h011; //0001 0001
    @(posedge clk);
    apbif.PENABLE = 1;


    //ASSIGN NEGEDGE 
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = NEG_EN_ADDR;
    apbif.PWDATA = 32'h044; //0100 0100
    @(posedge clk);
    apbif.PENABLE = 1;


    @(posedge clk);
    apbif.PSEL = 0;

    //ASSIGN pins to get posedge interrupts
    @(posedge clk);
    pin_w_data = 8'hFF;

    $display("Waiting for interrupt...");
    @(posedge gpioif.interrupt);

    //read status register
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 0;
    apbif.PENABLE = 0;
    apbif.PADDR = INTR_STAT_ADDR;
    @(posedge clk);
    apbif.PENABLE = 1;
    #(DELAY);

    if(apbif.PRDATA == 32'h11)
      $display("CORRECT: Posedge interrupt value.");
    else
      $error("ERROR: Incorrect Posedge interrupt value.");

    //write to clear interrupt values
    @(posedge clk);
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = INTR_CLR_ADDR;
    apbif.PWDATA = 32'h001; 
    @(posedge clk);
    apbif.PENABLE = 1;

    @(posedge clk);
    apbif.PSEL = 0;
    @(posedge clk);

    #(DELAY);

    if(~gpioif.interrupt)
      $display("CORRECT: Interrupt cleared successfully.");
    else
      $error("ERROR: Interrupt not cleared successfully.");

    //check negetive edge interrupt functionality
    pin_w_data = 8'h0F;

    @(posedge gpioif.interrupt);

    //read status register
    @(posedge clk);
    apbif.PSEL = 1;
    apbif.PWRITE = 0;
    apbif.PENABLE = 0;
    apbif.PADDR = INTR_STAT_ADDR;
    @(posedge clk);
    apbif.PENABLE = 1;
    #(DELAY);

    if(apbif.PRDATA == 32'h40)
      $display("CORRECT: Negedge interrupt value.");
    else
      $error("ERROR: Incorrect Negedge interrupt value.");


    //write to clear interrupt values
    @(posedge clk);
    apbif.PWRITE = 1;
    apbif.PENABLE = 0;
    apbif.PADDR = INTR_CLR_ADDR;
    apbif.PWDATA = 32'h001; 
    @(posedge clk);
    apbif.PENABLE = 1;

    @(posedge clk);
    apbif.PSEL = 0;
    @(posedge clk);

    #(DELAY);

    if(~gpioif.interrupt)
      $display("CORRECT: Interrupt cleared successfully.");
    else
      $error("ERROR: Interrupt not cleared successfully.");

    end

endmodule
