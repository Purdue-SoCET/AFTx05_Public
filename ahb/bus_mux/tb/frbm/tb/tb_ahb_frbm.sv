// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from The University of Southampton
// (c) COPYRIGHT 2010 The University of Southampton
// ALL RIGHTS RESERVED
// The entire notice above must be reproduced on all authorised
// copies and copies may only be made to the extent permitted
// by a licensing agreement from The University of Southampton.
//
// --------------------------------------------------------------------------
// Version and Release Control Information:
//
// File Name : tb_ahb_frbm.v
// File Revision : 0.5, Kier Dugan (kjd1v07@ecs.soton.ac.uk)
//
// --------------------------------------------------------------------------
// Purpose : Testbench for basic operation of the ahb_frbm module.
// --------------------------------------------------------------------------

`define OVL_ASSERT_ON

module tb_ahb_frbm;

localparam SLAVE_ADDR_WIDTH = 16;

// AHB signals.
logic           HCLK;
logic           HRESETn;
logic   [31:0]  HADDR;
logic   [ 2:0]  HBURST;
logic   [ 3:0]  HPROT;
logic   [ 2:0]  HSIZE;
logic   [ 1:0]  HTRANS;
logic   [31:0]  HWDATA;
logic           HWRITE;
logic   [31:0]  HRDATA;
logic           HREADY;
logic   [ 1:0]  HRESP;
logic           HBUSREQ;
logic           HLOCK;
logic           HGRANT;

// Slave response signals
logic           HSEL_1;

// Instantiate a master module.
ahb_frbm #(
    .MASTER_NAME    ("Test Master"),
    .TIC_CMD_FILE   ("./scripts/commands.tic")     //("../cachecmds.tic")
) master_a (.*);

// Instantiate a generic slave module.
ahb_gen_slave #(
    .ADDR_WIDTH (SLAVE_ADDR_WIDTH),
    .SLAVE_NAME ("Slave 1"),
    .MAX_DELAY (10),
    .MIN_DELAY (1)
) slave_1 (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .HADDR      (HADDR),
    .HBURST     (HBURST),
    .HPROT      (HPROT),
    .HSIZE      (HSIZE),
    .HTRANS     (HTRANS),
    .HWDATA     (HWDATA),
    .HWRITE     (HWRITE),
    .HRDATA     (HRDATA),
    .HREADY     (HREADY),
    .HRESP      (HRESP),
    .HSEL       (HSEL_1),
    .HREADY_in  (HREADY)
);

// Generate a clock.
initial begin
    HCLK = 1'b1;
    forever #5ns HCLK = ~HCLK;
end

// System reset.
initial begin
         HRESETn = 1'b0;
    #4ns HRESETn = 1'b1;
end

// Grant
initial begin
    HGRANT = 1'b0;
    #40ns HGRANT = 1'b1;
end

// Simple address decoder
assign HSEL_1 = (HADDR < (1 << SLAVE_ADDR_WIDTH) ) ? 1'b1 : 1'b0;

endmodule

