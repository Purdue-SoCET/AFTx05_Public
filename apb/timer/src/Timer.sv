// File name:   timer.sv
// Created:     1/26/2016
// Author:      Jacob Stevens
// Version:     1.0 
// Description: Timer peripheral accessed through an APB bus
//	

`include "apb_if.vh"
`include "timer_if.vh"
`include "timer_types_pkg.vh"
import timer_types_pkg::*;

module Timer 
#(
  parameter NUM_CHANNELS           = 8
)
(
  input wire HCLK, n_RST, 

  //APB_Slave Interface
  apb_if.apb_s apbif,

  //Timer Interface
  timer_if.timer timerif
);

    logic tim_clk, tim_overflow;
    logic [NUM_CHANNELS-1:0] edge_detected;
    logic [NUM_CHANNELS-1:0] compare_success, compare_output;
    
    /******************************** APB and Register Section *******************/
    // Timer Register Indices
    localparam IOS_IND          = 0;    //32'hXXXXX000
    localparam TCF_IND          = 1;    //32'hXXXXX004
    localparam TCNT_IND         = 2;    //32'hXXXXX008
    localparam TSCR_IND         = 3;    //32'hXXXXX00C
    localparam TOV_IND          = 4;    //32'hXXXXX010
    localparam TCR_IND          = 5;    //32'hXXXXX014
    localparam TIE_IND          = 6;    //32'hXXXXX018
    localparam TSCR2_IND        = 7;    //32'hXXXXX01C
    localparam FLG1_IND         = 8;    //32'hXXXXX020
    localparam FLG2_IND         = 9;    //32'hXXXXX024
    localparam TC0_IND          = 10;   //32'hXXXXX028
    localparam TC1_IND          = 11;   //32'hXXXXX02C
    localparam TC2_IND          = 12;   //32'hXXXXX030
    localparam TC3_IND          = 13;   //32'hXXXXX034
    localparam TC4_IND          = 14;   //32'hXXXXX038
    localparam TC5_IND          = 15;   //32'hXXXXX03C
    localparam TC6_IND          = 16;   //32'hXXXXX040
    localparam TC7_IND          = 17;   //32'hXXXXX044
    localparam NUM_REGISTERS    = 18;
    localparam NUM_TCn          = 1;
    //localparam NUM_TCn          = 8;			JOHN CHANGED THIS
    
    logic [31:0] apb_data;
    logic [NUM_REGISTERS-1:0][31:0] apb_read;
    logic [NUM_REGISTERS-1:0] wen;
    logic [NUM_CHANNELS-1:0] success;

    //-----------------------------------//
    // Register Types 
    //-----------------------------------//
    
    // Each register is instantiated as its own type.
    // This makes the code more verbose, as the registers
    // cannot be operated on altogether in a generate loop
    // but makes certain operations more clear and concise.
    IOSr IOS;
    TCFr TCF;
    TCNTr TCNT;
    TSCRr TSCR;
    TOVr TOV;
    TCRr TCR;
    TIEr TIE;
    TSCR2r TSCR2;
    FLG1r FLG1;
    FLG2r FLG2;
    TCNr [7:0] TCN;

    APB_SlaveInterface_timer #(
        .NUM_REGS(NUM_REGISTERS),
        .ADDR_OFFSET(0)
    ) apbs (
        .clk(HCLK),
        .n_rst(n_RST),
        
        // inputs from APB Bridge
        .PADDR(apbif.PADDR),
        .PWDATA(apbif.PWDATA),
        .PENABLE(apbif.PENABLE),
        .PWRITE(apbif.PWRITE),
        .PSEL(apbif.PSEL),
        // output to APB Bridge
        .PRDATA(apbif.PRDATA),
     
        // input data from slave registers
        .read_data(apb_read),
        // output to slave registers
        .w_enable(wen),
        .w_data(apb_data)
    );

    //--------------------------------------//
    // APB Writing to Slave Registers
    //-------------------------------------//
    always_ff @ (posedge HCLK, negedge n_RST) begin
        if(~n_RST) begin
            IOS <= '0;
            TSCR <= '0;
            TOV <= '0;
            TCR <= '0;
            TIE <= '0;
            TSCR2 <= '0;
            //FLG1 <= '0;
            //FLG2 <= '0;
        end
        else if (wen[IOS_IND]) IOS <= apb_data[31:0];
        else if (wen[TSCR_IND]) TSCR <= apb_data[31:0];
        else if (wen[TOV_IND]) TOV <= apb_data[31:0];
        else if (wen[TCR_IND]) TCR <= apb_data[31:0];
        else if (wen[TIE_IND]) TIE <= apb_data[31:0];
        else if (wen[TSCR2_IND]) TSCR2 <= apb_data[31:0];
        //else if (wen[FLG1_IND]) FLG1 <= apb_data[31:0];
        //else if (wen[FLG2_IND]) FLG2 <= apb_data[31:0];
    end



always_ff @ (posedge HCLK, negedge n_RST) begin

        // TCF must be cleared after one cycle
        if(~n_RST)
            TCF <= '0;
        else if (wen[TCF_IND])
            TCF <= apb_data[31:0];
        else
            TCF <= '0;
end


always_ff @ (posedge HCLK, negedge n_RST) begin   
        // The Interrupt Registers have unique write conditions
        if (~n_RST) begin
            FLG1 <= '0;
            FLG2 <= '0;
        end else if (wen[FLG1_IND])
            FLG1 <= FLG1 & ~apb_data;
        else if (wen[FLG2_IND])
            FLG2 <= FLG2 & ~apb_data;
        else begin
            FLG1.TF <= ((edge_detected & ~IOS.IOS) | (compare_success & IOS.IOS)) | FLG1.TF;
            FLG2.TOVF <= tim_overflow | FLG2.TOVF;
        end
 
end


    //The TCN registers have unique write conditions
    genvar i;
    generate
        for(i = 0; i < NUM_TCn; i++) begin: TCn_write_slave_regs
            always_ff @ (posedge HCLK, negedge n_RST) begin
                if(~n_RST)
                    TCN[i] <= '0;
                else if (wen[NUM_REGISTERS-NUM_TCn+i] & IOS.IOS[i])
                    //Register TCj can only be written to when the correspending
                    //j-th bit is set in the IOS register.
                    TCN[i] <= apb_data[31:0];
                else if (!IOS.IOS[i] & edge_detected[i])
                    TCN[i] <= TCNT;
            end
        end
    endgenerate

    //-------------------------------------//
    // APB Reading from Slave Registers
    //------------------------------------//
    assign apb_read[IOS_IND] = IOS;
    assign apb_read[TCF_IND] = '0;
    assign apb_read[TCNT_IND] = TCNT;
    assign apb_read[TSCR_IND] = TSCR;
    assign apb_read[TOV_IND] = TOV;
    assign apb_read[TCR_IND] = TCR;
    assign apb_read[TIE_IND] = TIE;
    assign apb_read[TSCR2_IND] = TSCR2;
    assign apb_read[FLG1_IND] = FLG1;
    assign apb_read[FLG2_IND] = FLG2;
    generate
        for(i = 0; i < NUM_TCn; i++) begin : generate_r_data_TCN
            assign apb_read[NUM_REGISTERS-NUM_TCn+i] = TCN[i];
        end
    endgenerate

/*****************************************************************************/
    clock_divider clkdiv(       .HCLK(HCLK),
                                .n_RST(n_RST),
                                .PRE(TSCR2.PRE),
                                .tim_clk(tim_clk));
    
    //----------------------------------//
    // Input Capture
    //----------------------------------//    
    logic [NUM_CHANNELS-1:0] r_signal_synch;
    always_ff @ (posedge HCLK, negedge n_RST)
    begin
        if (~n_RST)
            r_signal_synch <= 0;
        else
            r_signal_synch <= timerif.r_data;
    end

    edge_detector_timer edge_detect(  .clk(HCLK),
                                .n_rst(n_RST),
                                .signal(r_signal_synch),
                                .EDGEnA(TCR.EDGEnA),
                                .EDGEnB(TCR.EDGEnB),
                                .edge_detected(edge_detected));
    
    //----------------------------------//
    // Output Compare
    //----------------------------------//
    generate
        for(i = 0; i < NUM_CHANNELS; i++) begin: compare_succ_gen
            assign compare_success[i] = (TCNT == TCN[i]);
        end
    endgenerate

    generate
        for(i = 0; i < NUM_CHANNELS; i++) begin: compare_output_gen
            assign success[i] = compare_success[i] | TCF.TCF[i];
            always_ff @ (posedge HCLK, negedge n_RST) begin
                if (!n_RST)
                    compare_output[i] <= '0;
                else if (TOV.TOV[i] & tim_overflow)
                    compare_output[i] <= ~compare_output[i];
                else if (!TCR.OM[i] & TCR.OL[i] & success[i])
                    compare_output[i] <= ~compare_output[i];
                else if (TCR.OM[i] & !TCR.OL[i] & success[i])
                    compare_output[i] <= 0;
                else if (TCR.OM[i] & TCR.OL[i] & success[i])
                    compare_output[i] <= 1;
            end
        end
    endgenerate

    generate
        for(i = 0; i < NUM_CHANNELS; i++) begin: output_enable_gen
            assign timerif.output_en[i] = IOS[i] && (TCR.OM[i] || TCR.OL[i]);
        end
    endgenerate

    //assign timerif.w_data = compare_output;

  assign timerif.timer_bidir = timerif.output_en ? timerif.w_data : 1'bZ; 


  always @ (posedge HCLK)
  begin
    timerif.r_data <= timerif.timer_bidir;
    timerif.w_data <= compare_output;;
  end




    //-----------------------------------//
    // 32 bit counter
    //-----------------------------------//
    always_ff @ (posedge tim_clk, negedge n_RST)
    begin
        if(!n_RST)
            TCNT <= '0;
        else if (TSCR2.TCRE & success[NUM_CHANNELS-1])
            TCNT <= '0;
        /* TODO: REMOVE THIS PART! HERE FOR TESTING *ONLY* */
        else if (wen[TCNT_IND])
            TCNT <= apb_data[31:0];
        else if (TSCR.TCREN)
            TCNT <= TCNT + 1;
    end

    assign tim_overflow = (TCNT == 32'hFFFF_FFFF) && TSCR.TCREN && ~TSCR2.TCRE;

    //----------------------------------//
    // Interrupt Generation
    //----------------------------------//
    logic [NUM_CHANNELS-1:0] channel_irq_r;
    logic tim_irq_r;

    //An interrupt occurs on a rising edge in FLG1 or FLG2
    always_ff @ (posedge HCLK, negedge n_RST) begin
        if(~n_RST) begin
            channel_irq_r <= '0;
            tim_irq_r <= '0;
        end
        else begin
            channel_irq_r <= FLG1.TF;
            tim_irq_r <= FLG2.TOVF;
        end
    end
    
    //assign timerif.IRQ[7:0] = TIE.TIE & (~channel_irq_r & FLG1.TF);			JOHN CHANGED THIS
    //assign timerif.IRQ[8] = TSCR2.TOI & (~tim_irq_r & FLG2.TOVF);			JOHN CHANGED THIS

endmodule
