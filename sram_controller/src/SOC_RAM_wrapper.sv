`include "memory_blocks_if.vh"

module SOC_RAM_wrapper(input logic clk, nRST, memory_blocks_if.ram blkif);

parameter integer ADDRBITSIZE = 16;
parameter integer DATABITSIZE = 32;
parameter integer TOPROM = 16;

parameter TOPSIZE = 255;
parameter BOTTOMSIZE = 7;
//parameter TOP_OFFSET = 16'h2db3;
parameter TOP_OFFSET = 16'h2000;
  //modport ram (
  //  input wen, wdata, addr, byte_en,
  //  output ram_rdata, ram_wait, ram_active
  //);
  
  logic [ADDRBITSIZE-1:0] bottom_addr;
  logic [ADDRBITSIZE-1:0] top_addr;

  logic [DATABITSIZE-1:0] TOPRAMdata;
  logic [DATABITSIZE-1:0] BOTTOMRAMdata;

  logic top_wen;
  logic bottom_wen;

  logic [ADDRBITSIZE-1:0] reg_addr;

  assign bottom_addr = blkif.addr >> 2;
  assign top_addr = (blkif.addr >> 2) - TOP_OFFSET;

  assign blkif.ram_wait = 1'b0;

  always_ff @(posedge clk, negedge nRST) begin
    if(!nRST) begin
      reg_addr <= '1;
    end else begin
      reg_addr <= (blkif.addr >> 2);
    end

  end

  always_comb begin
    if (bottom_addr <= BOTTOMSIZE) begin
      blkif.ram_rdata = BOTTOMRAMdata;
      bottom_wen = blkif.wen;
      top_wen = 1'b0;
      blkif.ram_active = 1'b1;
    end else if (top_addr <= TOPSIZE) begin
      blkif.ram_rdata = TOPRAMdata;
      top_wen = blkif.wen;
      bottom_wen = 1'b0;
      blkif.ram_active = 1'b1;
    end else begin
      blkif.ram_rdata = 32'hBAD1BAD1;
      top_wen = 1'b0;
      bottom_wen = 1'b0;
      blkif.ram_active = 1'b0;
    end
  end

	SOC_RAM #(.ADDRBIT(ADDRBITSIZE),.DATABIT(DATABITSIZE),.BOTTOMADDR(0),.TOPADDR(TOPSIZE)) TOPRAM(.clk(clk),.n_rst(nRST),.w_data(blkif.wdata),.addr(top_addr),.w_en(top_wen),.byte_en(blkif.byte_en),.r_data(TOPRAMdata));
	SOC_RAM #(.ADDRBIT(ADDRBITSIZE),.DATABIT(DATABITSIZE),.BOTTOMADDR(0),.TOPADDR(BOTTOMSIZE)) BOTTOMRAM(.clk(clk),.n_rst(nRST),.w_data(blkif.wdata),.addr(bottom_addr),.w_en(bottom_wen),.byte_en(blkif.byte_en),.r_data(BOTTOMRAMdata));

endmodule
