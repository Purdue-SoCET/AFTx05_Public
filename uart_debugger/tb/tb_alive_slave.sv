/*
MODULE NAME 	: tb_debugger_top
AUTHOR 		: Andrew Brito & Chuan Yean, Tan
LAST UPDATE	: 3/29/12
VERSION 	: 1.0
DESCRIPTION 	: Running debugger together with the ahb_gen_slave
TESTCASE	: Sending multiple alive commands 
WAVEFORM	: waveform/tb_alive.do

*/

`timescale 10ns/10ns
`define EOF 32'hFFFF_FFFF

module tb_alive_slave();

logic 	clk;
logic 	n_Rst; 
logic   [8:0] data;
logic [7:0] count;
logic [31:0] addr;
logic [31:0] write_data;
integer i;
integer j;
integer cnt;
integer data_array[31:0];

//--UART SIGNALS--//
logic 	rx;
logic 	tx;

//--AHB BUS SIGNALS--//
logic 	HREADY;
logic 	[31:0] HRDATA;
logic 	HWRITE;
logic 	[2:0] HSIZE;
logic 	[2:0] HBURST;
logic 	[1:0] HTRANS;
logic 	[31:0] HADDR;
logic 	[31:0] HWDATA;	
logic	[ 3:0]  HPROT;
logic   [ 1:0]  HRESP;
logic		HSEL;
logic		HREADY_in;


/*
	Task List:
	----------
	1. send_bits()
	2. reset()
	3. set_count()
	4. set_addr()
	5. write32()
	6. read32()
	
	Descriptions on functions describe below.

*/

      
      
/*
	send_bits()
	-----------
 	Send 8bit data packets
	
	Sending Start Bit
	1 Start bit 	
	8 data bits
	0 parity bits

	Setting bits
	Data_in = MSB => LSB 
	Bit 0 is set to 0 because of start bit	
*/

task send_bits;
	for (i = 0 ; i <= 10 ; i++) begin
		if (i > 8)begin 
			rx <= 1'b1;
		//Start bit -> '0'
		end else if (i == 0) begin
			rx <= 1'b0;
		end else begin
			rx = data[i];
		end
		#8680;
	end
endtask

//--TASK : Reset the debugger and UART to its initial/default state--//
task reset;
 	rx 	<= 1'b1;
	n_Rst 	<= 1'b0; 
	data  	<= 9'b111111111;
	send_bits();
	#30; 
endtask 

//--TASK : Set the number of times that the next command will be executed--//
task set_count;
  	
	//----Set Command----//
  	n_Rst 	<= 1'b1; 
	data   <= {1'b1,7'd2,1'b0}; //Command #2
	send_bits();
	#1000;

	//----Set Count----//
	n_Rst 	<= 1'b1; 
	data   <= {count,1'b0};
	send_bits();
	#1000;
endtask


//--TASK : Set the memory address that will be accessed--// 
task set_addr;
 	//----Set Command----//
  	n_Rst 	 <= 1'b1; 
	data   <= {1'b1,7'd3,1'b0}; //Command #3
	send_bits();
	#1000;

	//-----Set Address------//
	// Address is four bytes
	// MSB -> LSB
	//-----Byte 1-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[31:24],1'b0};
	send_bits();
	#1000;
	
	//-----Byte 2-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[23:16],1'b0};
	send_bits();
	#1000;

	//-----Byte 3-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[15:8],1'b0};
	send_bits();
	#1000;

	//-----Byte 4-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[7:0],1'b0};
	send_bits();
	#1000;
endtask


//--TASK : Write data to the address set by the set_addr() task--//
task write32;
  	//----Set Command----//
  	n_Rst 	<= 1'b1; 
	data   	<= {1'b1,7'd5,1'b0}; //Command #5
	send_bits();
	#1000;

	for (j = count ; j > 0; j--) begin 
		//-----Byte 1-----//
		n_Rst 	 <= 1'b1; 
		data    <= {write_data[31:24],1'b0};
		send_bits();
		#1000;
		
		//-----Byte 2-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[23:16],1'b0};
		send_bits();
		#1000;
	
		//-----Byte 3-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[15:8],1'b0};
		send_bits();
		#1000;
	
		//-----Byte 4-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[7:0],1'b0};
		send_bits();
		#1000;
		write_data <= write_data + 1;
	end 
endtask  


//--TASK : Read data from the address set by the set_addr() task--//
task read32;

  	//----Set Command----//
	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd4,1'b0}; //Command #4
	send_bits();

	/*
		Debugger reads value and send the value back
		to the user through the UART. Thus, a long
		wait time is required
	*/

	//Wait for 400000 ns
	#400000;
endtask


//--TASK : 	Send 0x00AE to the state machine to check debugger is alive--//
//		*State machine is alive if receive 0x00AE through the UART
task alive;
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd6,1'b0}; //Command #6
	send_bits();
	/*
		Debugger will return 0x00AE through the UART if 
		it is alive.Thus, a long wait time is required. 
	*/
	
	//Wait for 100000 ns
	#100000;
endtask;


//---------------------------------------------------------------------------------------------------------------------------------------------//



parameter Period = 30;
 
//clock generation
always begin
	#(Period/2) clk = 1'b0;
	#(Period/2) clk = 1'b1;
end
  

initial begin
	
	/*
	DEFAULT ASSIGNMENT FOR AHB BUS 
	*/
	HPROT 		<= 4'd0;
	HSEL		<= 1'b1;
	HREADY_in	<= 1'b1;
	
	
	reset();
	/*
	INITIALIZE VALUE
	*/
	addr 		<= 32'd0;
	write_data 	<= 32'd0;

	//------------- Initialize and write data into memory ------------//
	reset();
	/*
		Write several different values to different memory addresses
		Memory Address from 0 -> 124(decimal)
	*/
  	for (cnt = 0 ; cnt < 32; cnt++) begin
   		/*
			- Count		= 1
			- Memory Address= 0 through 124
			- Write data	= 0 through 31
		*/
    		count <= 8'd1;
    		set_count();
    		set_addr();
		write32();


    		//Increment data by 1
    		write_data <= write_data + 1;
		//Save initialize data in data_array
		data_array[cnt] = write_data;
		//Increment address by 4(byte offset)
		addr = addr + 4;
  	end
	$display("Memory Initialized.");

	//-----Testcase :: Sending multiple alive commands-------//
	alive();
	alive();
	alive();

	$display("END OF TEST CASES");

end
  
  
//-------------------------------------------------PORT MAP-----------------------------------------------------------//

//DEBUGGER//
debugger_top debugger_top(
			.clk(clk),
			.n_Rst(n_Rst),
			//--UART SIGNALS--//
			.rx(rx),
			.tx(tx),
			//--AHB BUS SIGNALS--//
			.HREADY(HREADY),
			.HRDATA(HRDATA),
			.HWRITE(HWRITE),
			.HSIZE(HSIZE),
			.HBURST(HBURST),
			.HTRANS(HTRANS),
			.HADDR(HADDR),
			.HWDATA(HWDATA)	
			);

//AHB SLAVE//
ahb_gen_slave ahb_gen_slave (
        .HCLK(clk),
        .HRESETn(n_Rst),
        .HADDR(HADDR),
        .HBURST(HBURST),
        .HPROT(HPROT),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
       	.HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .HSEL(HSEL),
        .HREADY_in(HREADY_in) 
);

endmodule 
