/*
MODULE NAME 	: tb_wrapper_core.sv
AUTHOR 		: Andrew Brito & Chuan Yean Tan
LAST UPDATE	: 6/26/12
VERSION 	: 1.0
DESCRIPTION 	: Test for Debugger performing multiple read functions interfacing with a file 
		  reading bus master and an ahb memory slave
TESTCASE	: 1. Read from Memory Backwards
		  2. Ramdom Reads from Memory
		  3. Multiple Reads from Memory
WAVEFORM	: waveform/tb_wrapper_core.do
*/

`timescale 1ns/1ps
`define EOF 32'hFFFF_FFFF

module tb_core_wrapper();

//Interfacing Variables
logic 	clk;
logic 	n_Rst; 
logic [8:0] data;
logic [7:0] count;
logic [31:0] addr;
logic [31:0] write_data;

//Testbench Variables
integer i;
integer  DAT_FILE;
integer  OneChar;
integer  RtnVal;
string   Vector;
integer	 testcase;
integer	 addr_var;
integer  count_var;
integer data_var;

//--Error Checking Variables--//
integer j;
integer cnt;
integer data_array[31:0];
integer test_addr;
integer start_check;
integer cnt_check;
integer error;

//--UART SIGNALS--//
logic 	rx;
logic 	tx;

//--AHB BUS SIGNALS--//
logic 	HREADY;
logic 	[31:0] HRDATA;
logic 	HWRITE;
logic 	[ 2:0] 	HSIZE;
logic 	[ 2:0] 	HBURST;
logic 	[ 1:0] 	HTRANS;
logic 	[31:0] 	HADDR;
logic 	[31:0] 	HWDATA;	
logic	[ 3:0]  HPROT;
logic  	[ 1:0]	HRESP;
logic		HSEL;
logic		HREADY_in;


//CORE
logic HREADY_CORE;
logic [31:0] HRDATA_CORE;
logic HWRITE_CORE;
logic [2:0] HSIZE_CORE;
logic [2:0] HBURST_CORE;
logic [1:0] HTRANS_CORE;
logic [31:0] HADDR_CORE;
logic [31:0] HWDATA_CORE;        
logic HBUSREQ_CORE;
logic HLOCK_CORE;
logic [3:0] HPROT_CORE;
logic [1:0] HRESP_CORE;
logic debug_rst;
logic M0_RST;

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
		#13;
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

task core_rst;
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd6,1'b0}; //Command #6
	send_bits();
	/*
		Debugger will return 0x00AE through the UART if 
		it is alive.Thus, a long wait time is required. 
	*/
	
	//Wait for 100000 ns
	#100;
endtask;

task core_norm;
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd8,1'b0}; //Command #6
	send_bits();
	/*
		Debugger will return 0x00AE through the UART if 
		it is alive.Thus, a long wait time is required. 
	*/
	
	//Wait for 100000 ns
	#100;
endtask;



//---------------------------------------------------------------------------------------------------------------------------------------------//


//clock generation
parameter Period = 37;
always begin
	#(Period/2) clk = 1'b0;
	#(Period/2) clk = 1'b1;
end

/*
	Error Checking
	--------------
	
	A list of data is stored in a predefined data_array. 
	When a read operation is perform, the testbench will 
	compare the data on HRDATA with the data in the data
	array. 
*/
always @ (HRDATA) begin

	//To calculate block offset
	if (addr < 4 && addr > 0)begin
		test_addr = 1;
	end else begin
		test_addr = addr/4;
	end		
	
	

	//Check whether the correct value was read from memory
	if (start_check == 1)begin 
		if (!(HRDATA == data_array[test_addr])) begin
			/*
			For debug purposes:
			-------------------
	 		$display("[Error] : INCORRECT Read Value @ %0t", $time/1000);
			$display("Address: 	%d", test_addr);
			$display("HRDATA: 	%d", HRDATA);
			$display("data_array: 	%d\n", data_array[test_addr]);
			*/
			error = 1;
		end 
		/*
		For debug purposes:
		-------------------
		else begin
			$display("Correct Data.");
			$display("Address: 	%d", test_addr);
			$display("HRDATA: 	%d", HRDATA);
			$display("data_array: 	%d\n", data_array[test_addr]);
		end
		*/
	end
	
	/*
		Determines whether a block offset is needed.
		Debugger tracks the HRDATA when debugger is 
		performing a sequence of read operations.
		Adds a block offset if perform two or more 
		read operations.
	*/
	if(cnt_check > 1)begin 
		addr = addr + 4;
		cnt_check = cnt_check -1;
	end 

end  

initial
begin

	/*
	DEFAULT ASSIGNMENT FOR AHB BUS 
	*/
	HSEL		<= 1'b1;
	HREADY_in	<= 1'b1;
	
	/*
	INITIALIZE VALUE
	*/
	start_check	<= 0;
	cnt_check 	<= 0;
	error 		<= 0;

//------------- Initialize and write data into memory ------------//
	reset();
	/*
		Write several different values to different memory addresses
		Memory Address from 0 -> 124(decimal)
	*/
	/*
	--Initializing using debugger--
	addr 		<= 32'd0;
    	count 		<= 8'd32;
	write_data 	<= 32'd0;

	set_count();
	set_addr();
	write32();

	$display("Memory Initialized.");
	*/

	//Enable error checking
	start_check = 1;
//-------------- PARSE DAT FILE--------------------//	
DAT_FILE = $fopen("source/wrapper.dat","r");
if (!DAT_FILE) begin
	$display("Error opening data file \" wrapper\.dat \" ");
end
OneChar = $fgetc(DAT_FILE);

while (OneChar != `EOF) begin
	if(OneChar == "#") begin
		RtnVal = $fgets(Vector, DAT_FILE);
		OneChar = $fgetc(DAT_FILE);
	end else begin 
		RtnVal = $ungetc(OneChar,DAT_FILE);
		RtnVal = $fgets(Vector, DAT_FILE); 
		RtnVal = $sscanf(Vector,"%d %d %d %d",testcase, addr_var, count_var, data_var);
		OneChar = $fgetc(DAT_FILE);

		case(testcase) 
		1: begin
			//----- CASE 1 :: Multiple Writes to Memory -----//
			debug_rst <= 1'b0;
			addr <= addr_var;
			count <= count_var;
			write_data <= data_var;
			core_rst();
		   #100000;
		   
			set_count();	
		   #100000;
		   
			set_addr();	
		   #100000;
		   
			write32();
		   #100000;
		   
			core_norm();

		end //end case 1

		2: begin 
			//----- CASE 2 :: Multiple Reads from Memory -----//
			addr <= addr_var;
			count <= count_var;
			//core_rst();
			set_count();
			set_addr();
			//core_norm();
			read32();

		end //end case 2
		
		endcase

	end//end else

end//end while


//---------------------------END----------------------//

	$display("END OF TEST CASES");
	
end
  

	

//-------------------------------------------------PORT MAP-----------------------------------------------------------//

//DEBUGGER//
core_wrapper core_wrapper(
			.clk(clk),
			.n_Rst(n_Rst),
			.debug_rst(debug_rst),
			//--UART SIGNALS--//
			.rx(rx),
			.tx(tx),
			.M0_RST(M0_RST),
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
			.HPROT(HPROT),
			//Core Signals
			.HADDR_M1(HADDR_CORE),
                        .HBURST_M1(HBURST_CORE),
                        .HPROT_M1(HPROT_CORE),
                        .HSIZE_M1(HSIZE_CORE),
                        .HTRANS_M1(HTRANS_CORE),
                        .HWDATA_M1(HWDATA_CORE),
                        .HWRITE_M1(HWRITE_CORE),
                        .HRDATA_M1(HRDATA_CORE),
                        .HREADY_M1(HREADY_CORE),
                        .HRESP_M1(HRESP_CORE),
                        .HBUSREQ_M1(HBUSREQ_CORE),
                        .HLOCK_M1(HLOCK_CORE)
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

ahb_frbm #(
	.TIC_CMD_FILE("./source/ahb/frbm/scripts/commands.tic")
	) ahb_frbm (

                        .HCLK(clk),
                        .HRESETn(M0_RST),
                        .HADDR(HADDR_CORE),
                        .HBURST(HBURST_CORE),
                        .HPROT(HPROT_CORE),
                        .HSIZE(HSIZE_CORE),
                        .HTRANS(HTRANS_CORE),
                        .HWDATA(HWDATA_CORE),
                        .HWRITE(HWRITE_CORE),
                        .HRDATA(HRDATA_CORE),
                        .HREADY(HREADY_CORE),
                        .HRESP(HRESP_CORE),
                        .HBUSREQ(HBUSREQ_CORE),
                        .HLOCK(HLOCK_CORE),
                        .HGRANT(1'b1)
);


endmodule 
