// File name:	tb_ahb_interconnect.sv
// Created:	2/25/2016
// Author:	Noah Chesnut
// Version:	1.0
// Description:	Test the interconnect connecting AHB master to AHB slaves

`timescale 1ns / 10ps

// Interfaces
`include "ahb_if.vh"
`include "ahb_slave_interconnect.vh"

module tb_ahb_interconnect();

// Define parameters
parameter CLK_PERIOD = 20;
parameter NUM_SLAVES = 4;

// Test variables
int testcase = 1, i;

// Variables and Interfaces
logic clk, n_rst;
ahb_if master ();
ahb_if slave0();
ahb_if slave1();
ahb_if slave2();
ahb_if slave3();
ahb_slave_interconnect_if slaves (slave0,slave1,slave2,slave3);

// AHB Interconnect
ahb_interconnect #(NUM_SLAVES) AHB_I (
	.CLK(clk),
	.nRST(n_rst),
	.master(master),
	.slaves(slaves)
);

// Clock Generation
always
begin : CLK_GEN
	clk = 1'b0;
	#(CLK_PERIOD / 2);
	clk = 1'b1;
	#(CLK_PERIOD / 2);
end

// Test Procedure
initial
begin
	// Initialize variables
	slave0.HREADYOUT = '0;
	slave0.HRESP = '0;
	slave0.HRDATA = '0;
	slave1.HREADYOUT = '0;
	slave1.HRESP = '0;
	slave1.HRDATA = '0;
	slave2.HREADYOUT = '0;
	slave2.HRESP = '0;
	slave2.HRDATA = '0;
   	slave3.HREADYOUT = '0;
	slave3.HRESP = '0;
	slave3.HRDATA = '0;
	master.HTRANS = '0;
	master.HWRITE = '0;
	master.HADDR = '0;
	master.HWDATA = '0;
	master.HSIZE = '0;
	master.HBURST = '0;
	master.HPROT = '0;
	master.HMASTLOCK = '0;

	// Reset
	n_rst = 1'b0;
	#20;
	@(negedge clk);
	n_rst = 1'b1;
	#(CLK_PERIOD);

	// Test 1: Select SRAM
	master.HADDR = 32'h20000000;
	master.HBURST = 3;
	master.HTRANS = 2;
	master.HWRITE = 1;
	master.HWDATA = 32'h12345678;
	checkslave(0, testcase);
	slave0.HREADYOUT = 1;
        slave1.HREADYOUT = 0;
        slave2.HREADYOUT = 0;
        slave3.HREADYOUT = 0;
	slave0.HRDATA = 32'h13241324;
	slave0.HRESP = 2;
	checkmaster(0, testcase);
	testcase++;

	// Test 2: Select First Peripheral
	master.HADDR = 32'h40000000;
	master.HBURST = 1;
	master.HTRANS = 3;
	master.HWRITE = 1;
	master.HWDATA = 32'hF940049F;
	checkslave(1, testcase);
	slave0.HREADYOUT = 0;
        slave1.HREADYOUT = 1;
	slave1.HRDATA = 32'h56785678;
	slave1.HRESP = 3;
	checkmaster(1, testcase);
	testcase++;

	// Test 3: Select Second Peripheral
	master.HADDR = 32'h55000000;
	master.HBURST = 0;
	master.HTRANS = 2;
	master.HWRITE = 0;
	master.HWDATA = 32'hF94453382;
	checkslave(2, testcase);
	slave1.HREADYOUT = 0;
        slave2.HREADYOUT = 1;
	slave2.HRDATA = 32'h33335678;
	slave2.HRESP = 0;
	checkmaster(2, testcase);
	testcase++;
   
	// Test 4: Select Flash
	master.HADDR = 32'hB0000000;
	master.HBURST = 2;
	master.HTRANS = 1;
	master.HWRITE = 1;
	master.HWDATA = 32'h87654321;
	checkslave(3, testcase);
        slave2.HREADYOUT = 0;
	slave3.HREADYOUT = 1;
	slave3.HRDATA = 32'hABCDABCD;
	slave3.HRESP = 1;
	checkmaster(3, testcase);
	testcase++;
        $stop();
end

task checkslave;
   input logic [NUM_SLAVES/2:0] slavenum;
   input int test;
   logic temp [NUM_SLAVES-1:0];
   int 	 k;
   begin
      #(CLK_PERIOD);
                for (k = 0; k< NUM_SLAVES; k++) temp[k]=0;
                temp[slavenum] = 1; 
		$display("Test %d: Select slave %d", test, slavenum);
		if (slaves.HSEL != temp)
			$error("Error: Slave %d not correctly selected", slavenum);
		if (slaves.HBURST[slavenum] != master.HBURST)
			$error("Error: Slave %d did not correctly receive HBURST", slavenum);
		if (slaves.HTRANS[slavenum] != master.HTRANS)
			$error("Error: Slave %d did not correctly receive HTRANS", slavenum);
		if (slaves.HWRITE[slavenum] != master.HWRITE)
			$error("Error: Slave %d did not correctly receive HWRITE", slavenum);
		if (slaves.HADDR[slavenum] != master.HADDR)
			$error("Error: Slave %d did not correctly receive HADDR", slavenum);
		if (slaves.HWDATA[slavenum] != master.HWDATA)
			$error("Error: Slave %d did not correctly receive HWDATA", slavenum);
	end
endtask

task checkmaster;
   input logic [NUM_SLAVES-1:0] slavenum;
   input int test;
	begin
		#(CLK_PERIOD);
		if (master.HREADY != slaves.HREADYOUT[slavenum])
			$error("Error: Master did not receive HREADY from slave %d", slavenum);
		if (master.HRDATA != slaves.HRDATA[slavenum])
			$error("Error: Master did not receive HRDATA from slave %d", slavenum);
		if (master.HRESP != slaves.HRESP[slavenum])
			$error("Error: Master did not receive HRESP from slave %d", slavenum);
	end
endtask

endmodule
