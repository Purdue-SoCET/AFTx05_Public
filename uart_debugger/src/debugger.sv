/*
MODULE NAME 	: Debugger
AUTHORS 		: Andrew Brito & Chuan Yean, Tan
                  Haoyue Gao & Jacob Stevens
LAST UPDATE	: 8/13/15
VERSION 	: 2.0
DESCRIPTION 	: Execute commands to read and write from the ARM M0 Cortex Processor
		  Functions: 	1. Set Count
				2. Set Address
				3. Read32
				4. Write32
				5. Alive
				6. Hold core in reset
				7. Release core from reset

		  For more information, refer to Reference documents under the docs folder.  
*/


/*
INCLUDES
*/
`timescale 1ns/10ps

`ifdef SOCET_DEBUG
	`define OVL_ASSERT_ON
	`define OVL_INIT_MSG
	`include "assert_always.vlib" 
	`include "assert_never.vlib" 
`endif


/*
MODULE DECLARATION
*/
module debugger( 			
		//--INPUTS--//
		input clk,
		input rst_n,
		input wire [7:0] data_in, 		//data recieved from UART
		input wire byte_rcv,			//signal recieved from UART - indicate that it has completed its sending
		input wire byte_send,			//signal recieved from UART - indicate that data packet has succefully sent
		//--AHB INPUTS--//
		input wire HREADY,
		input wire [31:0] HRDATA,
		//--OUTPUTS--//
		output reg start_trans,			//signal to start transfer data
		output reg [7:0]data_send,		//data packet to be send via UART
		output     M0_RST,
		//--AHB OUTPUTS--//
		output reg HWRITE,
		output reg [2:0] HSIZE,
		output reg [2:0] HBURST,
		output reg [1:0] HTRANS,
		output reg [31:0] HADDR,
		output reg [31:0] HWDATA);


//PARAMETER
parameter SIZE = 3;

//TOP LEVEL STATES
/*
	Note: 	The states are declared as 7 bits because 
	      	the incoming command is 7 bits wide. More room
		to expand in the future.


	Command List: 
	-------------
	Set Count 	-> 2
	Set Addr  	-> 3
	Read32	  	-> 4
	Write32	  	-> 5
	Alive	  	-> 6
	Set Core Rst 	-> 7
	Reset Core Rst 	-> 8
*/

//MAIN STATE
typedef enum reg [3:0] {
    IDLE,
    CMD_RECD,
    SET_COUNT, 
    SET_ADDR,
    READ32,
    WRITE32, 
    ALIVE,
    CORE_RST,
    CORE_NORM, 
    DONE} MAIN_STATE_t;

//SET_COUNT STATE
typedef enum reg [1:0] {
    START_SET_COUNT,
    COUNT_RCV_BYTE,
    COUNT_DONE} SET_COUNT_STATE_t;
   
		
//SET_ADDR STATES
typedef enum reg [1:0] {
		START_SET_ADDR,
		ADDR_RCV_BYTE,
		SAVE_ADDR,
		ADDR_DONE} SET_ADDR_STATE_t;
   
//READ32 STATES
typedef enum reg [2:0] {
    READ32_START,
    READ32_APHASE,
    READ32_APHASE_FINISH,
    READ32_DPHASE,
    READ32_SEND_DATA,
    READ32_DONE} READ32_STATE_t;

//WRITE32 STATES
typedef enum reg [2:0] {
    WRITE32_START,
    WRITE32_ADDR,
    WRITE32_WRITE_DATA,
    WRITE32_CHK_SEND,
    WRITE32_DONE} WRITE32_STATE_t;

//RCV_X_BYTE
typedef enum reg [1:0] {
    START_RCV_X_BYTE,
    UPDATE_IDLE,
    RECEIVE_BYTE,
    RCV_X_BYTE_DONE} RCV_X_BYTE_t;
		
//SEND_X_BYTE
typedef enum reg [1:0] {
    START_SEND_X_BYTE,
    SEND_BYTE,
    TRIM_BYTE,
    SEND_X_BYTE_DONE} SEND_X_BYTE_t;
		
//ALIVE STATES
typedef enum reg {
    ALIVE_START,
    ALIVE_DONE} ALIVE_STATE_t;


//CORE RESET STATES
typedef enum reg { 
    CORE_RST_SET,
    CORE_RST_DONE} CORE_RESET_STATE_t;

//CORE NORMAL STATES	
typedef enum reg {
    CORE_NORM_SET,
    CORE_NORM_DONE} CORE_NORMAL_STATE_t;

/*
DECLARATIONS
*/

//STATES		
MAIN_STATE_t           state;
SET_COUNT_STATE_t      set_count_state;
SET_ADDR_STATE_t       set_addr_state;
READ32_STATE_t         read32_state;
WRITE32_STATE_t        write32_state;
RCV_X_BYTE_t           rcv_x_byte_state;
SEND_X_BYTE_t          send_x_byte_state;
ALIVE_STATE_t          alive_state;
CORE_RESET_STATE_t     core_rst_state;
CORE_NORMAL_STATE_t    core_norm_state;

//VARIABLES
reg [7:0] cmd_reg;		// stores cmd (8 bits)
reg [7:0] crc_reg; 		// crc register for reads and writes
reg [3:0] rcv_x_byte_ctr; 	// rcv_x_byte counter
reg [31:0] rcv_x_byte_reg; 	// rcv_x_byte register 
reg [31:0] send_x_byte_ctr;	// send_x_byte counter
reg [31:0] send_x_byte_reg;	// send_x_byte counter
reg [31:0] count_reg;		// 32 bit count register 
reg [31:0] read_ctr; 		// 32 bit read byte counter
reg [31:0] write_ctr; 		// 32 bit write byte counter
reg [31:0] addr_reg; 		// 32 bit addr register
reg core_rst_reg;


//TOP LEVEL STATE MACHINE
always @ (posedge clk, negedge rst_n) begin
	
	if (rst_n == 1'b0) begin 
		/*
		STATES
		*/
		state				<= CORE_NORM;
		set_count_state 		<= START_SET_COUNT;
		set_addr_state 			<= START_SET_ADDR;
		read32_state 			<= READ32_START;
		write32_state 			<= WRITE32_START;
		rcv_x_byte_state		<= START_RCV_X_BYTE;
		send_x_byte_state  		<= START_SEND_X_BYTE;
		alive_state			<= ALIVE_START;
		core_rst_state 			<= CORE_RST_SET;
		core_norm_state 		<= CORE_NORM_SET;

		/*
		VARIABLES
		*/
		cmd_reg				<= 8'd0;
		count_reg 			<= 32'd0;
		addr_reg 			<= 32'd0;

		rcv_x_byte_ctr			<= 4'b0000;
		rcv_x_byte_reg 			<= 32'd0;
		send_x_byte_ctr 		<= 32'd0;
		send_x_byte_reg			<= 32'd0;

		read_ctr 			<= 32'd0;
		write_ctr 			<= 32'd0;
		data_send 			<= 8'd0;
		start_trans			<= 1'b0;
		crc_reg	     			<= 8'd0;
		core_rst_reg 			<= 1'd1;

		/*
		AHB BUS SIGNALS
		*/
		HTRANS 				<= 2'b00;
		HWRITE 				<= 1'b0;
		HSIZE				<= 3'b000;
		HBURST				<= 3'b000;
		HTRANS				<= 2'b00;
		HADDR				<= 32'd0;
		HWDATA				<= 32'd0;
	
	end else begin
		case (state)
		IDLE: begin
				state 		<= CMD_RECD;
				rcv_x_byte_ctr 	<= 4'd1;
				crc_reg  	<= 8'd0;   //Reset crc value before every command
		end

		CMD_RECD:
		begin
				rcv_x_byte(); 
				if (rcv_x_byte_state == RCV_X_BYTE_DONE) begin
					if (rcv_x_byte_reg[7] == 1'b1) begin 
						cmd_reg <= rcv_x_byte_reg[7:0];
						if (rcv_x_byte_reg[6:0] == SET_COUNT) begin
							state <= SET_COUNT;
							set_count_state <= START_SET_COUNT;
						end else if (rcv_x_byte_reg[6:0] == SET_ADDR) begin
							state <= SET_ADDR; 
							set_addr_state <= START_SET_ADDR;
						end else if (rcv_x_byte_reg[6:0] == READ32) begin 
							state <= READ32; 
							read32_state <= READ32_START;
						end else if (rcv_x_byte_reg[6:0] == WRITE32) begin 
							state <= WRITE32;
							write32_state <= WRITE32_START;
						end else if (rcv_x_byte_reg[6:0] == ALIVE) begin
							state <= ALIVE;
							alive_state <= ALIVE_START;
						end else if (rcv_x_byte_reg[6:0] == CORE_RST) begin
							state <= CORE_RST;
							core_rst_state <= 	CORE_RST_SET;
						end else if (rcv_x_byte_reg[6:0] == CORE_NORM) begin
							state <= CORE_NORM;
							core_norm_state <= CORE_NORM_SET;
						end else begin
							state <= IDLE;
						end
					end else begin
						state <= CMD_RECD;
					end 
				end

		end
		
		SET_COUNT: 
		begin
				set_count();
				if (set_count_state == COUNT_DONE)begin
					state <= DONE; 
				end 
		end
		
		SET_ADDR: 
		begin 
				set_addr();
				if (set_addr_state == ADDR_DONE)begin
					state <= DONE; 
				end 
		end
		READ32: 
		begin
				read32();
				if (read32_state == READ32_DONE)begin
					state <= DONE; 
				end 
		end
		
		WRITE32: 
		begin
				write32();
				if (write32_state == WRITE32_DONE)begin
					state <= DONE; 
				end 
		end

		ALIVE: begin
			alive();
			if (alive_state == ALIVE_DONE) begin
				state <= DONE;
			end
		end

		CORE_RST: begin
			core_rst();
			if (core_rst_state == CORE_RST_DONE) begin
				state <= DONE;
			end 
		end


		CORE_NORM: begin
			core_norm();
			if (core_norm_state == CORE_NORM_DONE) begin
				state <= DONE;
			end 
		end
		
		DONE:	
		begin 
		    		//[TODO] check that all sub state machines are also done
		    		//Prepare to send the crc value through the UART
				send_x_byte_ctr 		<= 32'd1;
				send_x_byte_reg 		<= {crc_reg, 24'b0}; 
				send_x_byte();
				if(send_x_byte_state == SEND_X_BYTE_DONE) begin
					cmd_reg <= 8'd0;
					state <= IDLE;
				end
		end
		default: 
				state <= IDLE;
				
		endcase 
	end
end


/*
FUNCTIONS
*/
////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 1999-2008 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose : synthesizable CRC function
//   * polynomial: (0 2 3 6 8)
//   * data width: 8
//
// Info : tools@easics.be
//        http://www.easics.com
////////////////////////////////////////////////////////////////////////////////

  // polynomial: (0 2 3 6 8)
  // data width: 8
  // convention: the first serial bit is D[7]
  function [7:0] next_crc8;

    input [7:0] data;
    input [7:0] crc;
    reg [7:0] d;
    reg [7:0] c;
    reg [7:0] newcrc;
  begin
    d = data;
    c = crc;

    newcrc[0] = d[5] ^ d[4] ^ d[2] ^ d[0] ^ c[0] ^ c[2] ^ c[4] ^ c[5];
    newcrc[1] = d[6] ^ d[5] ^ d[3] ^ d[1] ^ c[1] ^ c[3] ^ c[5] ^ c[6];
    newcrc[2] = d[7] ^ d[6] ^ d[5] ^ d[0] ^ c[0] ^ c[5] ^ c[6] ^ c[7];
    newcrc[3] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[2] ^ c[4] ^ c[5] ^ c[6] ^ c[7];
    newcrc[4] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[1] ^ c[2] ^ c[3] ^ c[5] ^ c[6] ^ c[7];
    newcrc[5] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[2] ^ c[3] ^ c[4] ^ c[6] ^ c[7];
    newcrc[6] = d[7] ^ d[3] ^ d[2] ^ d[0] ^ c[0] ^ c[2] ^ c[3] ^ c[7];
    newcrc[7] = d[4] ^ d[3] ^ d[1] ^ c[1] ^ c[3] ^ c[4];
    next_crc8 = newcrc;
  end
  endfunction


/*
TASK LIST:

Second Level
1. set_count
2. set_addr
3. read32
4. write32
5. core_rst
6. core_norm

Third Level
1. send_crc
2. rcv_x_byte
3. send_x_byte
*/

/*
 * NAME :: set_count()
 * PURPOSE :: To indicate how many read or write operations 
 *            to perform sequentially.
 */
task set_count;
	case(set_count_state)
	START_SET_COUNT:begin
		//Default counter value is 1 byte
        // Consider making it 9 bits so we can write 256 or use all FF as code for stop?
		rcv_x_byte_ctr  <= 4'd1;
		count_reg 	<= 32'd0;
		set_count_state <= COUNT_RCV_BYTE;
	end
	COUNT_RCV_BYTE: begin
	  	//Receive count value from the UART
		rcv_x_byte();
		if (rcv_x_byte_state == RCV_X_BYTE_DONE) begin
			//Pass the received value to the count register if it is greater than 0
		  	//Else, set count to 1
		  	if (rcv_x_byte_reg <= 32'd0) begin
		  		count_reg <= 8'd1;
		  	end else begin
        			count_reg	<= rcv_x_byte_reg;
      			end
		set_count_state <= COUNT_DONE;
		end
			
	end
	COUNT_DONE:begin
		set_count_state <= START_SET_COUNT;
	end
	default:
		set_count_state <= START_SET_COUNT;
	endcase 
endtask

/*
 * NAME :: set_addr()
 * PURPOSE :: To indicate which memory location to access next
 *            with a read or write operation.
 */
task set_addr;
	case (set_addr_state)
	START_SET_ADDR:begin
	  //Set the counter to 4 since the address is 4 bytes
		rcv_x_byte_ctr		<= 4'd4;
		addr_reg 		<= 32'd0;
		set_addr_state 		<= ADDR_RCV_BYTE;
		//Reset the rcv_x_byte state machine to its start state
		rcv_x_byte_state 	<= START_RCV_X_BYTE;
	end
	ADDR_RCV_BYTE: begin
	  	//Receive the address value
		rcv_x_byte();
		if (rcv_x_byte_state == RCV_X_BYTE_DONE) begin
			set_addr_state <= ADDR_DONE;
		end else begin
			set_addr_state <= ADDR_RCV_BYTE;
		end
	end
	ADDR_DONE:begin
		addr_reg	<= rcv_x_byte_reg;
		set_addr_state 	<= START_SET_ADDR;
	end

	default: 
		set_addr_state <= START_SET_ADDR;
	endcase 
endtask

/*
	READ DATA FROM SPECIFIC ADDRESS
	3 cycles of HCLK 
	M0 		-> Master
	Debugger 	-> Slave
*/

/*
 * NAME :: read32()
 * PURPOSE :: To read a 32-bit word from a memory location in the slave.
 *            This location is set by the set_addr command. In
 *            addition, multiple reads may be performed if the
 *            count value set by the set_count command is greater than 1.
 *            In this case, the memory address is automatically incremented
 *            by 4 for every consecutive read operation in the burst.
 */
task read32;
	case (read32_state)

		READ32_START : begin 
			//State transaction
		  	read32_state <= READ32_APHASE;
			//[TODO] create a copy of count_reg for decrement that is the same for read32, write32, etc
		 	read_ctr <= count_reg; //number of read cycles to execute 
		end
		READ32_APHASE: begin
		 	//State transaction
		  	read32_state 	  <= READ32_APHASE_FINISH;
		  	send_x_byte_state <= START_SEND_X_BYTE;
		  	//--AHB bus config--//
		  	HADDR  <= addr_reg; 	//send address to master
		  	HTRANS <= 2'b10; 	//Set to NONSEQ --- > Hint to MUX @ arbiter
		  	HSIZE  <= 3'b010;   	//word-sized
		  	HBURST <= 3'b000;   	//single burst
		 	HWRITE <= 1'b0;     	//read phase
		end	
        READ32_APHASE_FINISH:
			if (HREADY) begin
                HTRANS <= 2'b00;
				read32_state <= READ32_DPHASE;
            end else begin
				read32_state <= READ32_APHASE_FINISH;
            end
		READ32_DPHASE: begin	
			if (HREADY) begin
				send_x_byte_reg <= HRDATA;        //save the data into a register
				send_x_byte_ctr <= 32'd4;   	  //prepare to send 4 bytes of data
		 		read_ctr <= read_ctr - 1;
				addr_reg <= addr_reg + 4;  	  //increment address value
				read32_state <= READ32_SEND_DATA; //enter data phase if HREADY = 1
			end else begin 
				read32_state <= READ32_DPHASE;
			end
		end
		READ32_SEND_DATA: begin
			send_x_byte(); 
			if (send_x_byte_state == SEND_X_BYTE_DONE) begin
				if (read_ctr != 0) begin
		 			read32_state <= READ32_APHASE;
				end else begin
		 			read32_state <= READ32_DONE;
				end
			end else begin
				read32_state <= READ32_SEND_DATA;
			end
		end
		READ32_DONE: begin
			read32_state <= READ32_START;
		end

		default : begin
			read32_state <= READ32_START;
		end
	endcase
endtask

/*
 * NAME :: write32()
 * PURPOSE :: To write a 32-bit word to a memory location in the slave.
 *            This location is set by the set_addr command. In
 *            addition, multiple writes may be performed if the
 *            count value set by the set_count command is greater than 1.
 *            In this case, the memory address is automatically incremented
 *            by 4 for every consecutive write operation in the burst.
 */
task write32;
	case (write32_state)
		WRITE32_START:begin 
			write32_state 		<= WRITE32_ADDR;
			rcv_x_byte_state 	<= START_RCV_X_BYTE;
			write_ctr 		<= count_reg;	
			rcv_x_byte_ctr		<= 4'd4;		//receiving 4 bytes of data
		end
		WRITE32_ADDR:begin
			rcv_x_byte();	
			if (rcv_x_byte_state == RCV_X_BYTE_DONE) begin
				HADDR 	<= addr_reg;
				HSIZE  	<= 3'b010;   			//word-sized
				HBURST 	<= 3'b000;   			//single burst
				HTRANS 	<= 2'b10;    			//nonsequential
				HWRITE 	<= 1'b1;     			//write phase
				write32_state <= WRITE32_WRITE_DATA;
			end else begin
				write32_state <= WRITE32_ADDR;
			end
		end
		WRITE32_WRITE_DATA: begin		
			HWDATA 		<= rcv_x_byte_reg;
			HTRANS  	<= 2'b00;
			HWRITE 		<= 1'b0;     				
			if (HREADY) begin								
				write_ctr 	<= write_ctr - 1; 		//decrement write counter
        			write32_state 	<= WRITE32_CHK_SEND;
			end else begin
				write32_state 	<= WRITE32_WRITE_DATA;
			end		
		end
		WRITE32_CHK_SEND: begin
   			if (write_ctr == 0) begin
        			write32_state <= WRITE32_DONE; 		//exit substate if counter is 0
      			end else begin
        			addr_reg 	<= addr_reg + 4;    	//increment address value
        			rcv_x_byte_ctr	<= 4'd4;     		//recieving 4 bytes of data
        			write32_state 	<= WRITE32_ADDR;   	//enter new address phase if counter is not 0
			end
		end
		WRITE32_DONE: begin
			rcv_x_byte_state <= START_RCV_X_BYTE;
			
		end
		default : begin
			write32_state <= WRITE32_START;
		end
	endcase
endtask

/*
 * NAME :: alive()
 * PURPOSE :: To send a byte of data through the UART.
 *            This is primarily used if the top-level
 *            state machine gets stuck in a read or write
 *            operation. In this case, the alive() command
 *            is used to attempt to get this state machine back
 *            into its IDLE state. Multiple alive() commands
 *            may be required to successfully achieve this.
 */
task alive;
	case (alive_state) 
		ALIVE_START: begin 
			//Byte "AE" indicates debugger is "alive"
			send_x_byte_reg   	<= 32'hAE000000;    
			send_x_byte_ctr 	<= 32'd1;
			send_x_byte();
			if (send_x_byte_state == SEND_X_BYTE_DONE) begin
				alive_state <= ALIVE_DONE;
			end else begin 
				alive_state <= ALIVE_START;	
			end	
		end
		ALIVE_DONE: begin
			alive_state 	 <= ALIVE_START;
		end
		/*default: begin
			alive_state <= ALIVE_START;
		end*/
	endcase
endtask

/*
	core_rst
	Function: Set the core_rst register to one
		  Keeps core in reset state until it is
		  release
*/
task core_rst;

	case (core_rst_state)  
		CORE_RST_SET:  begin 
			core_rst_reg <= 1'b1;
			core_rst_state <= CORE_RST_DONE;
		end
		
		CORE_RST_DONE:	begin
			core_rst_state <= CORE_RST_SET;
		end	
	endcase


endtask 

/*
	core_norm
	Function: Reset the core_rst register to 0
*/
task core_norm;

	case (core_norm_state) 
		CORE_NORM_SET:  begin 
			core_rst_reg <= 1'b0;
			core_norm_state <= CORE_NORM_DONE;
		end
		
		CORE_NORM_DONE:	begin
			core_norm_state <= CORE_NORM_SET;
		end	
	endcase


endtask 

assign M0_RST = (core_rst_reg) ? 1'b0 : rst_n; 

/*
 * NAME :: rcv_x_byte()
 * PURPOSE :: To receive an arbitrary amount of bytes of data 
 *            from the UART. This task is primarily used with the
 *            write commands.
 */
task rcv_x_byte;

	case(rcv_x_byte_state)
		START_RCV_X_BYTE:begin
			rcv_x_byte_reg 		<= 32'd0;
			rcv_x_byte_state 	<= UPDATE_IDLE;
		end
		UPDATE_IDLE:begin
			if (rcv_x_byte_ctr == 4'd0)begin
				rcv_x_byte_state <= RCV_X_BYTE_DONE;
			end else begin
				rcv_x_byte_state <= RECEIVE_BYTE;
			end
		end
		RECEIVE_BYTE:begin
			if (byte_rcv == 1'd1)begin
				rcv_x_byte_ctr <= rcv_x_byte_ctr - 4'd1;
				rcv_x_byte_reg <= {rcv_x_byte_reg[23:0],data_in};
				crc_reg <= next_crc8(data_in, crc_reg);   
				rcv_x_byte_state <= UPDATE_IDLE;
			end else begin 
				rcv_x_byte_state <= RECEIVE_BYTE;
			end
		end
		RCV_X_BYTE_DONE: begin 
			rcv_x_byte_state <= START_RCV_X_BYTE;
		end
		/*default: begin
			rcv_x_byte_state <= START_RCV_X_BYTE;
		end*/
	endcase

endtask

/*
 * NAME :: send_x_byte()
 * PURPOSE :: To send an arbitrary amount of bytes of data 
 *            through the UART. This task is primarily used with the
 *            read commands.
 */
task send_x_byte;
	case (send_x_byte_state)
		START_SEND_X_BYTE:begin 
			send_x_byte_state 	<= SEND_BYTE;
		end 
		SEND_BYTE: begin
			
			start_trans 	<= 1'b1;
			data_send 	<= send_x_byte_reg[31:24];
			

			if (byte_send == 1'b1) begin
				crc_reg 		<= next_crc8(send_x_byte_reg[31:24], crc_reg);
				send_x_byte_ctr 	<= send_x_byte_ctr - 1'b1;
				send_x_byte_state 	<= TRIM_BYTE;
				
			end else begin	
				send_x_byte_state 	<= SEND_BYTE;
			end
		end 
		TRIM_BYTE: begin 
			
			send_x_byte_reg <= {send_x_byte_reg[23:0], 8'b0};
			start_trans 	<= 1'b0;
			if (send_x_byte_ctr == 32'd0) begin 
				send_x_byte_state <= SEND_X_BYTE_DONE;
			end else begin
				send_x_byte_state <= SEND_BYTE;
			end 
		end 
		SEND_X_BYTE_DONE: begin 
			send_x_byte_ctr 	<= 32'd0;
 			send_x_byte_state 	<= START_SEND_X_BYTE;
		end
		/*default: begin
			send_x_byte_state 	<= START_SEND_X_BYTE;
		end*/
	endcase 
endtask
/*
`ifdef SOCET_DEBUG
	`include "debugger.v.assertions"
`endif
*/
endmodule

