/*
MODULE NAME         	: core_wrapper
AUTHOR                 	: Andrew Brito & Chuan Yean, Tan
LAST UPDATE        	: 6/26/13
VERSION         	: 1.0
DESCRIPTION         	: Wrapper interface between M0 Core and Debugger
*/

`include "ahb_if.vh"
`include "generic_bus_if.vh"

module core_wrapper(   
			//--INPUTS--//
			input		clk,
			input 		rst_n,
			//--DEBUG/UART SIGNALS--//
			input wire 	rx,
			output wire	tx,
			//--AHB BUS SIGNALS--//
			input wire 	HREADY,
			input wire 	[31:0] HRDATA,
			input wire 	[1:0] HRESP,
			//--OUTPUTS--//
			output wire	[31:0] cm0_pc,
			output wire	HWRITE,
			output wire	[2:0] HSIZE,
			output wire	[2:0] HBURST,
			output wire	[1:0] HTRANS,
			output wire	[31:0] HADDR,
			output wire	[31:0] HWDATA,
			output wire	[3:0] HPROT
        );


//CORE
generic_bus_if core_bus_if();
wire HREADY_M1;
wire [31:0] HRDATA_M1;
wire HWRITE_M1;
wire [2:0] HSIZE_M1;
wire [2:0] HBURST_M1;
wire [1:0] HTRANS_M1;
wire [31:0] HADDR_M1;
wire [31:0] HWDATA_M1; 
wire HMASTLOCK_M1;       
wire HBUSREQ_M1;
wire HLOCK_M1;
wire [3:0] HPROT_M1;
wire [1:0] HRESP_M1;
//CORE EXTRAS
wire  TXEV;              // Event output (SEV executed)
wire  LOCKUP;            // Core is locked-up
wire  SYSRESETREQ;       // System reset request
wire  SLEEPING;          // Core and NVIC sleeping


//DEBUG
wire HREADY_M2;
wire [31:0] HRDATA_M2;
wire HWRITE_M2;
wire [2:0] HSIZE_M2;
wire [2:0] HBURST_M2;
wire [1:0] HTRANS_M2;
wire [31:0] HADDR_M2;
wire [31:0] HWDATA_M2;
wire [3:0] HPROT_M2;
wire [1:0] HRESP_M2;
wire M0_RST;

//--PORT MAPS--//

//--AHB-LITE MUX--//
AHB_Lite_Mux AHB_Lite_Mux(
			//--INPUTS--//
			.clk(clk),
      			.n_Rst(rst_n),
			.debug_rst(1'b0),

			//--MASTER 1 SIGNALS--//
			.HWRITE_M1(HWRITE_M1),
			.HSIZE_M1(HSIZE_M1),
			.HBURST_M1(HBURST_M1),
			.HTRANS_M1(HTRANS_M1),
			.HADDR_M1(HADDR_M1),
			.HWDATA_M1(HWDATA_M1),        
			.HPROT_M1(HPROT_M1),

      			.HREADY_M1(HREADY_M1),
			.HRDATA_M1(HRDATA_M1),
			.HRESP_M1(HRESP_M1),

			//--MASTER 2 SIGNALS--//
			.HWRITE_M2(HWRITE_M2),
			.HSIZE_M2(HSIZE_M2),
			.HBURST_M2(HBURST_M2),
			.HTRANS_M2(HTRANS_M2),
			.HADDR_M2(HADDR_M2),
			.HWDATA_M2(HWDATA_M2),        
			.HPROT_M2(HPROT_M2),

      			.HREADY_M2(HREADY_M2),
			.HRDATA_M2(HRDATA_M2),
			.HRESP_M2(HRESP_M2),

      			//--AHB BUS SIGNALS--//
      			.HREADY(HREADY),
			.HRDATA(HRDATA),
			.HRESP(HRESP),

			.HWRITE(HWRITE),
			.HSIZE(HSIZE),
			.HBURST(HBURST),
			.HTRANS(HTRANS),
			.HADDR(HADDR),
			.HWDATA(HWDATA),
			.HPROT(HPROT)
		);

// -- RISCV CORE --//
ahb_if core_ahb_m_if();
RISCVBusiness RISCVBusiness (
  .CLK(clk),
  .nRST(M0_RST),
  .ahb_master(core_ahb_m_if)
);

  assign core_ahb_m_if.HREADY = HREADY_M1;
  assign core_ahb_m_if.HRESP = HRESP_M1;
  assign core_ahb_m_if.HRDATA = HRDATA_M1;
  assign HTRANS_M1    = core_ahb_m_if.HTRANS;
  assign HWRITE_M1    = core_ahb_m_if.HWRITE;
  assign HADDR_M1     = core_ahb_m_if.HADDR;
  assign HWDATA_M1    = core_ahb_m_if.HWDATA;
  assign HSIZE_M1     = core_ahb_m_if.HSIZE;
  assign HBURST_M1    = core_ahb_m_if.HBURST;
  assign HPROT_M1     = core_ahb_m_if.HPROT;
  assign HMASTLOCK_M1 = core_ahb_m_if.HMASTLOCK;

//--DEBUGGER--//
debugger_top debugger_top(
      .clk(clk),
      .rst_n(rst_n),
      .HREADY(HREADY_M2),
      .HRDATA(HRDATA_M2),
      .HWRITE(HWRITE_M2),
      .HSIZE(HSIZE_M2),
      .HBURST(HBURST_M2),
      .HTRANS(HTRANS_M2),
      .HADDR(HADDR_M2),
      .HWDATA(HWDATA_M2),
      .M0_RST(M0_RST),
      .rx(rx),
      .tx(tx) 
      );

endmodule

