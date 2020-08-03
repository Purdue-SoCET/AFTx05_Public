/* 
   Interface for the I/O of GPIO (top level)

   Author: Dwezil D'souza
*/

`ifndef GPIO_IF_VH
`define GPIO_IF_VH

interface gpio_if(inout [7:0] gpio_bidir);

  parameter NUM_PINS = 8; //MAX32

  logic interrupt;
  //wire [NUM_PINS - 1 : 0] gpio_bidir;  
  logic [NUM_PINS - 1 : 0] r_data;
  logic [NUM_PINS - 1 : 0] w_data;
  logic [NUM_PINS - 1 : 0] en_data; 

  modport gpio( 
    output interrupt, en_data,
    output w_data, r_data,
    inout gpio_bidir
  );

endinterface

`endif //GPIO_IF_VH
