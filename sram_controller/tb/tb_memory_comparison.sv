`timescale 1ns/1ns

`include "sram_controller_if.vh"
`include "offchip_sram_if.vh"
`include "memory_blocks_if.vh"

module tb_memory_comparison;

  parameter PERIOD = 10;

  sram_controller_if #(.N_SRAM(1)) sramif_old();
  sram_controller_if #(.N_SRAM(1)) sramif_new();
  memory_blocks_if blkif();
  offchip_sram_if offchip_sramif();

  logic clk;
  logic nRST;

  integer i;

  onchip_sram #(.SRAM_ID(0)) onchip_sram(clk,nRST, sramif_old);

  memory_blocks mem_blocks(clk, nRST, sramif_new, blkif);
  offchip_sram_controller offchip_sram(clk, rst_n, blkif, offchip_sramif);
  offchip_sram_simulator  sram_sim(offchip_sramif);

  //modport controller (
  //  output wen, ram_wData, addr, byte_en, sram_en,
  //  input ram_rData, sram_wait
  //);

  assign sramif_new.wen = sramif_old.wen;
  assign sramif_new.ram_wData = sramif_old.ram_wData;
  assign sramif_new.addr = sramif_old.addr;
  assign sramif_new.byte_en = sramif_old.byte_en;
  assign sramif_new.sram_en = sramif_old.sram_en;

  always begin
    clk = clk + 1;
    #(PERIOD/2);
  end

  initial begin
    clk = 0;
    nRST = 1;
    @(negedge clk);
    nRST = 0;
    sramif_old.wen = 0;
    sramif_old.ram_wData = '0;
    sramif_old.addr = '0;
    sramif_old.byte_en = '1;
    sramif_old.sram_en = 1;
    @(negedge clk);
    nRST = 0;
    @(posedge clk);
    nRST = 1;
    for(i = 0; i < 2048; i++) begin
      @(negedge clk);
      sramif_old.addr = i*4;
      @(posedge clk);
      assert (sramif_old.ram_rData === 'x || sramif_new.ram_rData == sramif_old.ram_rData) else $display("MISMATCH BETWEEN RAMS (w_addr: %X): old: %X, new: %x",i,  sramif_old.ram_rData, sramif_new.ram_rData);
    end

    $finish;
  end
endmodule
