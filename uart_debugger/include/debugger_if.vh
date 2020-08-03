`ifndef DEBUGGER_IF_VH
`define DEBUGGER_IF_VH


interface debugger_if;
    logic debug_rst, rx, tx, M0_RST;
    //ahb_if ahbif();

    modport debugger(
        input debug_rst, rx,
        output M0_RST, tx
        );
 
endinterface
`endif
