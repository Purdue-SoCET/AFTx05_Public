/*
 * Vadim Nikiforov 
 * 10/5/2019
 * off-chip SRAM controller 
 *
 */
//`include "memory_blocks_if.vh"
//`include "offchip_sram_if.vh"

module offchip_sram_controller ( 
    input logic clk, nRST,
		memory_blocks_if.sram blkif,
		offchip_sram_if.controller offchip_sramif
	);
  parameter ADDR_BOTTOM = 32'h00008400;
  parameter ADDR_TOP    = 32'h00200000;
  parameter DELAY_MAX   = 0; 

  logic active; // is the request within the external sram's address range?

  assign active =  (blkif.addr >= ADDR_BOTTOM) && (blkif.addr <= ADDR_TOP);
  assign blkif.sram_active = active;

  logic [3:0] wait_count;
  logic [31:0] old_addr;
  logic [31:0] old_wdata;
  logic old_wen;

   //logic clock_mask_reg;

   //always_ff @(posedge clk or negedge clk or negedge nRST) begin
   //  if(!nRST) begin
   //    clock_mask_reg <= '0;
   //  end else begin
   //    clock_mask_reg <= !clock_mask_reg;
   //  end
   //end

  always_ff @(posedge clk, negedge nRST) begin 
    if (!nRST) begin
      wait_count <= 0;
      old_addr <= '1;
      old_wdata <= 32'hBAD1BAD1;
      old_wen <= 0;
    end else begin
      wait_count <= wait_count;
      if (wait_count > 0) wait_count <= wait_count - 1; 
      if(old_addr != blkif.addr || old_wdata != blkif.wdata || old_wen != blkif.wen) begin
        wait_count <= DELAY_MAX;
      end
      old_addr <= blkif.addr;
      old_wdata <= blkif.wdata;
      old_wen <= blkif.wen;
    end
  end

  assign blkif.sram_wait = wait_count != 0;


  always_comb begin : offchip_sram_controls
    // by default, disable everything
    offchip_sramif.nWE = 4'b1111;
    offchip_sramif.nCE = 1'b0;
    offchip_sramif.nOE = 1'b1;

    if (active) begin
      //offchip_sramif.nCE = 1'b0; // enable chip when address range matches
      offchip_sramif.nOE = 1'b0; // by default, enable output
      if (blkif.wen) begin
            offchip_sramif.nOE = 1'b1; // disable output if writing
            offchip_sramif.nWE = ~(blkif.byte_en);// | {4{clock_mask_reg}}; // invert byte enables for nWE
      end
    end 
  end

  always_comb begin : offchip_sram_data
     // lower two address bits are not needed, as this is handled by having four physical SRAMs
    offchip_sramif.external_addr = blkif.addr >> 2; 

    // offchip_sramif.external_wdata[0] = blkif.wdata[7:0];
    // offchip_sramif.external_wdata[1] = blkif.wdata[15:8];
    // offchip_sramif.external_wdata[2] = blkif.wdata[23:16];
    // offchip_sramif.external_wdata[3] = blkif.wdata[31:24];

    //if(blkif.wen) begin
    //  blkif.sram_rdata = '0;
    //end else begin
    //  blkif.sram_rdata[7:0] = offchip_sramif.external_rdata[0];
    //  blkif.sram_rdata[15:8] = offchip_sramif.external_rdata[1];
    //  blkif.sram_rdata[23:16] = offchip_sramif.external_rdata[2];
    //  blkif.sram_rdata[31:24] = offchip_sramif.external_rdata[3];
    //end

  end


  //assign offchip_sramif.external_bidir[7:0] = (!offchip_sramif.nWE[0]) ? ~offchip_sramif.external_wdata[0] : 8'bZ; 
  //assign offchip_sramif.external_bidir[15:8] = (!offchip_sramif.nWE[1]) ? ~offchip_sramif.external_wdata[1] : 8'bZ; 
  //assign offchip_sramif.external_bidir[23:16] = (!offchip_sramif.nWE[2]) ? ~offchip_sramif.external_wdata[2] : 8'bZ; 
  //assign offchip_sramif.external_bidir[31:24] = (!offchip_sramif.nWE[3]) ? ~offchip_sramif.external_wdata[3] : 8'bZ; 

  assign offchip_sramif.external_bidir[7:0] = (!offchip_sramif.nWE[0]) ?   blkif.wdata[7:0] : 8'bZ; 
  assign offchip_sramif.external_bidir[15:8] = (!offchip_sramif.nWE[1]) ?  blkif.wdata[15:8] : 8'bZ; 
  assign offchip_sramif.external_bidir[23:16] = (!offchip_sramif.nWE[2]) ? blkif.wdata[23:16] : 8'bZ; 
  assign offchip_sramif.external_bidir[31:24] = (!offchip_sramif.nWE[3]) ? blkif.wdata[31:24] : 8'bZ; 

always @ (posedge clk)
begin
    if(blkif.wen) begin
            blkif.sram_rdata <= '0;
    end else begin
            blkif.sram_rdata[7:0] <=  offchip_sramif.external_bidir[7:0];
            blkif.sram_rdata[15:8] <=  offchip_sramif.external_bidir[15:8];
            blkif.sram_rdata[23:16] <=  offchip_sramif.external_bidir[23:16];
            blkif.sram_rdata[31:24] <=  offchip_sramif.external_bidir[31:24];
    end

    //offchip_sramif.external_wdata[0] <= blkif.wdata[7:0];
    //offchip_sramif.external_wdata[1] <= blkif.wdata[15:8];
    //offchip_sramif.external_wdata[2] <= blkif.wdata[23:16];
    //offchip_sramif.external_wdata[3] <= blkif.wdata[31:24];
end

assign offchip_sramif.WE = ~offchip_sramif.nWE;


  // modport controller (
  //   output nCE, nOE, nWE, external_rdata
  //   input external_wdata
  // );

  // modport sram (
  //   input wen, wdata, addr, byte_en,
  //   output sram_rdata, sram_wait
  // );

endmodule
