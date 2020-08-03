/*
--UART Specifications-- 
Data: 		8 bits
Parity: 	NONE
Stop bits: 	1, 1.5, 2
Baud rate: 	115.2k

--Design information--
File name:   	uart.v
Created:    	2/28/2013
Author:      	Chuan Yean Tan
Version:	1.0 
Description: 	UART top level block

--Note to self--
-> The debugger is only connected via the UART,
therefore, it only has rx and tx interfacing with the UART

*/

`include "debugger_if.vh"

module debugger_top(	input logic		clk,
			input logic		rst_n,
			input logic rx,
			output logic M0_RST, 
			output logic tx,
			input  logic HREADY,
			input  logic [31:0] HRDATA,
			output logic HWRITE,
			output logic [2:0] HSIZE, HBURST,
			output logic [1:0] HTRANS,
		  	output logic [31:0] HWDATA, HADDR		
	);
		
	
//UART
wire byte_send;
wire [7:0] UDATA_OUT;
wire [7:0] UDATA_IN;
wire byte_rcv;
wire start_trans;
wire is_receiving;
wire is_transmitting;
wire recv_error;
  
//OUTPUTS// 
/*			
wire IN_HWRITE;
wire [2:0] IN_HSIZE;
wire [2:0] IN_HBURST;
wire [1:0] IN_HTRANS;
wire [31:0] IN_HADDR;
wire [31:0] IN_HWDATA;
*/
//PORT MAP


debugger debugger( 
			.clk(clk),
			.rst_n(rst_n),
			//INPUTS
			.data_in(UDATA_IN), 		//from UART
			.byte_rcv(byte_rcv),		//signal sent from the UART to indicate that it has completed its sending
			.byte_send(byte_send),
			//OUTPUTS 
			.start_trans(start_trans),	//signal to start transfer data
			.data_send(UDATA_OUT),		//connected to UART -> sending data out to USER
			.M0_RST(M0_RST),		//Connected to core's reset
			//--AHB BUS SIGNALS--//		
			//INPUTS//
			.HREADY(HREADY),
			.HRDATA(HRDATA),	
			//OUTPUTS//			
			.HWRITE(HWRITE),
			.HSIZE(HSIZE),
			.HBURST(HBURST),
			.HTRANS(HTRANS),
			.HADDR(HADDR),
			.HWDATA(HWDATA)
		);

uart uart(
	  .clk(clk),
	  .n_rst(rst_n),
	  .rx(rx),	  
	  .transmit(start_trans),
	  .tx_byte(UDATA_OUT),
	  //output
	  .tx(tx),
	  .received(byte_rcv),
	  .rx_byte(UDATA_IN),
	  .is_receiving(is_receiving),
	  .is_transmitting(is_transmitting),
	  .recv_error(recv_error),
	  .sent(byte_send)
	  );
   



//--------------------------------------------OUTPUT LOGIC------------------------------------------------//
/*always @ (*) begin 
        //HPROT <= 4'd0;
	
    HWRITE 	<= IN_HWRITE;
	HSIZE 	<= IN_HSIZE;
    HBURST 	<= IN_HBURST;
	HTRANS 	<= IN_HTRANS;
	HADDR 	<= IN_HADDR;
	HWDATA	<= IN_HWDATA;
end */
					
					
endmodule
