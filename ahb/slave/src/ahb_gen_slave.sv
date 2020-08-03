// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from The University of Southampton
// (c) COPYRIGHT 2010 The University of Southampton
// ALL RIGHTS RESERVED
// The entire notice above must be reproduced on all authorised
// copies and copies may only be made to the extent permitted
// by a licensing agreement from The University of Southampton.
//
// ---------------------------------------------------------------------
// Version and Release Control Information:
//
// File Name : gen_ahb_slave.v
// File Revision : 2.1, Kier Dugan
//
// ---------------------------------------------------------------------
// Purpose : Generic AHB slave.
// ---------------------------------------------------------------------
//
`include "ahb_if.vh"

module ahb_gen_slave (// slave interface
        input  logic             HCLK,
        input  logic             HRESETn,
        ahb_if.ahb_s             ahbsif
        /*
        // Split support
        input  logic             HMASTLOCK,
        input  logic     [ 3:0]  HMASTER,
        output logic     [15:0]  HSPLITx*/
);

// Configuration for the module
parameter  SLAVE_NAME   = "Slave";
parameter  DELAY        = 0;
parameter  MAX_DELAY    = 5;
parameter  MIN_DELAY    = 1;    
parameter  DEF_RDATA    = 32'hxxxxxxxx;
parameter  IDLE_RDATA   = 32'hdeadbeef;
parameter  ADDR_WIDTH   = 32;
localparam ADDR_MSB     = ADDR_WIDTH - 1;
localparam ADDR_MAX     = (1 << ADDR_WIDTH) - 1;
localparam MEM_SIZE     = 1 << (ADDR_WIDTH - 2);

// AHB slave responses
localparam RESP_OKAY    = 2'b00;
localparam RESP_ERROR   = 2'b01;
localparam RESP_RETRY   = 2'b10;
localparam RESP_SPLIT   = 2'b11;

// AHB transfer types   
localparam TRANS_IDLE   = 2'b00;
localparam TRANS_BUSY   = 2'b01;
localparam TRANS_NONSEQ = 2'b10;
localparam TRANS_SEQ    = 2'b11;

// Burst types          
localparam BURST_SINGLE = 3'b000;
localparam BURST_INCR   = 3'b001;
localparam BURST_WRAP4  = 3'b010;
localparam BURST_INCR4  = 3'b011;
localparam BURST_WRAP8  = 3'b100;
localparam BURST_INCR8  = 3'b101;
localparam BURST_WRAP16 = 3'b110;
localparam BURST_INCR16 = 3'b111;

// States
localparam STATE_IDLE   = 2'b00;
localparam STATE_ERROR  = 2'b01;
localparam STATE_READ   = 2'b10;
localparam STATE_WRITE  = 2'b11;

// Internal memory.
logic [3:0] [7:0] mem [ADDR_MSB : 0];

// Internal signals.
logic     [ 1:0]  state;
logic             error;
logic     [ 1:0]  error_code;
logic             delay;
logic     [31:0]  dummy;

// AHB buffers
logic     [31:0]  ahb_addr_r;
logic     [31:0]  ahb_rdata_r;

logic     [ 1:0]  ahb_resp;
logic     [31:0]  ahb_rdata;
logic     [31:0]  ahb_addr;
logic             ahb_ready;

// Sanity checks.
initial begin
    // Minimum delay must not be negative, and the maximum delay must be greater
    // than the minimum...
    if (MIN_DELAY < 0) begin
        $display ("%6.0dns %s: Error: Minimum delay must be non-negative!", $time,
            SLAVE_NAME);
        $stop;
    end else if (MAX_DELAY < MIN_DELAY) begin
        $display ("%6.0dns %s: Error: MAX_DELAY must be greater than MIN_DELAY",
            $time, SLAVE_NAME);
        $stop;
    end
end

// State machine.
always @ (posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
        state       <= STATE_IDLE;
        error       <= 1'b0;
        error_code  <= RESP_ERROR;
        delay       <= '0;
        ahb_addr_r  <= '0;
	dummy	    <= '0;
    end else begin
        if (~ahbsif.HSEL) begin
            // Must be idle if we aren't selected.
            state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
		    // Reset latency counter
		    dummy <= '0;

                    case (ahbsif.HTRANS)
                        // Remain idle.
                        TRANS_IDLE, TRANS_BUSY: begin
                            state <= STATE_IDLE;
                            error <= 1'b0;
                        end
                        
                        // This should not happen and is probably a host error.
                        TRANS_SEQ: begin
                            state       <= STATE_IDLE;
                            error       <= 1'b1;
                            error_code  <= RESP_ERROR;
                        end

                        // The start of a read or write operation.
                        TRANS_NONSEQ: begin
                            if (ahbsif.HWRITE)
                                state <= STATE_WRITE;
                            else
                                state <= STATE_READ;
                            
                            // Clear error.
                            error <= 1'b0;
                        end
                    endcase
                end
                
                STATE_READ, STATE_WRITE: begin
                    if (ahbsif.HADDR > ADDR_MAX) begin
                        // Return an error response if the address is out of
                        // range.
                        $display ("%6.0dns %s: Address 0x%08H is out of range!",
                            $time, SLAVE_NAME, ahbsif.HADDR);
                        state       <= STATE_IDLE;
                        error       <= 1'b1;
                        error_code  <= RESP_ERROR;
                    end else begin
			// Counter for latency
			if (DELAY > 0) begin			
				if (dummy == DELAY) begin
               	    			dummy <= 0;
				end else begin
					dummy <= dummy + 1;
				end
			end
				
                        delay <= ~delay;
                        case (ahbsif.HTRANS)
                            // Another transfer or a host idle.
                            TRANS_SEQ, TRANS_BUSY:
                                state <= state;     //STATE_WRITE;

                            TRANS_IDLE:
                                state <= (ahbsif.HREADY & ahbsif.HREADYOUT) ? STATE_IDLE : state;
                            
                            // A new, unrelated transfer.
                            TRANS_NONSEQ: begin
                                if (ahbsif.HWRITE)
                                    state <= STATE_WRITE;
                                else
                                    state <= STATE_READ;
                            end
                        endcase
                    end
                end
            endcase
            
            // Always cache address.
            if (ahbsif.HREADY & ahbsif.HREADYOUT)
                ahb_addr_r <= ahbsif.HADDR;
            
            // Do a memory write.
            if (state == STATE_WRITE & ahbsif.HREADYOUT) begin
                mem[ahb_addr_r[31:2]] <= ahbsif.HWDATA;
            end
        end
    end
end

// Combinatorial outputs.
always @ (state, ahbsif.HSEL, ahbsif.HTRANS, error, ahb_addr, delay, dummy) begin
    case (state)
        STATE_IDLE: begin
            // Output funky data if the slave is not selected so that incorrect
            // reads can be easily spotted.
            if (~ahbsif.HSEL)
                ahb_rdata = DEF_RDATA;
            else
                ahb_rdata = IDLE_RDATA;
                
            // Complete an error response.
            if (error) begin
                ahb_ready   = 1'b1;
                ahb_resp    = error_code;
            end else if (ahbsif.HTRANS == TRANS_SEQ) begin
                // A sequential transfer immediately from IDLE is wrong.
                ahb_ready   = 1'b0;
                ahb_resp    = RESP_ERROR;
            end else begin
                ahb_ready   = 1'b1;
                ahb_resp    = RESP_OKAY;
            end
        end
        
        /*STATE_ERROR: begin
            ahb_rdata   = '0;
            ahb_ready   = 1'b1;
            ahb_resp    = RESP_ERROR;
        end*/
        
        STATE_READ: begin
            if (ahbsif.HADDR /*ahb_addr*/ > ADDR_MAX) begin
                // Address is out of range, so return an error.
                ahb_rdata   = IDLE_RDATA;
                ahb_ready   = 1'b0;
                ahb_resp    = RESP_ERROR;
	    // Pull HREADY low during latency
            end else if (DELAY > 0 & dummy != DELAY) begin
		ahb_ready   = 1'b0;
            end else begin
                // Successfully return data.
                ahb_rdata   = mem[ahb_addr_r[ADDR_MSB:2]];
                ahb_ready   = 1'b1;    //delay;
                ahb_resp    = RESP_OKAY;
            end
        end
        
        STATE_WRITE: begin
            if (ahbsif.HADDR /*ahb_addr*/ > ADDR_MAX) begin
                // Address is out of range, so return an error.
                ahb_ready   = 1'b0;
                ahb_resp    = RESP_ERROR;
	    // Pull HREADY low during latency
            end else if (DELAY > 0 & dummy != DELAY) begin
		ahb_ready   = 1'b0;
            end else begin
                // Successfully return data.
                ahb_ready   = 1'b1;    //delay;
                ahb_resp    = RESP_OKAY;
            end
            
            // Return funky data or not.
            ahb_rdata = ahbsif.HSEL ? IDLE_RDATA : DEF_RDATA;
        end
    endcase
end

// Output assignments.
assign ahbsif.HRDATA   = ahb_rdata;
assign ahbsif.HREADYOUT   = ahb_ready;
assign ahbsif.HRESP    = ahb_resp;

// Input assignments.

// Internal assignments.
assign ahb_addr = ahb_addr_r;

/*
// Internal signals
logic             dphase;
logic             do_error_response;
logic             ahb_ready_r;
//logic     [31:0]  ahb_rdata_r;
//logic     [31:0]  ahb_addr_r;
logic     [ 1:0]  ahb_resp_r;
logic             ahb_write_r;
    
//logic    [31:0]  ahb_addr;
logic    [31:0]  ahb_addr_actual;

//logic            error;
logic            req;

//logic     [ 1:0]  ahb_resp;
//logic             ahb_ready;

logic             selected;
logic		HSELx;

logic     [31:0]  dummy;

logic [ADDR_MSB : 0] imm_addr;
logic [ADDR_MSB : 0] buf_addr;

// Signal assignments
//assign ahb_addr = { ahbsif.HADDR[31:2], 2'b00 };
assign ahb_addr_actual = { ahbsif.HADDR[31:2], 2'b00 };
assign imm_addr = (ahb_addr_actual[ADDR_MSB : 0] >> 2);
assign buf_addr = (ahb_addr_r[ADDR_MSB : 0] >> 2);
//assign HREADY   = ahb_ready_r;
assign ahbsif.HRDATA   = ahb_rdata_r;
//assign HRESP    = ahb_resp_r;    
//assign error    = (ahb_addr_actual > MEM_SIZE) ? 1'b1 : 1'b0;
assign req      = (ahbsif.HTRANS == TRANS_IDLE ||
                    ahbsif.HTRANS == TRANS_BUSY) ? 1'b0 : 1'b1;

assign ahbsif.HREADYOUT   = ahb_ready;
assign ahbsif.HRESP    = ahb_resp;

//assign ahb_addr = ahbsif.HREADYOUT ? ahb_addr_actual : ahb_addr_r;
//assign ahb_addr = ahb_addr_actual;

// Standard state machine
always @ (posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
        //mem         <= '0;
        dphase              <= '0;
        ahb_ready_r         <= '1;
        do_error_response   <= '0;
        ahb_rdata_r         <= '0;
        ahb_addr_r          <= '0;
        ahb_resp_r          <= '0;
        ahb_write_r         <= '0;
        selected            <= '0;
        dummy               <= '0;
        
        ahb_resp             = '0;
        ahb_ready            = '1;
    end else begin
        // Wait for select
        if (HSELx & ahbsif.HREADY & ~selected) begin
            selected <= 1'b1;
        end else if (~HSELx) begin
            selected <= 1'b0;
        end
        
        // Only operate when selected.
        if (selected) begin
            // Always save certain data from bus
            ahb_addr_r  <= ahbsif.HREADY ? ahb_addr_actual : ahb_addr_r;
            //ahb_addr_r  <= ahb_addr_actual;
            //ahb_write_r <= ahbsif.HWRITE;
            
            // Clear an error flag
            //if (do_error_response)
            //    do_error_response <= 1'b0;
            do_error_response <= error & ~do_error_response & req;
            
            // Handle error responses
            if (do_error_response) begin
                // Second cycle.
                ahb_ready = 1'b1;
                ahb_resp  = RESP_ERROR;
            end else if (error & req) begin
                // First cycle
                ahb_ready = 1'b0;
                ahb_resp  = RESP_ERROR;
            end else if (~req & dummy == 0) begin
                // Dummy responses to prevent stalling of the bus.
                //ahb_ready_r <= 1'b1;
                //ahb_resp_r  <= `RESP_OKAY;
                ahb_ready  = 1'b1;
                ahb_resp   = RESP_OKAY;
            end else begin // Process an actual request
                // Advance the counter
                if(DELAY > 0) begin
                    dummy <= dummy + 1;
                end
                
                // Register HWRITE
                if (ahbsif.HWRITE)
                    ahb_write_r <= 1'b1;
                
                if (dummy == DELAY) begin
                    // Always succeed at the moment.
                    dummy <= 0;
                    ahb_ready  = 1'b1;
                    ahb_resp   = RESP_OKAY;

                    // Do a write
                    // if (!(HWRITE && DELAY == 0) || ahb_write_r)
                    //if (HWRITE)
                    //    ahb_write_r <= 1'b1;
                    //else
                    if ((DELAY == 0 & ~ahbsif.HWRITE) || ~ahb_write_r)
                        if (DELAY == 0) begin
                            ahb_rdata_r <= mem[ahb_addr[ADDR_MSB : 0] >> 2];
                        end else begin
                            ahb_rdata_r <= mem[ahb_addr_r[ADDR_MSB : 0] >> 2];
                        end
                        //ahb_rdata_r <= mem[imm_addr];
                end else begin
                    ahb_ready   = 1'b0;
                    ahb_resp    = RESP_OKAY;
                end
            end
        end

        // May have to complete a write asynchronously with the bus.
        if (ahb_write_r) begin
            if (ahbsif.HREADYOUT) begin
                $display ("%6.0dns %s: Writing 0x%08H to address 0x%H", $time,
                    SLAVE_NAME, ahbsif.HWDATA, buf_addr);
            end
            mem[buf_addr] <= ahbsif.HWDATA;
            ahb_write_r <= ahbsif.HWRITE;
        end
    end
end */

endmodule

