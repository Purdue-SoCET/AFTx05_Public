/*
 * Vadim Nikiforov 
 * 10/5/2019
 * top level controller for all memory blocks on the SoC
 *
 */

`include "memory_blocks_if.vh"

module memory_blocks(
  input logic clk, nRST,
  sram_controller_if.sram sramif,
  memory_blocks_if.soc_memory blkif
  );

 
  // blkif
  //modport soc_memory (
  //  output wen, wdata, addr, byte_en, mem_wait,
  //  input  rdata, sram_rdata, sram_wait, ram_rdata, ram_wait, rom_rdata, rom_wait
  //);
  //
  // sramif
  // modport sram (
  //   input wen, ram_wData, addr, byte_en, sram_en,
  //   output ram_rData, sram_wait
  // );
  logic [31:0] rdata_swapped;
  logic [31:0] rdata_mux;
  logic [31:0] wdata_reg;
  
  //always_ff @(posedge clk, negedge nRST) begin
  //  if (!nRST) begin
  //    sramif.ram_rData[0] <= '1;
  //  end else begin
  //    sramif.ram_rData[0] <= rdata_swapped;
  //  end
  //end
  
  // always_ff @(posedge clk, negedge nRST) begin
  //   if (!nRST) begin
  //     blkif.addr <= '1;
  //     blkif.wen <= '0;
  //     blkif.byte_en <= '0;
  //     wdata_reg <= '1;
  //   end else begin
  //     blkif.addr <= sramif.addr;
  //     blkif.wen <= sramif.wen;
  //     blkif.byte_en <= {sramif.byte_en[0], sramif.byte_en[1], sramif.byte_en[2], sramif.byte_en[3]};
  //     wdata_reg <= sramif.ram_wData;
  //   end
  // end

  logic [31:0] rom_rdata_reg;
  logic [31:0] ram_rdata_reg;
  logic [31:0] rom_active_reg;
  logic [31:0] ram_active_reg;
  logic [31:0] sram_active_reg;
  always_ff @(posedge clk, negedge nRST) begin
    if (!nRST) begin
      rom_rdata_reg <= '1;
      ram_rdata_reg <= '1;
      rom_active_reg <= '0;
      ram_active_reg <= '0;
      sram_active_reg <= '0;
    end else begin
      rom_rdata_reg <= blkif.rom_rdata;
      ram_rdata_reg <= blkif.ram_rdata;
      rom_active_reg <= blkif.rom_active;
      ram_active_reg <= blkif.ram_active;
      sram_active_reg <= blkif.sram_active;
    end
  end

  assign blkif.addr = sramif.addr;
  assign blkif.wen = sramif.wen;
  assign blkif.byte_en =  {sramif.byte_en[0], sramif.byte_en[1], sramif.byte_en[2], sramif.byte_en[3]};
  assign wdata_reg = sramif.ram_wData;

  assign sramif.ram_rData[0] = rdata_swapped;

  always_comb begin
    if (rom_active_reg) begin
      //rdata_mux = blkif.rom_rdata;
      rdata_mux = rom_rdata_reg;
      sramif.sram_wait = blkif.rom_wait;
    end else if (ram_active_reg) begin
      //rdata_mux = blkif.ram_rdata;
      rdata_mux = ram_rdata_reg;
      sramif.sram_wait = blkif.ram_wait;
    end else if(sram_active_reg) begin
      rdata_mux = blkif.sram_rdata;
      sramif.sram_wait = blkif.sram_wait;
    end else begin
      rdata_mux = 32'hBAD1BAD1;
    end
  end

  endian_swapper_ram write_swap(.word_in(wdata_reg),
                            .word_out(blkif.wdata));
  endian_swapper read_swap(.word_in(rdata_mux),
                            .word_out(rdata_swapped));

  // assign sramif.ram_rData = blkif.sram_rdata;
  //assign blkif.addr = sramif.addr;

endmodule
