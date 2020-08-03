//`timescale 1ns / 10ns
// Documented Verilog UART
// Copyright (C) 2010 Timothy Goddard (tim@goddard.net.nz)
// Distributed under the MIT licence.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Version 2.0
// Date: 8/13/2015
// Updated by: Haoyue Gao, Jacob Stevens 
`timescale 1ns/10ps
module uart(
    input clk, // The master clock for this module
    input n_rst, // Synchronous reset.
    input rx, // Incoming serial line
    output tx, // Outgoing serial line
    input transmit, // Signal to transmit
    input [7:0] tx_byte, // Byte to transmit
    output received, // Indicated that a byte has been received.
    output [7:0] rx_byte, // Byte received
    output is_receiving, // Low when receive line is idle.
    output is_transmitting, // Low when transmit line is idle.
    output recv_error, // Indicates error in receiving packet.
    output sent
    );

parameter CLOCK_DIVIDE = 108; // clock rate (50Mhz) / (baud rate (115.2k) * 4)

// States for the receiving state machine.
// These are just constants, not parameters to override.
typedef enum reg [2:0] {
    RX_IDLE,
    RX_CHECK_START,
    RX_READ_BITS,
    RX_CHECK_STOP,
    RX_DELAY_RESTART,
    RX_ERROR,
    RX_RECEIVED} RX_STATE_t;

// States for the transmitting state machine.
// Constants - do not override.
typedef enum reg [2:0] {
    TX_IDLE,
    TX_SENDING,
    TX_DELAY_RESTART,
    TX_BYTE_SENT,
    TX_STOP} TX_STATE_t;


typedef struct {
    reg [5:0] countdown;
    reg [3:0] bits_remaining;
    reg [7:0] data;
    reg [10:0] clk_divider;
} rx_tx_t;

rx_tx_t rx_s, tx_s;
RX_STATE_t rx_state;// = RX_IDLE;
TX_STATE_t tx_state;// = TX_IDLE;
reg tx_out;

assign received = rx_state == RX_RECEIVED;
assign recv_error = rx_state == RX_ERROR;
assign is_receiving = rx_state != RX_IDLE;
assign rx_byte = rx_s.data;

assign tx = tx_out;
assign is_transmitting = tx_state != TX_IDLE;

assign sent = tx_state == TX_BYTE_SENT;
 
always @(posedge clk, negedge n_rst) begin
	if (n_rst==1'b0) begin
		rx_state = RX_IDLE;
		tx_state = TX_IDLE;
		rx_s.countdown = '0;
		rx_s.bits_remaining = '0;
		rx_s.data = '0;
		rx_s.clk_divider = '0;
		tx_s.countdown = '0;
		tx_s.bits_remaining = '0;
		tx_s.data = '0;
		tx_s.clk_divider = '0;

		tx_out = 0;
	end
	else begin	
	// The clk_divider counter counts down from
	// the CLOCK_DIVIDE constant. Whenever it
	// reaches 0, 1/16 of the bit period has elapsed.
   // Countdown timers for the receiving and transmitting
	// state machines are decremented.
	rx_s.clk_divider = rx_s.clk_divider - 1;
	if (!rx_s.clk_divider) begin
		rx_s.clk_divider = CLOCK_DIVIDE;
		rx_s.countdown = rx_s.countdown - 1;
	end
	tx_s.clk_divider = tx_s.clk_divider - 1;
	if (!tx_s.clk_divider) begin
		tx_s.clk_divider = CLOCK_DIVIDE;
		tx_s.countdown = tx_s.countdown - 1;
	end
	
	// Receive state machine
	case (rx_state)
		RX_IDLE: begin
			// A low pulse on the receive line indicates the
			// start of data.
			if (!rx) begin
				// Wait half the period - should resume in the
				// middle of this first pulse.
				rx_s.clk_divider = CLOCK_DIVIDE;
				rx_s.countdown = 2;
				rx_state = RX_CHECK_START;
			end
		end
		RX_CHECK_START: begin
			if (!rx_s.countdown) begin
				// Check the pulse is still there
				if (!rx) begin
					// Pulse still there - good
					// Wait the bit period to resume half-way
					// through the first bit.
					rx_s.countdown = 4;
					rx_s.bits_remaining = 8;
					rx_state = RX_READ_BITS;
				end else begin
					// Pulse lasted less than half the period -
					// not a valid transmission.
					rx_state = RX_ERROR;
				end
			end
		end
		RX_READ_BITS: begin
			if (!rx_s.countdown) begin
				// Should be half-way through a bit pulse here.
				// Read this bit in, wait for the next if we
				// have more to get.
				rx_s.data = {rx, rx_s.data[7:1]};
				rx_s.countdown = 4;
				rx_s.bits_remaining = rx_s.bits_remaining - 1;
				rx_state = rx_s.bits_remaining ? RX_READ_BITS : RX_CHECK_STOP;
			end
		end
		RX_CHECK_STOP: begin
			if (!rx_s.countdown) begin
				// Should resume half-way through the stop bit
				// This should be high - if not, reject the
				// transmission and signal an error.
				rx_state = rx ? RX_RECEIVED : RX_ERROR;
			end
		end
		RX_DELAY_RESTART: begin
			// Waits a set number of cycles before accepting
			// another transmission.
			rx_state = rx_s.countdown ? RX_DELAY_RESTART : RX_IDLE;
		end
		RX_ERROR: begin
			// There was an error receiving.
			// Raises the recv_error flag for one clock
			// cycle while in this state and then waits
			// 2 bit periods before accepting another
			// transmission.
			rx_s.countdown = 8;
			rx_state = RX_DELAY_RESTART;
		end
		RX_RECEIVED: begin
			// Successfully received a byte.
			// Raises the received flag for one clock
			// cycle while in this state.
			rx_state = RX_IDLE;
		end
	endcase
	
	// Transmit state machine
	case (tx_state)
		TX_IDLE: begin
            tx_s.countdown = 0; //Otherwise, will continue to decrement
			if (transmit) begin
				// If the transmit flag is raised in the idle
				// state, start transmitting the current content
				// of the tx_byte input.
				tx_s.data = tx_byte;
				// Send the initial, low pulse of 1 bit period
				// to signal the start, followed by the data
				tx_s.clk_divider = CLOCK_DIVIDE;
				tx_s.countdown = 4;
				tx_out = 0;
				tx_s.bits_remaining = 8;
				tx_state = TX_SENDING;
			end
		end
		TX_SENDING: begin
			if (!tx_s.countdown) begin
				if (tx_s.bits_remaining) begin
					tx_s.bits_remaining = tx_s.bits_remaining - 1;
					tx_out = tx_s.data[0];
					tx_s.data = {1'b0, tx_s.data[7:1]};
					tx_s.countdown = 4;
					tx_state = TX_SENDING;
				end else begin
					// Set delay to send out 2 stop bits.
					tx_out = 1;
					tx_s.countdown = 8;
					tx_state = TX_DELAY_RESTART;
				end
			end
		end
		TX_DELAY_RESTART: begin
			// Wait until tx_s.countdown reaches the end before
			// we send another transmission. This covers the
			// "stop bit" delay.
			tx_state = tx_s.countdown == 0 ? TX_BYTE_SENT :TX_DELAY_RESTART;
		end
	        TX_BYTE_SENT: begin
		   tx_state = TX_STOP;
		end
	        TX_STOP: begin
		   tx_state = TX_IDLE;
		end
	endcase
end
end
endmodule

