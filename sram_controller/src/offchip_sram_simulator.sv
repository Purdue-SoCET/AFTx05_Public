/*
 * Vadim Nikiforov 
 * 10/5/2019
 * Simulation of an off-chip SRAM 
 *
 */

`timescale 1ns/10ps
`include "offchip_sram_if.vh"

module offchip_sram_simulator (
    input logic clk,
		offchip_sram_if.sram offchip_sramif
	);

  int fd, fd_w;
  int i;

  parameter RAM_SIZE = 'h10000;

  // word addressed memory contents
  logic [RAM_SIZE-1:0][31:0] memory_contents = '{default: '0};


  initial begin
    //fd = $fopen ("/local/scratch/a/socet30/SoCET_Public/meminit.hex", "r");
    //assert (fd) begin
    //  $display("Successfully opened meminit.hex: %0d", fd);
    //end else begin
    //  $display("Error opening meminit.hex: %0d", fd);
    //  $finish;
    //end

    //fd_w = $fopen ("/local/scratch/a/socet30/SoCET_Public/memsim.hex", "w");
    //assert (fd) begin
    //  $display("Successfully opened memsim.hex: %0d", fd);
    //end else begin
    //  $display("Error opening memsim.hex: %0d", fd);
    //  $finish;
    //end

    //while(read_init_line());
    //$fclose(fd);
    //#(1000000);
    //write_init_file();
    //$fclose(fd_w);
  end

  function write_init_file;
    int addr_idx;
    for(addr_idx = 0; addr_idx < RAM_SIZE; addr_idx++) begin
            if(memory_contents[addr_idx]) begin
            $fwrite(fd_w, ":04%04x00%08x00\n", addr_idx, memory_contents[addr_idx]);
            end
    end
    $fwrite(fd_w, ":00000001FF\n");

  endfunction

  function read_init_line;
    string temp;
    logic [31:0] addr;
    logic [31:0] data;
    int str_idx;
    
    // read :04
    $fgetc(fd);
    $fgetc(fd);
    if ($fgetc(fd) == 48) return 0;

    // read in the address
    temp = "             ";
    for(str_idx=0; str_idx < 4; str_idx++) begin
      temp[str_idx] = $fgetc(fd);
    end
    addr = temp.atohex();

    // read 00
    $fgetc(fd);
    $fgetc(fd);

    // read in the data
    temp = "               ";
    for(str_idx=0; str_idx < 8; str_idx++) begin
      temp[str_idx] = $fgetc(fd);
    end
    data = temp.atohex();

    // read the checksum (ignoring it)
    $fgetc(fd);
    $fgetc(fd);

    // read the newline
    $fgetc(fd);

    //$display("Got data %8H at addr %4H", data, addr);
    memory_contents[addr] = data;

    return 1;
  endfunction 

  //logic nCE;
  //logic nOE;
  //logic [3:0] nWE;

  //logic [3:0][7:0] external_rdata;
  //logic [3:0][7:0] external_wdata;
  //logic [15:0] external_addr;
  logic [3:0][7:0] offchip_sramif_external_rdata;
  
  always @(negedge clk) begin
    //offchip_sramif.external_rdata = 'z;
    offchip_sramif.external_rdata = '1;
    if(!offchip_sramif.nCE) begin
      if(!offchip_sramif.nOE) begin
        offchip_sramif_external_rdata[0] <= memory_contents[offchip_sramif.external_addr][7:0];
        offchip_sramif_external_rdata[1] <= memory_contents[offchip_sramif.external_addr][15:8];
        offchip_sramif_external_rdata[2] <= memory_contents[offchip_sramif.external_addr][23:16];
        offchip_sramif_external_rdata[3] <= memory_contents[offchip_sramif.external_addr][31:24];
      end else begin
        if(!offchip_sramif.nWE[0]) memory_contents[offchip_sramif.external_addr][7:0] <= offchip_sramif.external_wdata[0];
        if(!offchip_sramif.nWE[1]) memory_contents[offchip_sramif.external_addr][15:8] <= offchip_sramif.external_wdata[1];
        if(!offchip_sramif.nWE[2]) memory_contents[offchip_sramif.external_addr][23:16] <= offchip_sramif.external_wdata[2];
        if(!offchip_sramif.nWE[3]) memory_contents[offchip_sramif.external_addr][31:24] <= offchip_sramif.external_wdata[3];
      end
    end
  end

  assign offchip_sramif.external_bidir[7:0] = (!offchip_sramif.nWE[0]) ? 8'bZ : offchip_sramif.external_rdata[0]; 
  assign offchip_sramif.external_bidir[15:8] = (!offchip_sramif.nWE[1]) ? 8'bZ : offchip_sramif.external_rdata[1]; 
  assign offchip_sramif.external_bidir[23:16] = (!offchip_sramif.nWE[2]) ? 8'bZ : offchip_sramif.external_rdata[2]; 
  assign offchip_sramif.external_bidir[31:24] = (!offchip_sramif.nWE[3]) ? 8'bZ : offchip_sramif.external_rdata[3]; 


always @ (posedge clk)
begin
    offchip_sramif.external_wdata[0] <=  ~offchip_sramif.external_bidir[7:0];
    offchip_sramif.external_wdata[1] <=  ~offchip_sramif.external_bidir[15:8];
    offchip_sramif.external_wdata[2] <=  ~offchip_sramif.external_bidir[23:16];
    offchip_sramif.external_wdata[3] <=  ~offchip_sramif.external_bidir[31:24];

    offchip_sramif.external_rdata[0] <= offchip_sramif_external_rdata[0];
    offchip_sramif.external_rdata[1] <= offchip_sramif_external_rdata[1];
    offchip_sramif.external_rdata[2] <= offchip_sramif_external_rdata[2];
    offchip_sramif.external_rdata[3] <= offchip_sramif_external_rdata[3];
end


endmodule
