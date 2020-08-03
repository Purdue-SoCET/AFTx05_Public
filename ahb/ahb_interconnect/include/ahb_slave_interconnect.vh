`ifndef AHB_SLAVE_INTERCONNECT_VH
`define AHB_SLAVE_INTERCONNECT_VH

`include "ahb_if.vh"

`define AHB_INTER_NUM_SLAVES 3

`define SLAVE_CONNECT(id) \
  assign ahbif_``id``.HTRANS    = HTRANS[``id``]; \
  assign ahbif_``id``.HWRITE    = HWRITE[``id``]; \
  assign ahbif_``id``.HADDR     = HADDR[``id``]; \
  assign ahbif_``id``.HWDATA    = HWDATA[``id``]; \
  assign ahbif_``id``.HSIZE     = HSIZE[``id``]; \
  assign ahbif_``id``.HSEL      = HSEL[``id``]; \
  assign ahbif_``id``.HBURST    = HBURST[``id``]; \
  assign ahbif_``id``.HREADY    = HREADY[``id``]; \
  assign ahbif_``id``.HPROT     = HPROT[``id``]; \
  assign ahbif_``id``.HMASTLOCK = HMASTLOCK[``id``]; \
  assign HREADYOUT[``id``]      = ahbif_``id``.HREADYOUT; \
  assign HRESP[``id``]          = ahbif_``id``.HRESP; \
  assign HRDATA[``id``]         = ahbif_``id``.HRDATA; 

interface ahb_slave_interconnect_if(
  ahb_if ahbif_0,
  ahb_if ahbif_1,
  ahb_if ahbif_2
);

  logic [1:0]   HTRANS    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [1:0]   HRESP     [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [2:0]   HSIZE     [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [31:0]  HADDR     [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [31:0]  HWDATA    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic         HWRITE    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic         HREADY    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic         HREADYOUT [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic         HSEL      [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic         HMASTLOCK [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [31:0]  HRDATA    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [2:0]   HBURST    [`AHB_INTER_NUM_SLAVES - 1 : 0];
  logic [3:0]   HPROT     [`AHB_INTER_NUM_SLAVES - 1 : 0];

  `SLAVE_CONNECT(0)
  `SLAVE_CONNECT(1)
  `SLAVE_CONNECT(2)

  modport interconnection (
    output  HTRANS, HWRITE, HADDR, HWDATA, HSIZE, HSEL,
            HBURST, HREADY, HPROT, HMASTLOCK,
    input   HREADYOUT, HRESP, HRDATA
  );

endinterface

`endif //AHB_SLAVE_INTERCONNECT_VH
