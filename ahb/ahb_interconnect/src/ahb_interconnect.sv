// File name:	ahb_interconnect.sv
// Created:	1/28/2016
// Author:	Noah Chesnut
// Version	1.0
// Description:	AMBA 3 AHB-Lite Interconnect

`include "ahb_if.vh"
`include "ahb_slave_interconnect.vh"

module ahb_interconnect 
#(
	parameter NUM_SLAVES = 3
)
(
	input logic CLK, nRST,
	// interface connecting to master
	ahb_if.ahb_m_i master,
	// interface connecting to slaves
	ahb_slave_interconnect_if.interconnection slaves
);

   localparam DIV = NUM_SLAVES - 2;
   localparam OFFSET = 32'h20000000 / DIV;
   
   // Internal signals
   logic [NUM_SLAVES-1:0] SSel_aphase, SSel_dphase, nxtSSel_dphase;
   int 		       i, k;
   genvar 	       j;
   
   
   
// Decoder
always_comb
begin : DECODER
	// Decoding logic
        SSel_aphase = 0;
		  k = 0;
	if ( master.HADDR <= 32'h3FFFFFFF ) begin
	  SSel_aphase[0] = 1;// Address is SRAM
        end else if (master.HADDR <= 32'h5FFFFFFF) begin
	   for (k = NUM_SLAVES-2; k > 0; k--) begin
	      if (master.HADDR <= (32'h40000000 + k * OFFSET))
		begin
		   SSel_aphase = 0;
		   SSel_aphase[k] = 1;// Address is Peripheral
		end
	   end
        end else if ((master.HADDR >= 32'hA0000000) &&
	        (master.HADDR <= 32'hDFFFFFFF)) begin
	  SSel_aphase[NUM_SLAVES-1] = 1;// Address is Flash
        end
end
// Slave Mux
always_comb
begin : SLAVE_MUX
   // Set default signals
   master.HREADY = slaves.HREADYOUT[0];
   master.HRESP = slaves.HRESP[0];
   master.HRDATA = slaves.HRDATA[0];
   // Decoding logic
   for (i = 0; i < NUM_SLAVES; i++) begin
      if (SSel_dphase[i]) begin
	 master.HREADY = slaves.HREADYOUT[i];
	 master.HRESP = slaves.HRESP[i];
	 master.HRDATA = slaves.HRDATA[i];
      end
   end
end
// Slave Select Reg
always_ff @ (posedge CLK, negedge nRST)
begin : SLAVE_SELECT
	if (!nRST)
		SSel_dphase <= 0;
	else
		SSel_dphase <= nxtSSel_dphase;
end

   assign nxtSSel_dphase = master.HREADY ? SSel_aphase : SSel_dphase;
   generate
      for (j=0;j < NUM_SLAVES;j++) begin : slave_assign
	 assign slaves.HTRANS[j] = master.HTRANS;
	 assign slaves.HWRITE[j] = master.HWRITE;
	 assign slaves.HADDR[j] = master.HADDR;
	 assign slaves.HWDATA[j] = master.HWDATA;
	 assign slaves.HSIZE[j] = master.HSIZE;
	 assign slaves.HBURST[j] = master.HBURST;
	 assign slaves.HREADY[j] = master.HREADY;
	 assign slaves.HPROT[j] = master.HPROT;
	 assign slaves.HMASTLOCK[j] = master.HMASTLOCK;
	 assign slaves.HSEL[j] = SSel_aphase[j] && (master.HTRANS != 0);
	   end : slave_assign
      endgenerate

endmodule // ahb_interconnect
