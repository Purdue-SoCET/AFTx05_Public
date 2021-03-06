/*
MODULE NAME 	: tb_debugger_top
AUTHOR 		: Jacob Stevens
LAST UPDATE	: 6/30/15
VERSION 	: 1.0
DESCRIPTION 	: Uses files generated by python script as test cases
*/

`timescale 1ns/ 10ps
`include "debugger_if.vh"

module tb_debugger_top();
    //Define local parameters
    localparam CLK_PERIOD = 20;
    localparam SET_COUNT = 8'h82;
    localparam SET_ADDR = 8'h83;
    localparam READ32 = 8'h84;
    localparam WRITE32 = 8'h85;
    localparam ALIVE = 8'h86;
    localparam CORE_RST = 8'h87;
    localparam CORE_NORM = 8'h88;
    localparam T = 8'h54;
    localparam C = 8'h43;
    localparam R = 8'h52;
    localparam X = 8'h58;
    localparam LF = 8'h0A;
    localparam POUND = 8'h23;

    // Define DUT ports
    reg tb_clk;
    reg tb_n_rst;
    //reg uart_rx;
    //reg uart_tx;
    reg tb_transmit;
    reg [7:0] tb_tx_byte;
    reg tb_received;
    reg [7:0] tb_rx_byte;
    reg tb_is_receiving;
    reg tb_is_transmitting;
    reg tb_recv_error;
    integer test_file;
    integer output_file;
    reg [7:0] c;
    reg tb_start;

    reg [9:0] byte_count;
    reg [7:0] count_reg;

    ahb_if ahbif();
    debugger_if dif();    

    // Test bench states
    typedef enum bit [2:0] {
        IDLE,
        START,
        READ,
        CRC,
        WRITE,
        TASK,
        STOP,
        ERROR} tbState_t;

    typedef enum bit [2:0] {
        START_RECEIVE,
        SEND_COMMAND,
        RECEIVE_BYTE, 
        RECEIVE_CRC,
        STOP_RECEIVE} receiveState_t;

    typedef enum bit [1:0] {
            START_TRANSMIT,
            SEND_BYTE,
            TRANSMIT_CRC,
            STOP_TRANSMIT} transmitState_t;

    tbState_t state;
    receiveState_t receive_state;
    transmitState_t transmit_state;

    uart tb_uart(
                    .clk(tb_clk),
                    .n_rst(tb_n_rst),
                    .rx(dif.tx),
                    .tx(dif.rx),
                    .transmit(tb_transmit),
                    .tx_byte(tb_tx_byte),
                    .received(tb_received),
                    .rx_byte(tb_rx_byte),
                    .is_receiving(tb_is_receiving),
                    .is_transmitting(tb_is_transmitting),
                    .recv_error(tb_recv_error));

    debugger_top debugger_top(
                    .clk(tb_clk),
                    .n_Rst(tb_n_rst),
                    .dif(dif),
                    .ahbmif(ahbif));

    ahb_gen_slave ahb_gen_slave (
                    .HCLK(tb_clk),
                    .HRESETn(tb_n_rst),
                    .ahbsif(ahbif));

    // generate the test bench clock signal
    always
    begin
        tb_clk = 1'b0;
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        #(CLK_PERIOD/2.0);
    end

    always @(posedge tb_clk, negedge tb_n_rst)
    begin
        if (tb_n_rst == 1'b0)
        begin
            test_file = $fopen("../m0_debugger/resources/test.txt", "r");
            output_file = $fopen("../m0_debugger/resources/test_output.txt", "w");
            state <= IDLE;
            transmit_state <= START_TRANSMIT;
            receive_state <= START_RECEIVE;
        end
        else if (tb_start == 1'b1)
            state <= START;
        else
        begin
            tb_transmit = 1'b0;
            state <= state;
            case(state)
                START:
                begin
                    c = $fgetc(test_file);
                    case(c)
                        POUND:
                        begin
                            while(c != LF)
                                c = $fgetc(test_file);
                            $ungetc(c,test_file);
                            state <= START;
                        end
                        T:
                            state <= WRITE;
                        C:
                            state <= CRC;
                        R:
                            state <= READ;
                        X:
                            state <= STOP;
                        LF:
                        begin
                            state <= START;
                            /* Put new line back to introduce empty space */
                            $ungetc(c,test_file);
                        end
                        default:
                            state <= ERROR;
                    endcase
                    $fgetc(test_file); //consume empty space before data
                end
                WRITE:
                begin
                    //c = $fgetc(test_file);
                    $fscanf(test_file, "%2x", c);
                    tb_tx_byte = c;
                    tb_transmit = 1'b1;
                    state <= TASK;
                end
                READ:
                begin
                    //c = $fgetc(test_file);
                    $fscanf(test_file, "%2x", c);
                    tb_tx_byte = c;
                    tb_transmit = 1'b1;
                    state <= TASK;
                end
                TASK:
                begin
                    state <= TASK;
                    case(c)
                        SET_COUNT:
                        begin
                            transmit(1);
                            if (transmit_state == STOP_TRANSMIT)
                            begin
                                state <= START;
                                count_reg <= tb_tx_byte;
                            end
                        end
                        SET_ADDR:
                        begin
                            transmit(4);
                            if(transmit_state==STOP_TRANSMIT) state <= START;
                        end
                        READ32:
                        begin
                            receive(count_reg*4);
                            if (receive_state==STOP_RECEIVE) state <= START; 
                        end
                        WRITE32:
                        begin
                            transmit(count_reg*4);
                            if (transmit_state == STOP_TRANSMIT) state <= START;
                        end
                        ALIVE:
                        begin
                            receive(1);
                            if(receive_state==STOP_RECEIVE) state <= START;
                        end
                        CORE_RST:
                        begin
                            transmit(0);
                            if (transmit_state==STOP_TRANSMIT) state <= START;
                        end
                        CORE_NORM:
                        begin
                            transmit(0);
                            if (transmit_state==STOP_TRANSMIT) state <= START;
                        end
                    endcase
                end
                CRC:
                begin
                    c = $fgetc(test_file);
                    case(c)
                        LF:
                            state <= START;
                        default:
                            state <= CRC;
                    endcase
                end
                READ:
                begin
                    c = $fgetc(test_file);
                    case(c)
                    LF:
                        state <= START;
                    default:
                        state <= READ;
                    endcase
                end
                STOP:
                begin
                    $display("Simulation is over");
                    state <= STOP;
                    $finish;
                end
                ERROR:
                begin
                    $display("Error in file format (most likely)");
                    state <= ERROR;
                end
            endcase
        end
    end

task transmit(int count);
    case(transmit_state)
        START_TRANSMIT:
        begin
            transmit_state <= SEND_BYTE;
            byte_count <= count;
        end
        SEND_BYTE:
        begin
            if (byte_count == 0 && tb_is_transmitting == 1'b0)
                transmit_state <= TRANSMIT_CRC;
            else
            begin
                transmit_state <= SEND_BYTE;
                if (tb_is_transmitting == 1'b0)
                begin
                    /* Format of test file is 'FF FF', with a space        */
                    /* between hex values. This fgetc removes that space   */
                    $fgetc(test_file);
                    $fscanf(test_file, "%2x", tb_tx_byte);
                    tb_transmit = 1'b1;
                    byte_count <= byte_count - 1;
                end
            end
        end
        TRANSMIT_CRC:
        begin
            if (tb_received == 1'b0)
                transmit_state <= TRANSMIT_CRC;
            else
            begin
                transmit_state <= STOP_TRANSMIT;
                $fwrite(output_file, "%h\n", tb_rx_byte);
            end
        end
        STOP_TRANSMIT:
            begin
                /* Format of test file is 'FF ', with a trailing space     */
                /* This fgetc moves the file pointer past that space       */
                /* So that it is pointing at the NL, as expected by the tb */
                $fgetc(test_file);
                transmit_state <= START_TRANSMIT;
            end
    endcase
endtask

task receive(int count);
    case(receive_state)
        START_RECEIVE:
        begin
            receive_state <= SEND_COMMAND;
            byte_count <= count - 1;
        end
        SEND_COMMAND:
        begin
            if(tb_is_transmitting == 1'b1)
                receive_state <= SEND_COMMAND;
            else
                receive_state <= RECEIVE_BYTE;
        end
        RECEIVE_BYTE:
        begin
            if(byte_count == 0 && tb_received == 1'b1)
            begin
                receive_state <= RECEIVE_CRC;
                if (tb_rx_byte == 8'hae)
                    $fwrite(output_file,"%h ",tb_rx_byte);
            end
            else
            begin
                receive_state <= RECEIVE_BYTE;
                if (tb_received == 1'b1)
                begin
                    byte_count <= byte_count - 1;
                    if (tb_rx_byte == 8'hae)
                        $fwrite(output_file,"%h ",tb_rx_byte);
                end
            end
        end
        RECEIVE_CRC:
        begin
            if (tb_received == 1'b0)
                receive_state <= RECEIVE_CRC;
            else
            begin
                receive_state <= STOP_RECEIVE;
                // only log receive crcs when it is an alive command
                if (tb_rx_byte == 8'hfb)
                    $fwrite(output_file,"%h\n",tb_rx_byte);
            end
        end 
        STOP_RECEIVE:
            begin
                $fgetc(test_file);
                receive_state <= START_RECEIVE;
            end
    endcase
endtask

/* Asynchronized reset block*/
reg rff1;
reg tb_asyncrst_n;
always @(posedge tb_clk, negedge tb_asyncrst_n)
begin
    if (!tb_asyncrst_n)
        {tb_n_rst,rff1} <= 2'b0;
    else
        {tb_n_rst,rff1} <= {rff1,1'b1};
end
                    
    initial
    begin
        ahbif.HSEL <= 1'b1;     //Not output by the debugger so must generate
        ahbif.HREADY <= 1'b1;   //Not output by the debugger so must generate
        tb_start = 1'b0;
        #(CLK_PERIOD);
        #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_asyncrst_n = 1'b0;
        #(CLK_PERIOD);
        tb_asyncrst_n = 1'b1;
        #(CLK_PERIOD * 2);
        tb_start = 1'b1;
        @(posedge tb_clk);
        tb_start = 1'b0;
         
    end


endmodule 
