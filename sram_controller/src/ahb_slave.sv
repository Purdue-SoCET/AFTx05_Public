/*
    Created by: John Skubic

    AHB Slave functionality based off of the AMBA 3 specification

*/

module ahb_slave
(
    //AHB Signals
    input logic HCLK, HRESETn, HMASTLOCK, HWRITE, HSEL, HREADYIN,
    input logic [31:0] HADDR, HWDATA,
    input logic [1:0] HTRANS,
    input logic [2:0] HBURST, HSIZE,
    input logic [3:0] HPROT, 

    output logic [31:0] HRDATA,
    output logic HREADYOUT, 
    output logic HRESP, 

    //slave interface signals
    input logic burst_cancel,       //slave requests to cancel a burst; tie to 0 if not used
    input logic slave_wait,         //slave is busy and needs wait cycles; tie to 0 if not used
    input logic [31:0] rdata,       //read data

    output logic [31:0] wdata, addr, //address and write data
    output logic r_prep, w_prep, //read/write data needs to be provided next cycle corresponding to the current addr
    output logic wen, ren,    //write or read data should be valid, this is needed in case wait states are after a prep
    output logic [2:0] size,  //size of the data according to AHB spec (passthrough of HSIZE)
    output logic [4:0] burst_count,  //current beat count, count increments after the trans data phase, can be safely ignored
    output logic [2:0] burst_type //burst type, according to AHB spec, can be safely ignored
);

    parameter BASE_ADDRESS = 0;
    parameter NUMBER_ADDRESSES = 1024; //byte addresses

    localparam MAX_ADDRESS = BASE_ADDRESS + NUMBER_ADDRESSES - 1;

    //HTRANS VALUES
    localparam TRANS_IDLE =   2'b00;
    localparam TRANS_BUSY =   2'b01;
    localparam TRANS_NONSEQ = 2'b10;
    localparam TRANS_SEQ =    2'b11;

    //HBURST VALUES
    localparam BURST_SINGLE = 3'b000;
    localparam BURST_INCR =   3'b001; //undefined length
    localparam BURST_WRAP4 =  3'b010;
    localparam BURST_INCR4 =  3'b011;
    localparam BURST_WRAP8 =  3'b100;
    localparam BURST_INCR8 =  3'b101;
    localparam BURST_WRAP16 = 3'b110;
    localparam BURST_INCR16 = 3'b111;

    //HRESP VALUES
    localparam RESP_OK =    1'b0;
    localparam RESP_ERROR = 1'b1;

    //state machine states
    typedef enum {
        IDLE, READ, WRITE, ERROR_C1, ERROR_C2 //errors require two cycles
    } AHB_STATE;

    //local vars
    AHB_STATE current;
    AHB_STATE next;
    logic save_addr;
    logic [4:0] count; 

    always_ff @ (posedge HCLK, negedge HRESETn) begin
        //state machine
        if (~HRESETn) 
            current <= IDLE;
        else
        begin
            current <= next;

             //transfer beat count
             if (~HRESETn)
                 count <= '0;
             else if (HTRANS == TRANS_NONSEQ)
                 count <= 1;
            else if (HTRANS == TRANS_SEQ) 
                count <= count + 1;
            else
                count <= count;
        end
    end

    //next state logic
    always_comb begin  

        casez (current)
            IDLE : begin
                if(HSEL && HREADYIN) begin //if selected and previous transfer has completed
                    if((HADDR > MAX_ADDRESS) | (HTRANS != TRANS_NONSEQ)) //addr out of range or bad trans type
                        next = ERROR_C1;
                    else if (HWRITE) 
                        next = WRITE;
                    else 
                        next = READ;
                end
                else //slave not selected
                    next = IDLE;
            end

            READ : begin
                if (burst_cancel) //cancel requested by the slave
                    next = ERROR_C1;
                else if (HTRANS == TRANS_BUSY) 
                    next = READ;
                else if (HREADYIN && HSEL) begin
                    if (HADDR > MAX_ADDRESS) 
                        next = ERROR_C1;
                    else if (~HWRITE && HSEL)
                        next = READ;
                    else if ((HTRANS == TRANS_NONSEQ) && HWRITE && HSEL) 
                        next = WRITE;
                    else //new transfers have to begin with NONSEQ 
                        next = ERROR_C1;
                end
                else //slave not selected
                    next = IDLE;
            end

            WRITE : begin
                if (burst_cancel) //cancel requested by the slave
                    next = ERROR_C1;
                else if (HTRANS == TRANS_BUSY)
                    next = WRITE;
                else if (HREADYIN && HSEL) begin
                    if (HADDR > MAX_ADDRESS)
                        next = ERROR_C1;
                    else if (HWRITE && HSEL)
                        next = WRITE;
                    else if ((HTRANS == TRANS_NONSEQ) && HSEL && ~HWRITE)
                        next = READ;
                    else
                        next = ERROR_C1;
                end
                else
                    next = IDLE;
            end

            //two cycle error response
            ERROR_C1 : begin
                next = ERROR_C2;
            end

            ERROR_C2 : begin
                next = IDLE;
            end

            default : begin
                next = IDLE;
            end
        endcase
    end


    //output logic
    assign HRESP = ((current == ERROR_C1) | (current == ERROR_C2)) ? RESP_ERROR : RESP_OK;
    assign HREADYOUT = (current == ERROR_C1) ? 1'b0 : (
                    (current == ERROR_C2) ? 1'b1 : 
                    ~slave_wait); //follow error response, otherwise give control to slave
    assign HRDATA = rdata; //if there is pending read data, choose it
    assign wdata = HWDATA;
    assign addr = HADDR;
    assign burst_type = HBURST;
    assign wen = (current == WRITE) && (HTRANS != TRANS_BUSY); //write initiated and the master does not request a wait
    assign w_prep = (HSEL && (HADDR <= MAX_ADDRESS) && HWRITE && (HTRANS != TRANS_BUSY)); //if a write is impending
    assign ren = (current == READ) && (HTRANS != TRANS_BUSY); //read initiated and the master does not request a wait
    assign r_prep = (HSEL && (HADDR <= MAX_ADDRESS) && ~HWRITE && (HTRANS != TRANS_BUSY)); //if a read is impending
    assign burst_count = count;
    assign size = HSIZE;
    


                    


endmodule
