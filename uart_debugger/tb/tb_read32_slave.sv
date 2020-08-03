/*
MODULE NAME 	: tb_read32_slave.sv
AUTHOR 		: Andrew Brito & Chuan Yean Tan
LAST UPDATE	: 5/22/12
VERSION 	: 1.0
DESCRIPTION 	: Test for Debugger performing multiple read functions
TESTCASE	: 1. Read from Memory Backwards
		  2. Ramdom Reads from Memory
		  3. Multiple Reads from Memory
WAVEFORM	: waveform/tb_read32.do
*/

`timescale 1ns/1ps
`define EOF 32'hFFFF_FFFF

module tb_read32_slave();

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


//clock generation
parameter Period = 30;
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
	 		$display("[Error] : INCORRECT Read Value @ %0t", $time/1000);
			$display("Address: 	%d", test_addr);
			$display("HRDATA: 	%d", HRDATA);
			$display("data_array: 	%d\n", data_array[test_addr]);
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
	HPROT 		<= 4'd0;
	HSEL		<= 1'b1;
	HREADY_in	<= 1'b1;
	
	/*
	INITIALIZE VALUE
	*/
	addr 		<= 32'd0;
	write_data 	<= 32'd0;
	start_check	<= 0;
	cnt_check 	<= 0;
	error 		<= 0;

//------------- Initialize and write data into memory ------------//
	reset();
	/*
		Write several different values to different memory addresses
		Memory Address from 0 -> 124(decimal)
	*/
  	for (cnt = 0 ; cnt < 32; cnt++) begin
   		/*
			- Count		= 1
			- Mtestcaseemory Address= 0 through 124
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
	//Enable error checking
	start_check = 1;
//-------------- PARSE DAT FILE--------------------//	
DAT_FILE = $fopen("../source/read32.dat","r");
if (!DAT_FILE) begin
	$display("Error opening data file \" read32\.dat \" ");
end
OneChar = $fgetc(DAT_FILE);
while (OneChar != `EOF) begin
	if(OneChar == "#") begin
		RtnVal = $fgets(Vector, DAT_FILE);
		OneChar = $fgetc(DAT_FILE);
	end else begin 
		RtnVal = $ungetc(OneChar,DAT_FILE);
		RtnVal = $fgets(Vector, DAT_FILE); 
		RtnVal = $sscanf(Vector,"%d %d %d",testcase,addr_var, count_var);
		OneChar = $fgetc(DAT_FILE);

		case(testcase) 
		1: begin
			//----- CASE 1 :: Read from Memory Backwards -----//

			//Read from address 36 downto 0
			addr <= addr_var;
			for (cnt = 0 ; cnt < 10; cnt++) begin
   			/*
				- Count 	= 1
				- Memory Address= 36 downto 0
				- Read data	
			*/
    				count <= count_var;
				cnt_check <= 1;
    				set_count();
    				set_addr();
				read32();
				//Increment address by 4(byte offset)
				addr = addr - 4;
  			end

			if(error == 0) begin 
				$display("TestCase 1 Passed");
			end else begin
				$display("TestCase 1 Failed");
			end
		end

		2: begin 

			//----- CASE 2 :: Ramdom Reads from Memory -----//
	
			/*
				- Count 	= 1
				- Memory Address= 30
				- Read data	
			*/
  			count <= count_var;
			cnt_check <= 1;
    			set_count();
  			addr <= addr_var;
			set_addr();
			read32();

			/*
				- Count 	= 1
				- Memory Address= 6
				- Read data	
			
			count <= 1;
			cnt_check <= 8'd1;
    			set_count();
  			addr <= 32'd6;
			set_addr();
			read32();
			*/


			if(error == 0) begin 
				$display("TestCase 2 Passed");
			end else begin
				$display("TestCase 2 Failed");
			end
		
		end
		
		3: begin

			//----- CASE 3 :: Multiple Reads from Memory -----//
	
			/*
				- Count 	= 8
				- Memory Address= 0 through 28
				- Read data	
			*/
			count <= count_var;
			cnt_check <= 8;
    			set_count();
  			addr <= addr_var;
			set_addr();
			read32();
	
			if(error == 0) begin 
				$display("TestCase 3 Passed");
			end else begin
				$display("TestCase 3 Failed");
			end
		
		end//end 3
		endcase //end case
	end//end else
end//end while


//---------------------------END----------------------//

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
