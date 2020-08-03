/*
MODULE NAME 	: tb_write32_slave.sv
AUTHOR 		: Andrew Brito & Chuan Yean, Tan
LAST UPDATE	: 5/23/2013
VERSION 	: 1.0
DESCRIPTION 	: Running debugger together with the ahb_gen_slave to test possible write32 cases
TESTCASE	: 1. Test if the address is not set before a write 
         	  2. Half of a write32 and two alive commands
		  3. 8 normal write32 commands, and a string of 8 write32 commands that "failed" and required several alive commands
		  4. A string of 32 consecutive write32 commands
WAVEFORM	: waveform/tb_write32.do

*/

`timescale 10ns/10ns
`define EOF 32'hFFFF_FFFF

module tb_write32_slave();    

logic 	clk;
logic 	n_Rst; 

//--TESTBENCH VARIABLE--//
logic [8:0] data;
logic [7:0] count;
logic [31:0] addr;
logic [31:0] write_data;
integer i;
integer j;
integer k;
integer cnt;
integer  DAT_FILE;
integer  OneChar;
integer  RtnVal;
string   Vector;
integer	 testcase;
integer	 addr_var;
integer  count_var;
integer  write_data_var;


//--ERROR SIGNAL--//
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
logic	 [ 3:0]  HPROT;
logic  [ 1:0]  HRESP;
logic		HSEL;
logic		HREADY_in;

//--MEMORY ARRAYS--//
reg [3:0] [7:0] test_mem [31 : 0];
reg [3:0] [7:0] slave_mem [31 : 0];     


/*
  Send 8bit data packets
*/
/*	
	Sending Start Bit
	1 Start bit 	
	8 data bits
	0 parity bits

	Setting bits
	Data_in = MSB => LSB 
	Bit 0 is set to 0 because of start bit	
*/

task send_bits();
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

//--TASK : Reset the debugger/testbench and UART to its initial/default state--//
task reset();
  error = 0;
 	rx 	<= 1'b1;
	n_Rst 	<= 1'b0; 
	data  	<= 9'b111111111;
	send_bits();
	#30; 
endtask

//--TASK : Test whether the correct data was written to the slave's memory--//
//--       Must be called immediately following a single write32 operation--//
task test_write();
  count <= 8'd1;
  set_count();
  
  read32();
  	
	//Check whether the correct value was written to memory
	if (!(HRDATA == write_data)) begin
	  error = 1;
	end
endtask
  

//--------------- START COMMAND TASK ---------------//

//--TASK : Set the number of times that the next command will be executed--//
task set_count();
  	
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


//--TASK : Set the slave address that will be accessed--// 
task set_addr();
 	//----Set Command----//
 	n_Rst 	 <= 1'b1; 
	data   <= {1'b1,7'd3,1'b0}; //Command #3
	send_bits();
	#1000;

	//-----BYTE1-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[31:24],1'b0};
	send_bits();
	#1000;
	
	//-----BYTE2-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[23:16],1'b0};
	send_bits();
	#1000;

	//-----BYTE3-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[15:8],1'b0};
	send_bits();
	#1000;

	//-----BYTE4-----//
	n_Rst 	<= 1'b1; 
	data    <= {addr[7:0],1'b0};
	send_bits();
	#1000;
endtask


//--TASK : Write data to the address set by the set_addr() task--//
task write32();
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data   	<= {1'b1,7'd5,1'b0}; //Command #5
	send_bits();
	#1000;
	
	if (count <= 8'd0) begin
	  k = 8'd1;
	end else begin
	  k = count;
	end

	for ( ; k > 0 ; k--) begin 
		//-----BYTE1-----//
		n_Rst 	 <= 1'b1; 
		data    <= {write_data[31:24],1'b0};
		send_bits();
		#1000;
		
		//-----BYTE2-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[23:16],1'b0};
		send_bits();
		#1000;
	
		//-----BYTE3-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[15:8],1'b0};
		send_bits();
		#1000;
	
		//-----BYTE4-----//
		n_Rst 	 <= 1'b1; 
		data     <= {write_data[7:0],1'b0};
		send_bits();
		#1000;
 
    //Check whether the correct value was stored into memory
    if (!(HWDATA == write_data)) begin
      $display("INCORRECT value of HWDATA: %t ns",$time/1000);
      error = 1;
    end
    
    if (count > 1) begin
      write_data <= write_data + 1;
    end
  end
endtask 


//--TASK : Half of a write32() task. ONLY USED TO TEST THE ALIVE COMMAND--//
task write16();
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data   	<= {1'b1,7'd5,1'b0}; //Command #5
	send_bits();
	#1000;

	//-----BYTE1-----//
	n_Rst 	 <= 1'b1; 
	data    <= {write_data[31:24],1'b0};
	send_bits();
	#1000;
	
	//-----BYTE2-----//
	n_Rst 	 <= 1'b1; 
	data     <= {write_data[23:16],1'b0};
	send_bits();
	#1000;
endtask  


//--TASK : Read data from the address set by the set_addr() task--//
task read32();

  	//----Set Command----//
	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd4,1'b0}; //Command #4
	send_bits();
	#400000;
endtask


//--TASK : Send 0x00AE to the state machine to check if debugger is alive--//
task alive();
  	//----Set Command----//
 	n_Rst 	<= 1'b1; 
	data    <= {1'b1,7'd6,1'b0}; //Command #6
	send_bits();
	#10000;
endtask;
//--------------- END COMMAND TASK ---------------//


//clock generation
parameter Period = 30;
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
	//Initialize error value to 0
	error = 0;



//-------------- PARSE DAT FILE--------------------//	
DAT_FILE = $fopen("source/write32.dat","r");
if (!DAT_FILE) begin
	$display("Error opening data file \" write32\.dat \" ");
end
OneChar = $fgetc(DAT_FILE);
while (OneChar != `EOF) begin
	if(OneChar == "#") begin
		RtnVal = $fgets(Vector, DAT_FILE);
		OneChar = $fgetc(DAT_FILE);
	end else begin 
		RtnVal = $ungetc(OneChar,DAT_FILE);
		RtnVal = $fgets(Vector, DAT_FILE); 
		RtnVal = $sscanf(Vector,"%d %d %d %d",testcase,addr_var, count_var, write_data_var);
		OneChar = $fgetc(DAT_FILE);

		case(testcase) 
		1: begin
			 //---------- CASE 1 ----------//
  			/* Try to execute a write32 command
  	 		 * without first setting the address
  	 		 * and setting the count to 0.
   			 * If the debugger is first reset, then
   			 * the address is set to 0x00 as a default.
   			 * However, if the reset() task is not called
   			 * first, then the data is not written to
   			 * any memory location.
   			 */
    
  			reset();
     
  			count <= count_var;
  			set_count();

  			write_data <= write_data_var;
  			write32();
  			test_write();
  	
  			if (error == 0) begin
    				$display("TEST CASE 1: PASSED");
  			end else begin
    				$display("TEST CASE 1: FAILED");
  			end
			
		end

		2: begin 
			//---------- CASE 2 ----------//
  			/* Only send 2 bytes of data
   			 * with the write32 command,
   			 * then try to get back to IDLE
   			 * with the alive command.
   			 */
      $display("\n-----START ALIVE COMMAND TEST-----\n");

  			//Set count
  			count <= count_var;
  			set_count();
  			//Set address
 			addr <= addr_var;
  			set_addr();
  			//Set data to write
  			write_data <= write_data_var;
  			write16();
  			//Send the alive command
  			alive();
  			alive();
  
  			if (error == 0) begin
    				$display("TEST CASE 2: PASSED");
  			end else begin
   				$display("TEST CASE 2: FAILED");
  			end		
  			
		end
		
		3: begin
			//---------- CASE 3 ----------//
  			/* Multiple write32 commands are
  			 * executed. One write32 in the middle
  			 * of this stream of commands only
  			 * executes halfway. Alive commands
  			 * are then required to get the state
  			 * machine back into an IDLE state.
  			 */
      
  			//Set count
  			count <= count_var;
  			set_count();
  			//Set address
  			addr <= addr_var;
  			set_addr();
  
  			for (cnt = 0; cnt < 8; cnt++) begin
  				//Set data to write
    				write_data <= write_data_var;
    				write32();
    				addr <= addr + 4;
    				set_addr();
  			end
  
  			//Simulate a broken write32 command with 2 alive commands
  			write16();
  			alive();
  			alive();
  
  			//Simulate 8 broken writes
  			count <= 8'd8;
  			set_count();
  			write16();
  
  			//Send the alive command until the state machine returns to IDLE
  			for (cnt = 0; cnt < 9; cnt++) begin
    				for (j = 0; j < 4; j++) begin
     					alive();
    				end
   				addr <= addr + 4;
  			end
  
  			if (error == 0) begin
    				$display("TEST CASE 3: PASSED");
  			end else begin
   				$display("TEST CASE 3: FAILED");
  			end
  			
  			$display("\n-----END ALIVE COMMAND TEST-----\n");
		end

		4: begin 
			//---------- CASE 4 ----------//
 			/* Test 32 consecutive writes to
  			 * fill up all memory locations.
  			 */
  
  			//Set count to 32
  			count <= count_var;
  			set_count();

  			//Set starting address to 0x00  
  			addr <= addr_var;
 			set_addr();

  			//Set initial write data
  			write_data <= write_data_var;
  			write32();
  
  			if (error == 0) begin
    				$display("TEST CASE 4: PASSED");
  			end else begin
    				$display("TEST CASE 4: FAILED");
  			end
		end
		endcase //end case
	end//end else
end//end while

  $display("----------END OF TEST CASES----------");
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
