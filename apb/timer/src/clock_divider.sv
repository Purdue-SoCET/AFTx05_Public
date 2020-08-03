// File name:   clock_divider.sv
// Created:     1/28/2016
// Author:      Jacob Stevens
// Version:     1.0 
// Description: Produces a 50% duty cycle clock based on the PRE selection of
//              clock divisions 2^0 through 2^7

module clock_divider
(
    input logic HCLK, n_RST,
    input logic[2:0] PRE,
    output logic tim_clk
);
    // Clock Dividers:
    // Using multiple flipflops instead of a counter for different clock
    // divisions in order to keep a 50% duty cycles and to avoid having to use
    // parameters + math in order to calculate what to count up to for a division.
    logic clkdiv2, clkdiv4, clkdiv8, clkdiv16, clkdiv32, clkdiv64, clkdiv128;
    always_ff @ (posedge HCLK, negedge n_RST) begin
        if (!n_RST)
            clkdiv2 <= 0;
        else
            clkdiv2 <= ~clkdiv2;
    end 
    always_ff @ (posedge clkdiv2, negedge n_RST) begin
        if (!n_RST)
            clkdiv4 <= 0;
        else
            clkdiv4 <= ~clkdiv4;
    end 
    always_ff @ (posedge clkdiv4, negedge n_RST) begin
        if (!n_RST)
            clkdiv8 <= 0;
        else
            clkdiv8 <= ~clkdiv8;
    end 
    always_ff @ (posedge clkdiv8, negedge n_RST) begin
        if (!n_RST)
            clkdiv16 <= 0;
        else
            clkdiv16 <= ~clkdiv16;
    end 
    always_ff @ (posedge clkdiv16, negedge n_RST) begin
        if (!n_RST)
            clkdiv32 <= 0;
        else
            clkdiv32 <= ~clkdiv32;
    end 
    always_ff @ (posedge clkdiv32, negedge n_RST) begin
        if (!n_RST)
            clkdiv64 <= 0;
        else
            clkdiv64 <= ~clkdiv64;
    end 
    always_ff @ (posedge clkdiv64, negedge n_RST) begin
        if (!n_RST)
            clkdiv128 <= 0;
        else
            clkdiv128 <= ~clkdiv128;
    end 

    always_comb begin
        case (PRE)
            3'b000: tim_clk = HCLK;
            3'b001: tim_clk = clkdiv2;
            3'b010: tim_clk = clkdiv4;
            3'b011: tim_clk = clkdiv8;
            3'b100: tim_clk = clkdiv16;
            3'b101: tim_clk = clkdiv32;
            3'b110: tim_clk = clkdiv64;
            3'b111: tim_clk = clkdiv128;
        endcase 
    end
endmodule
