
`timescale 1ns/10ps
`define GPIO_R_IND 		0
`define GPIO_W_IND 		1
`define GPIO_EN_IND 	2

`define GPIO_DATA_ADDR 				32'h8000_1004
`define GPIO_EN_ADDR				32'h8000_1008
`define GPIO_DATA_ADDR2				32'h8000_2004
`define GPIO_EN_ADDR2				32'h8000_2008

`define COMMAND_SET_COUNT 		{1'b1,7'd2}
`define COMMAND_SET_ADDR 		{1'b1,7'd3}
`define COMMAND_READ_DATA		{1'b1,7'd4}
`define COMMAND_WRITE_DATA 		{1'b1,7'd5}
`define COMMAND_ALIVE			{1'b1,7'd6}
`define COMMAND_CORE_RST		{1'b1,7'd7}
`define COMMAND_CORE_NORM		{1'b1,7'd8}


module tb_top_chip;

parameter PERIOD = 20*5;
parameter S_BIT_PERIOD = 8620*5;

logic tx_o = 1'b1;
logic rx_i;
logic n_rst;
logic clk = 1'b1;
wire [7:0] gpio0_bidir_inout;
logic [7:0] gpio0_sel_out;
wire [7:0] gpio0_sel_sub_out;

logic [7:0] gpio_data;

logic [7:0] crc_data;

logic [18:0]offchip_sramif_external_addr;
logic [3:0] offchip_sramif_WE;
logic [3:0] offchip_sramif_nWE;
wire [31:0] offchip_sramif_external_bidir;
logic offchip_sramif_nOE;

offchip_sram_if offchip_sramif(offchip_sramif_external_bidir);

assign offchip_sramif.nWE = offchip_sramif_nWE;
assign offchip_sramif.nOE = offchip_sramif_nOE;
assign offchip_sramif.external_addr = offchip_sramif_external_addr;


assign (pull1, pull0) gpio0_bidir_inout = gpio_data; //(gpio0_sel_out) ? 8'bZ : gpio_data;

logic timer_sel_sub, timer_sel_out; 
wire timer_bidir;


assign timer_bidir = (timer_sel_out) ? 1'bZ : 1'b1;

//assign gpio0_bidir_inout = 8'b11111111;


wire [31:0] ram_pin_bidir;

// Remove references to external RAMs

top_chip aftx05(
  .clk_pad(clk),
  .asyncrst_n_pad(n_rst),
  // debugger signals
	.rx_pad(tx_o),
	.tx_pad(rx_i),
  // gpio
  .gpio_pad(gpio0_bidir_inout),
  .pwm_w_data_0_pad(),
  .timer_pad(timer_bidir),
  .ring_osc_out_pad(),
  .scan_en_pad('b0),
  .test_sig_pad('b0),
  .scan_in_1_pad('b0),
  .scan_out_1_pad(),
  .offchip_sramif_external_addr_pad(offchip_sramif_external_addr),
  .offchip_sramif_nWE_pad(offchip_sramif_nWE),
  .mem_data_pad(offchip_sramif_external_bidir),
  .offchip_sramif_nOE_pad(offchip_sramif_nOE)
);

// module top_chip( mem_data_pad, gpio_pad, timer_pad, ring_osc_out_pad, 
//                  pwm_w_data_0_pad, poli_X_pad, offchip_sramif_nWE_pad, offchip_sramif_nOE_pad, 
//                  offchip_sramif_external_addr_pad, tx_pad, scan_out_1_pad, poli_output_select_pad,
//                  poli_A_pad, poli_B_pad, poli_orient_pad, test_sig_pad, scan_en_pad, scan_in_1_pad, 
//                  clk_pad, asyncrst_n_pad, rx_pad

	task send_bits(input logic [8:0]data);
	//$display("Sending %d", data[7:0]);
	begin
		for(int i =0; i <= 10; i++) begin
			//repeat (435) begin
			//	@(posedge clk);
			//end
			case (i)
				0: tx_o <= 1'b0;
				1: tx_o <= data[i-1];
				2: tx_o <= data[i-1];
				3: tx_o <= data[i-1];
				4: tx_o <= data[i-1];
				5: tx_o <= data[i-1];
				6: tx_o <= data[i-1];
				7: tx_o <= data[i-1];
				8: tx_o <= data[i-1];
				9: tx_o <= 1'b1;
			endcase 
			#(S_BIT_PERIOD);
		end
		#(S_BIT_PERIOD);
	end
	endtask

	task receive_bits(output logic [7:0] data);
	begin
		//#(S_BIT_PERIOD*11);
		//@(negedge rx_i);
		//$display("Start receiving\n");
		//#(S_BIT_PERIOD);
		//for(int i = 0; i < 8; i++) begin
		//	#(S_BIT_PERIOD/2);
		//	data[i] <= rx_i;
		//	#(S_BIT_PERIOD/2);
		//end
		//#(S_BIT_PERIOD);
		//#(S_BIT_PERIOD);
	end
	endtask

	task reset;
	begin
		tx_o <= 1'b1;
		n_rst <= 1'b0;
		#1000;
		n_rst <= 1'b1;
	end
	endtask

	task set_count(input logic [7:0]count);
	begin
		send_bits(`COMMAND_SET_COUNT);
		send_bits(count);
		receive_bits(crc_data);
	end
	endtask

	task set_addr(input logic [31:0] addr);
	begin
		send_bits(`COMMAND_SET_ADDR);
		send_bits(addr[31:24]);
		send_bits(addr[23:16]);
		send_bits(addr[15:8]);
		send_bits(addr[7:0]);
		receive_bits(crc_data);
	end
	endtask
		
	task write32(input logic [31:0] data);
	begin
		send_bits(`COMMAND_WRITE_DATA);
		send_bits(data[31:24]);
		send_bits(data[23:16]);
		send_bits(data[15:8]);
		send_bits(data[7:0]);
		receive_bits(crc_data);
	end
	endtask

	task read32(output logic [31:0] rx_data);
	begin
		send_bits(`COMMAND_READ_DATA);
		//TODO: get uart data back
		receive_bits(rx_data[31:24]);
		receive_bits(rx_data[23:16]);
		receive_bits(rx_data[15:8]);
		receive_bits(rx_data[7:0]);

		receive_bits(crc_data);
	end
	endtask

	task alive;
	begin
		send_bits(`COMMAND_ALIVE);
		//debugger should return 0x00AE through UART
		receive_bits(crc_data);
	end
	endtask

	task core_rst;
	begin
		send_bits(`COMMAND_CORE_RST);
		#(S_BIT_PERIOD*11);
	end
	endtask

	task core_norm;
	begin
		send_bits(`COMMAND_CORE_NORM);
		#(S_BIT_PERIOD*11);
	end
	endtask

	//Clock generation
	initial begin	
		clk = 1'b1;
		forever #(PERIOD/2) clk = ~clk;
	end

  task writeSRAM(input logic [31:0] addr, input logic [31:0] data);
  begin
  		
		set_addr(addr);
		//$display("Writing to the SRAM\n");
		set_count(8'h1);
		write32(data);
		//$display("Wrote to the SRAM\n");
  end
  endtask
	
  task readSRAM(input logic [31:0] addr);
  begin
  		
		set_addr(addr);
		//$display("Reading from the SRAM\n");
		set_count(8'h1);
		read32();
		//$display("Read from the SRAM\n");
  end
  endtask

	task loadFile();
	integer data_file;
	logic [31:0] ram_addr;
	logic [31:0] ram_data;
	begin
		$display("Loading file!");
		ram_addr = 32'h0000_0000;
		ram_data = 32'hBAD1_C0DE;
	
		data_file = $fopen("/local/scratch/a/socet20/bit_reads.mif", "r");
		if (!data_file) begin
			return;
		end

		//while(!$feof(data_file) && (ram_addr < 32'h0000_02E0)) begin
		while(!$feof(data_file)) begin
			
			$fscanf(data_file, "%d:%h;\n", ram_addr, ram_data);
			$display("SRAM[0x%h] <= 0x%h", ram_addr, ram_data);
			writeSRAM({ram_addr,2'b0}, ram_data);

		end
	end
	endtask

	//write and read using debugger
	
        int x;
	initial begin
		$sdf_annotate("top_chip.sdf.X",aftx05,,"sdf_chip.log","MINIMUM");
    gpio_data = 8'h00;
    #10;
    gpio_data = 8'h01;
		$display("About to Reset\n");
    //TODO, need to update to actual path for pnr output
    reset();
		$display("Reset\n");
    #(2_000*5);
    gpio_data = 8'h00;
		core_rst();
    #(600_000*5);
        //writeSRAM(32'h8000, 32'h800000b7);
        //writeSRAM(32'h8004, 32'h00408093);
        //writeSRAM(32'h8008, 32'h0ff00113);
        //writeSRAM(32'h800C, 32'h0020a223);
        //writeSRAM(32'h8010, 32'h0dd00113);
        //writeSRAM(32'h8014, 32'h0020a023);
        //writeSRAM(32'h8018, 32'h0000006f);
        //writeSRAM(32'h801C, 32'h00100093);
        //writeSRAM(32'h8020, 32'h00100113);
        //writeSRAM(32'h8024, 32'h00000097);
        //writeSRAM(32'h8028, 32'h3c20ae23);
        //writeSRAM(32'h802C, 32'hfd5ff06f);
        //writeSRAM('0, 32'h8000);

        x = 'h00;

        // test upload of code to bottom of SRAM addr
        writeSRAM(32'h8400 - x, 32'h800000b7);
        writeSRAM(32'h8404 - x, 32'h00408093);
        writeSRAM(32'h8408 - x, 32'h0ff00113); // works
        writeSRAM(32'h840C - x, 32'h0020a223); // works
        writeSRAM(32'h8410 - x, 32'h0dd00113); // doesn't work
        writeSRAM(32'h8414 - x, 32'h0020a023);
        writeSRAM(32'h8418 - x, 32'h0000006f); // doesn't work
        writeSRAM(32'h841C - x, 32'h00100093);
        writeSRAM(32'h8420 - x, 32'h00100113);
        writeSRAM(32'h8424 - x, 32'h00000097);
        writeSRAM(32'h8428 - x, 32'h3c20ae23); // resume here, works
        writeSRAM(32'h842C - x, 32'hfd5ff06f);
        writeSRAM('0, 32'h8400 - x);

        // test upload of code to bottom of SRAM addr
        //writeSRAM(32'h8404, 32'h800000b7);
        //writeSRAM(32'h8408, 32'h00408093);
        //writeSRAM(32'h840C, 32'h0ff00113); // works
        //writeSRAM(32'h8410, 32'h0020a223);
        //writeSRAM(32'h8414, 32'h0dd00113); // doesn't work
        //writeSRAM(32'h8414, 32'h0020a023);
        //writeSRAM(32'h8418, 32'h0000006f); // doesn't work
        //writeSRAM(32'h841C, 32'h00100093);
        //writeSRAM(32'h8420, 32'h00100113);
        //writeSRAM(32'h8424, 32'h00000097);
        //writeSRAM(32'h8428, 32'h3c20ae23);
        //writeSRAM(32'h842C, 32'hfd5ff06f);
        //writeSRAM('0, 32'h8404);
    //writeSRAM('0, 32'h12345678);
    //writeSRAM(32'h4, 32'hAAAAAAAA);
    //alive();
		//core_norm();		
		//core_rst();
    //alive();
		
  end
	
endmodule




