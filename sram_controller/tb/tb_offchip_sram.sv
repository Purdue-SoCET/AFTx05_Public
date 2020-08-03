`timescale 1ns/1ns

`include "offchip_sram_if.vh"
`include "memory_blocks_if.vh"

module tb_offchip_sram();

int i;
logic tb_clk, tb_nRST;

offchip_sram_if offchip_sramif();
memory_blocks_if blkif();


offchip_sram_controller DUT(tb_clk, tb_nRST, blkif, offchip_sramif);
offchip_sram_simulator SRAM(offchip_sramif);

//  modport sram (
//    input wen, wdata, addr, byte_en,
//    output sram_rdata, sram_wait
//  );


  initial begin
     for(i = 0; i<1024; i++) begin
       blkif.wen = '0;
       blkif.addr = i*4;
       blkif.byte_en = 4'b1111;
       blkif.wdata = '1;
       #10;
     end
/*
     for(i = 0; i<64; i++) begin
       offchip_sramif.external_wdata = '1;
       offchip_sramif.nWE = '1;
       offchip_sramif.nCE = '1;
       offchip_sramif.nOE = '0;
       offchip_sramif.external_addr = i;
       #10;
     end
     for(i = 0; i<64; i++) begin
       offchip_sramif.external_wdata = 32'hDEADBEEF;
       offchip_sramif.nWE = 4'b1010;
       offchip_sramif.nCE = '0;
       offchip_sramif.nOE = '1;
       offchip_sramif.external_addr = i;
       #10;
     end
     for(i = 0; i<64; i++) begin
       offchip_sramif.external_wdata = '1;
       offchip_sramif.nWE = '1;
       offchip_sramif.nCE = '0;
       offchip_sramif.nOE = '0;
       offchip_sramif.external_addr = i;
       #10;
     end
     $finish;
*/
  end

endmodule
