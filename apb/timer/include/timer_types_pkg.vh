/*
* Name: timer_types_pkg.vh
* Date: 2/2/2016
* Author: Jacob R. Stevens
*/

`ifndef TIMER_TYPES_PKG_VH
`define TIMER_TYPES_PKG_VH

// Each struct represents a timer configuration register.
// Since the APB bus is 32 bits wide, the high bits of 
// timer registers < 32 bits wide are padded with
// unimplemented bits. 
package timer_types_pkg;

typedef struct packed {
    logic [23:0] unimplementedIOS;
    logic [7:0] IOS;  
} IOSr;

typedef struct packed {
    logic [23:0] unimplementedTCF;
    logic [7:0] TCF;
} TCFr;

typedef struct packed {
    logic [31:0] TCNT;
} TCNTr;

typedef struct packed {
    logic [23:0] unimplementedTSCRhi;
    logic TCREN;
    logic TFCA;
    logic [5:0] unimplementedTSCRlo;
} TSCRr;

typedef struct packed {
    logic [23:0] unimplementedTOV;
    logic [7:0] TOV;
} TOVr;

typedef struct packed {
    logic [7:0] OM;         //TCR1
    logic [7:0] OL;         //TCR2
    logic [7:0] EDGEnA;   //TCR3
    logic [7:0] EDGEnB;   //TCR4
} TCRr;

typedef struct packed {
    logic [23:0] umimplementedTIE;
    logic [7:0] TIE;
} TIEr;

typedef struct packed {
    logic [23:0] unimplementedTSCR2hi;
    logic TOI;
    logic TCRE;
    logic [2:0] unimplementedTSCR2med;
    logic [2:0] PRE;
} TSCR2r;

typedef struct packed {
    logic [23:0] unimplementedFLG1;
    logic [7:0] TF;
} FLG1r;

typedef struct packed {
    logic [23:0] unimplementedFLG2hi;
    logic TOVF;
    logic [22:0] unimplementedFLG2lo;
} FLG2r;

typedef struct packed {
    logic [31:0] TCRn;
} TCNr;

endpackage

`endif
