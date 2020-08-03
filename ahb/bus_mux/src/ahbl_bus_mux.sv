/*
:set expandtab
:set tabstop=4
:set shiftwidth=4
:retab

*/

`include "ahbl_defines.vh"

module foo #(parameter MM=1)
    (ahbl.master m[MM:0], ahbl.slave s);

    assign m[0].HWDATA = s.HWDATA;

endmodule : foo

