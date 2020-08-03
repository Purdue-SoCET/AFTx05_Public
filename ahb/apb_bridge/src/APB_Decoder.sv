/*
// File name:   APB_Decoder.sv
// Created:     6/18/2014
// Author:      Xin Tze Tee
// Version:     1.0 
// Description: APB Decoder for AHB to APB Bridge.
                Decodes address sent from AHB Master to select which peripherals 
                to communicate with.
*/

module APB_Decoder
#(
  parameter NUM_SLAVES = 2
)
(
	input wire [31:0] PADDR,
	input wire psel_en,
	input wire [31:0] PRData_in [NUM_SLAVES-1:0],

  output wire [31:0] PRDATA_PSlave,
	output wire [NUM_SLAVES-1:0] PSEL_slave
);

logic [NUM_SLAVES-1:0] psel_slave_reg; //one hot select for slave 
int i;

/* psel_slave uses n bits where each bit corresponds to 
   the PSEL for each peripherals. (one hot)
*/
always_comb
begin
  psel_slave_reg = '0;
  if (psel_en) begin   
    psel_slave_reg = 1 << PADDR[23:16];
  end
end //always block

assign PSEL_slave = psel_slave_reg;

// Read Selection MUX                 
assign PRDATA_PSlave = PRData_in[PADDR[23:16]];

endmodule
