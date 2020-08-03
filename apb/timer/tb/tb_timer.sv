/*
  Author: Jacob R. Stevens
  Date: 2/16/2016
  Version: 1.0
  Description: Test bench for timer
*/

`timescale 1ns / 100ps
`include "apb_if.vh"
`include "timer_if.vh"

module tb_timer();
    localparam WIDTH = 8;    
    localparam PERIOD = 20;
    localparam DELAY = 1;

    localparam IOS          = 32'h80010000;
    localparam TCF          = 32'h80010004;
    localparam TCNT         = 32'h80010008;
    localparam TSCR         = 32'h8001000C;
    localparam TOV          = 32'h80010010;
    localparam TCR          = 32'h80010014;
    localparam TIE          = 32'h80010018;
    localparam TSCR2        = 32'h8001001C;
    localparam FLG1         = 32'h80010020;
    localparam FLG2         = 32'h80010024;
    localparam TC0          = 32'h80010028;
    localparam TC1          = 32'h8001002C;
    localparam TC2          = 32'h80010030;
    localparam TC3          = 32'h80010034;
    localparam TC4          = 32'h80010038;
    localparam TC5          = 32'h8001003C;
    localparam TC6          = 32'h80010040;
    localparam TC7          = 32'h80010044;

    logic clk, n_rst;
    timer_if #(.NUM_CHANNELS(8)) timerif();
    apb_if apbsif();
    virtual apb_if.apb_m apbmif;
    
    timer DUT(
        .HCLK(clk),
        .n_RST(n_rst),
        .apbif(apbsif),
        .timerif(timerif)
    );

    // Clock
    always begin
        clk = 1'b0;
        #(PERIOD/2);
        clk = 1'b1;
        #(PERIOD/2);
    end

    initial begin
        apbmif = apbsif;
        apbmif.PADDR = 0;
        apbmif.PENABLE = 0;
        apbmif.PWRITE = 0;
        apbmif.PSEL = 0;
        apbmif.PWDATA = 0;
        timerif.r_data = '0;
        n_rst = 1'b0;
        #(PERIOD);
        n_rst = 1'b1;
        @(posedge clk);
        #(PERIOD);

        // begin testing
        
        /********** CHECK THAT TIMER IS NOT RUNNING UNTIL ENABLED ************/
        #(PERIOD*5);
        apbRead(TCNT, 0, "Timer correctly disabled", "Timer incorrectly running");

        /**************** TEST NORMAL COUNTER FUNCTIONALITY ******************/

        apbWrite(TSCR, 32'h80);
        #(PERIOD*8);
        apbRead(TCNT, 32'hA, "Correct timer count at 10", "Incorrect timer count at 10");

        /**************** TEST COUNTER AT /8 Frequency ***********************/

        apbWrite(TSCR2, 32'h3);
        #(PERIOD*8);
        apbRead(TCNT, 32'd16, "Correct timer count at 16", "Incorrect timer count");
        apbWrite(TSCR2, 32'h0);

        /******* INPUT CAPTURE SINGLE RISING EDGE WITH INTERRUPT *************/

        apbWrite(TCR, 32'h1);
        apbWrite(TIE, 32'h1);
        #(PERIOD*5);
        timerif.r_data = 32'h1;
        #(2*PERIOD)
        assert (timerif.IRQ[0] == 1)
            $display("IRQ correct for rising edge of channel 0");
        else
            $error("Missed IRQ");
        apbRead(TC0, 32'h1D, "Correct input capture at 29", "Incorrect input capture");

        /*************** TEST IRQ CLEAR ONLY ON WRITING A 1 ******************/  

        // Write a 0 to FLG1[0]
        apbWrite(FLG1, 0);
        // Read from FLG1
        apbRead(FLG1, 32'h01, "Channel 0 flag correctly still set", "Channel 0 flag incorrectly cleared");
        // Write a 1 to FLG1[0]
        apbWrite(FLG1, 32'h1);
        // Read from FLG1
        apbRead(FLG1, 32'h00, "Channel 0 flag correctly cleared", "Channel 0 flag incorrectly still set");
        
        /********** TEST OUTPUT COMPARE AT COUNT 42 ON CHANNEL 1 *************/
        
        apbWrite(IOS, 32'h2);
        apbWrite(TC1, 32'd65);
        apbWrite(TCR,  32'h0202_0000);
        apbWrite(TIE, 32'h2);
        #(PERIOD*5);
        #(DELAY);
        assert(timerif.IRQ[1] == 1)
            $display("IRQ correct for output compare at 65");
        else
            $error("Missed IRQ on channel 1");

        assert(timerif.w_data[1] == 1)
            $display("Write data correctly set at output compare at 65");
        else
            $error("Write data not correctly set at output compare at 65");

        /*********** CLEAR COUNTER ON SUCCESSFUL CHANNEL 7 OC  ***************/
        apbWrite(IOS, 32'h80);
        apbWrite(TC7, 32'd80);
        apbWrite(TCR, 32'h8000_0000);
        apbWrite(TSCR2, 32'b1000000);
        #(PERIOD*3);
        apbRead(TCNT, 32'h2, "Correct counter value of 2 after clear", "Incorrect clear");
        
        /*************** FORCE OUTPUT COMPARE ON CHANNEL 7 *******************/
        #(PERIOD*10);
        apbWrite(TCF, 32'h80);
        apbRead(TCNT, 32'h1, "Correct counter value of 1 after forced clear", "Incorrect force clear");
        apbRead(TCF, 32'h0, "TCF correctly cleared after a cycle", "TCF incorrectly still set");
        /***************** RESET TIMER ON OVERFLOW ***************************/
        /*NOTE: IF THESE ASSERTS FAIL MAKE SURE TCNT IS WRITEABLE FOR TESTING*/
        apbWrite(TOV, 32'h1);
        apbWrite(IOS, 32'h1);
        apbWrite(TSCR2, 32'h80);
        apbWrite(TCNT, 32'hFFFF_FFFA);
        #(PERIOD*5);
        #(DELAY);
        assert(timerif.IRQ[8] == 1)
            $display("IRQ correct for timer overflow");
        else
            $error("Missed IRQ on timer overflow");
        assert(timerif.w_data[0] == 1)
            $display("Output correctly toggled on overflow");
        else
            $error("Output not correctly toggled on overflow");
        /*********************************************************************/
        #(PERIOD*5);
        $finish; 
    end
    
    /* Write the data to the given APB address */
    task apbWrite(input bit[31:0] addr, input bit[31:0] data);
        @(posedge clk);
        #(DELAY);
        apbmif.PSEL = 1;
        apbmif.PWRITE = 1;
        apbmif.PADDR = addr;
        apbmif.PWDATA = data;
        @(posedge clk);
        apbmif.PENABLE = 1;
        #(PERIOD);
        apbmif.PENABLE = 0;
        apbmif.PSEL = 0;
        #(PERIOD);
    endtask

    /* Set up a read for the given address and check the validity as needed*/
    task apbRead(input bit [31:0] addr, input bit [31:0] expected,
                    input string success, input string fail);
        @(posedge clk);
        #(DELAY);
        apbmif.PSEL = 1;
        apbmif.PWRITE = 0;
        apbmif.PADDR = addr;
        @(posedge clk);
        apbmif.PENABLE = 1;
        #(DELAY);
        
        assert(apbmif.PRDATA == expected)
            $display("%s", success);
        else
            $error("%s: %d", fail, apbmif.PRDATA);
        
        #(PERIOD);
        apbmif.PENABLE = 0;
        apbmif.PSEL = 0;
        #(PERIOD);
    endtask

endmodule
