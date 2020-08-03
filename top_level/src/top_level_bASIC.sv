/*
* Top level file for the bASIC chip
* Intended tape out: November 3rd, 2015
* Authors:  Jacob Stevens
*           John Skubic
*           Dwezil D'souza
*/

//`include "top_level_bASIC_if.vh"
`include "apb_if.vh"
`include "gpio_if.vh"
`include "debugger_if.vh"
`include "ahb2apb_if.vh"
`include "timer_if.vh"
//`include "m0_if.vh"
`include "sram_controller_if.vh"
`include "memory_blocks_if.vh"
`include "offchip_sram_if.vh"
//`include "top_level_macros.vh"
/* Reset synchronizer */
module reset_synchronizer_n (
        input  logic clk,
        input  logic async_reset,
        output logic sync_reset);

        logic reset_flop;
        always @ (posedge clk or negedge async_reset)
        begin
            if (!async_reset)
                {sync_reset,reset_flop} <= 2'b0;
            else
                {sync_reset,reset_flop} <= {reset_flop,1'b1};
        end
endmodule

module top_level_bASIC #(
  parameter NUM_GPIO_PINS = 8,
  parameter NUM_PWM_PINS = 1,
  parameter NUM_TIMER_PINS = 1,
  parameter SRAM_DEPTH =32'h3fff_ffff,
  parameter NUM_SRAM = 1,
  parameter NUM_AHB_SLAVES = 3,
  parameter NUM_APB_SLAVES = 6
)(
    input logic clk,
    input logic asyncrst_n,
    /* Debugger Signals */
    input logic rx,
    output logic tx,
    /* GPIO Signals */  
    inout logic [NUM_GPIO_PINS-1:0] gpio_bidir_io,
    output logic [NUM_GPIO_PINS-1:0] gpio_sel_out,
    output logic [NUM_GPIO_PINS-1:0] gpio_sel_sub,
    /* PWM Signals */
    output logic [NUM_PWM_PINS-1:0] pwm_w_data_0,
    /* Timer Signals */
    inout  wire [NUM_TIMER_PINS-1:0] timer_bidir_0,
    output logic [NUM_TIMER_PINS-1:0] timer_sel_out,
    output logic [NUM_TIMER_PINS-1:0] timer_sel_sub,
    /* RO stuff */
//	  input logic ring_osc_en,
    output logic ring_osc_out,
    /* Memory stuff */
    output logic [18:0]offchip_sramif_external_addr,
    output logic [3:0] offchip_sramif_WE_out,
    output logic [3:0] offchip_sramif_nWE_out,
    inout wire [31:0] offchip_sramif_external_bidir,
    output logic offchip_sramif_nOE
);

localparam GPIO0_APB_IDX = 0;
localparam PWM0_APB_IDX  = 1;
localparam TIMER0_APB_IDX  = 2;
localparam POLI0_APB_IDX = 3;

localparam PWM_PIN_COUNT = NUM_PWM_PINS;
localparam TIMER_PIN_COUNT = NUM_TIMER_PINS;
localparam GPIO_PIN_COUNT = NUM_GPIO_PINS;


offchip_sram_if offchip_sramif(offchip_sramif_external_bidir);

assign offchip_sramif_external_addr = offchip_sramif.external_addr;

assign offchip_sramif_nWE_out = offchip_sramif.nWE;
assign offchip_sramif_WE_out = ~offchip_sramif.nWE;
assign offchip_sramif_nOE = offchip_sramif.nOE; 

/*
assign offchip_sramif_WE[7:0] = (!offchip_sramif.nWE[0]) ? '1 : '0;
assign offchip_sramif_WE[15:8] = (!offchip_sramif.nWE[1]) ? '1 : '0;
assign offchip_sramif_WE[23:16] = (!offchip_sramif.nWE[2]) ? '1 : '0;
assign offchip_sramif_WE[31:24] = (!offchip_sramif.nWE[3]) ? '1 : '0;
assign offchip_sramif_WE_sub[7:0] = (!offchip_sramif.nWE[0]) ? '0 : '1;
assign offchip_sramif_WE_sub[15:8] = (!offchip_sramif.nWE[1]) ? '0 : '1;
assign offchip_sramif_WE_sub[23:16] = (!offchip_sramif.nWE[2]) ? '0 : '1;
assign offchip_sramif_WE_sub[31:24] = (!offchip_sramif.nWE[3]) ? '0 : '1;
*/
    

//timer bidir signal split up
//input  logic [NUM_TIMER_PINS-1:0] timer_r_data_0,
//output logic [NUM_TIMER_PINS-1:0] timer_w_data_0,
//output logic [NUM_TIMER_PINS-1:0] timer_en_0,

//assign timer_sel_sub = ~timer_en_0;
//assign timer_sel_out = timer_en_0;



//logic clk;


//Internal Signals
logic rst_n;
logic select_slave;

//AHB
ahb_if muxed_ahb_if();

//GPIO
gpio_if #(GPIO_PIN_COUNT) gpioIf0(gpio_bidir_io);
apb_if gpio0apbIf();

//Polymorphic CRC
apb_if poli0If();

//PWM
apb_if pwm0If();

//Timer
apb_if apb_timer0If();
timer_if #(TIMER_PIN_COUNT) pin_timer0If(timer_bidir_0);

//Bridge Interconnection Interface
ahb2apb_if #(.NUM_SLAVES(4)) ahb2apbIf();


//m0_if m0If();

//SRAM Controller Interface
sram_controller_if #(.N_SRAM(1)) sramIf();
memory_blocks_if blkif();


//Hiererarchical Interface Definitions
ahb_if sramIf_ahbif();
ahb_if ahb2apbIf_ahbif();
apb_if ahb2apbIf_apbif();


//Core Instantiation
core_wrapper corewrap(.clk(clk),
                        .rst_n(rst_n),
                        .rx(rx),
                        .tx(tx),
                        .HREADY(muxed_ahb_if.HREADY),
                        .HRDATA(muxed_ahb_if.HRDATA),
                        .HRESP(muxed_ahb_if.HRESP),
                        //OUTPUTS
                        .HWRITE(muxed_ahb_if.HWRITE),
                        .HSIZE(muxed_ahb_if.HSIZE),
                        .HBURST(muxed_ahb_if.HBURST),
                        .HTRANS(muxed_ahb_if.HTRANS),
                        .HADDR(muxed_ahb_if.HADDR), 
                        .HWDATA(muxed_ahb_if.HWDATA),
                        .HPROT(muxed_ahb_if.HPROT)
);

//Bridge Interconnection Instantiation
ahb2apb #(.NUM_SLAVES(4)) ahb2apb(clk, rst_n, ahb2apbIf_ahbif, ahb2apbIf_apbif, ahb2apbIf);

//GPIO Instantiation
Gpio #(GPIO_PIN_COUNT) Gpio0(clk, rst_n, gpio0apbIf, gpioIf0);

//GPIO Interface Connections
assign gpio0apbIf.PWDATA = ahb2apbIf_apbif.PWDATA;
assign gpio0apbIf.PADDR = ahb2apbIf_apbif.PADDR;
assign gpio0apbIf.PWRITE = ahb2apbIf_apbif.PWRITE;
assign gpio0apbIf.PENABLE = ahb2apbIf_apbif.PENABLE;
assign gpio0apbIf.PSEL = ahb2apbIf.PSEL_slave[GPIO0_APB_IDX];
assign ahb2apbIf.PRData_slave[GPIO0_APB_IDX] = gpio0apbIf.PRDATA;

// Polymorphic CRC
POLI_top_level Poli0(
                      .CLK(clk),
                      .nRST(rst_n),
                      .PWDATA(poli0If.PWDATA),
                      .PADDR(poli0If.PADDR),
                      .PWRITE(poli0If.PWRITE),
                      .PSEL(poli0If.PSEL),
                      .PENABLE(poli0If.PENABLE),
                      .PRDATA(poli0If.PRDATA),
                      .PREADY()
                    );

// Polymorphic CRC Connections
assign poli0If.PWDATA = ahb2apbIf_apbif.PWDATA;
assign poli0If.PADDR = ahb2apbIf_apbif.PADDR;
assign poli0If.PWRITE = ahb2apbIf_apbif.PWRITE;
assign poli0If.PENABLE = ahb2apbIf_apbif.PENABLE;
assign poli0If.PSEL = ahb2apbIf.PSEL_slave[POLI0_APB_IDX];
assign ahb2apbIf.PRData_slave[POLI0_APB_IDX] = poli0If.PRDATA;

// PWM 
logic [PWM_PIN_COUNT:0] pwm_out;
pwm #(PWM_PIN_COUNT) Pwm0(
                      .clk(clk),
                      .n_rst(rst_n),
                      .paddr(pwm0If.PADDR),
                      .pwdata(pwm0If.PWDATA),
                      .psel(pwm0If.PSEL),
                      .penable(pwm0If.PENABLE),
                      .pwrite(pwm0If.PWRITE),
                      .prdata(pwm0If.PRDATA),
                      .pwm_out(pwm_out)
                    );

// PWM Connections
assign pwm0If.PWDATA = ahb2apbIf_apbif.PWDATA;
assign pwm0If.PADDR = ahb2apbIf_apbif.PADDR;
assign pwm0If.PWRITE = ahb2apbIf_apbif.PWRITE;
assign pwm0If.PENABLE = ahb2apbIf_apbif.PENABLE;
assign pwm0If.PSEL = ahb2apbIf.PSEL_slave[PWM0_APB_IDX];
assign ahb2apbIf.PRData_slave[PWM0_APB_IDX] = pwm0If.PRDATA;

// Timer
Timer #(TIMER_PIN_COUNT) Timer0(
                      .HCLK(clk),
                      .n_RST(rst_n),
                      .apbif(apb_timer0If),
                      .timerif(pin_timer0If)
                    );

// PWM Connections
assign apb_timer0If.PWDATA = ahb2apbIf_apbif.PWDATA;
assign apb_timer0If.PADDR = ahb2apbIf_apbif.PADDR;
assign apb_timer0If.PWRITE = ahb2apbIf_apbif.PWRITE;
assign apb_timer0If.PENABLE = ahb2apbIf_apbif.PENABLE;
assign apb_timer0If.PSEL = ahb2apbIf.PSEL_slave[PWM0_APB_IDX];
assign ahb2apbIf.PRData_slave[TIMER0_APB_IDX] = apb_timer0If.PRDATA;

sram_controller #(.SRAM_DEPTH('h7FFFF), .N_SRAM(1)) sram_controller(clk, rst_n, sramIf_ahbif, sramIf);

//onchip_sram #(.SRAM_ID(0)) onchip_sram1(clk,rst_n, sramIf);
memory_blocks mem_blocks(clk, rst_n, sramIf, blkif);
offchip_sram_controller offchip_sram(clk, rst_n, blkif, offchip_sramif);
SOC_ROM ROM(blkif);
SOC_RAM_wrapper RAM(clk, rst_n, blkif);


/* GPIO Signals */


assign gpio_sel_sub = ~gpioIf0.en_data;
assign gpio_sel_out = gpioIf0.en_data;


/* PWM Signals */
assign pwm_w_data_0 = pwm_out;

/* Timer Signals */
//assign timer_bidir_0 = pin_timer0If.timer_bidir;
assign timer_sel_sub = ~pin_timer0If.output_en;
assign timer_sel_out = pin_timer0If.output_en;

assign select_slave = muxed_ahb_if.HTRANS != 2'b00;

// 0 SRAM
// 1 GPIO
logic mux_sel;
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		mux_sel <= 0;
	end else begin
		if (muxed_ahb_if.HREADY) begin
			mux_sel <= muxed_ahb_if.HADDR[31];
		end
	end 
end 

always_comb begin
	if (muxed_ahb_if.HADDR[31]) begin
		sramIf_ahbif.HSEL = 0;
		ahb2apbIf_ahbif.HSEL = select_slave;
	end else begin
		sramIf_ahbif.HSEL = select_slave;
		ahb2apbIf_ahbif.HSEL = 0;
	end
end

/* AHB Mux */
always_comb
begin
	if(mux_sel)
		begin
			/* GPIO (an APB peripheral) is selected */
			muxed_ahb_if.HREADY = ahb2apbIf_ahbif.HREADYOUT;
			muxed_ahb_if.HRESP[0] = ahb2apbIf_ahbif.HRESP;
			muxed_ahb_if.HRDATA = ahb2apbIf_ahbif.HRDATA;

		end
	else
		begin
			/* SRAM (an AHB peripheral) is selected */
			muxed_ahb_if.HREADY = sramIf_ahbif.HREADYOUT;
			muxed_ahb_if.HRESP[0] = sramIf_ahbif.HRESP;
			muxed_ahb_if.HRDATA = sramIf_ahbif.HRDATA;
		end
end
assign muxed_ahb_if.HRESP[1] = 1'b0;

assign sramIf_ahbif.HTRANS = muxed_ahb_if.HTRANS; 
assign sramIf_ahbif.HWRITE = muxed_ahb_if.HWRITE;         
assign sramIf_ahbif.HADDR = muxed_ahb_if.HADDR;
assign sramIf_ahbif.HWDATA = muxed_ahb_if.HWDATA;
assign sramIf_ahbif.HSIZE = muxed_ahb_if.HSIZE;
assign sramIf_ahbif.HBURST = muxed_ahb_if.HBURST;
assign sramIf_ahbif.HPROT = muxed_ahb_if.HPROT;
assign sramIf_ahbif.HMASTLOCK = muxed_ahb_if.HMASTLOCK;
assign sramIf_ahbif.HREADY = muxed_ahb_if.HREADY;

assign ahb2apbIf_ahbif.HTRANS = muxed_ahb_if.HTRANS; 
assign ahb2apbIf_ahbif.HWRITE = muxed_ahb_if.HWRITE;         
assign ahb2apbIf_ahbif.HADDR = muxed_ahb_if.HADDR;
assign ahb2apbIf_ahbif.HWDATA = muxed_ahb_if.HWDATA;
assign ahb2apbIf_ahbif.HSIZE = muxed_ahb_if.HSIZE;
assign ahb2apbIf_ahbif.HBURST = muxed_ahb_if.HBURST;
assign ahb2apbIf_ahbif.HPROT = muxed_ahb_if.HPROT;
assign ahb2apbIf_ahbif.HMASTLOCK = muxed_ahb_if.HMASTLOCK;
assign ahb2apbIf_ahbif.HREADY = muxed_ahb_if.HREADY;

reset_synchronizer_n core_reset (clk, asyncrst_n, rst_n);

  //pad80_inDig_PD PAD_asyncrst_n(.BUF_OUT(asyncrst_n));
  //pad80_inDig_PD PAD_clk(.PAD_IN(clk_ext), .BUF_OUT(clk));
  //
  //pad80_inDig_PD PAD_rx(.BUF_OUT(rx));
  //pad80_ls_buf_out PAD_tx(.IN(tx));
  //
  //pad80_inDig_PD PAD_gpio_r_data_0_0(.BUF_OUT(gpio_r_data_0[0]));
  //pad80_inDig_PD PAD_gpio_r_data_0_1(.BUF_OUT(gpio_r_data_0[1]));
  //pad80_inDig_PD PAD_gpio_r_data_0_2(.BUF_OUT(gpio_r_data_0[2]));
  //pad80_inDig_PD PAD_gpio_r_data_0_3(.BUF_OUT(gpio_r_data_0[3]));
  //pad80_inDig_PD PAD_gpio_r_data_0_4(.BUF_OUT(gpio_r_data_0[4]));
  //pad80_inDig_PD PAD_gpio_r_data_0_5(.BUF_OUT(gpio_r_data_0[5]));
  //pad80_inDig_PD PAD_gpio_r_data_0_6(.BUF_OUT(gpio_r_data_0[6]));
  //pad80_inDig_PD PAD_gpio_r_data_0_7(.BUF_OUT(gpio_r_data_0[7]));
  //pad80_inDig_PD PAD_gpio_r_data_0_8(.BUF_OUT(gpio_r_data_0[8]));
  //pad80_inDig_PD PAD_gpio_r_data_0_9(.BUF_OUT(gpio_r_data_0[9]));
  //pad80_inDig_PD PAD_gpio_r_data_0_10(.BUF_OUT(gpio_r_data_0[10]));
  //pad80_inDig_PD PAD_gpio_r_data_0_11(.BUF_OUT(gpio_r_data_0[11]));
  //pad80_inDig_PD PAD_gpio_r_data_0_12(.BUF_OUT(gpio_r_data_0[12]));
  //pad80_inDig_PD PAD_gpio_r_data_0_13(.BUF_OUT(gpio_r_data_0[13]));
  //pad80_inDig_PD PAD_gpio_r_data_0_15(.BUF_OUT(gpio_r_data_0[15]));
  //
  //pad80_ls_buf_out PAD_gpio_w_data_0_0(.IN(gpio_w_data_0[0]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_1(.IN(gpio_w_data_0[1]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_2(.IN(gpio_w_data_0[2]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_3(.IN(gpio_w_data_0[3]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_4(.IN(gpio_w_data_0[4]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_5(.IN(gpio_w_data_0[5]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_6(.IN(gpio_w_data_0[6]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_7(.IN(gpio_w_data_0[7]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_8(.IN(gpio_w_data_0[8]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_9(.IN(gpio_w_data_0[9]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_10(.IN(gpio_w_data_0[10]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_11(.IN(gpio_w_data_0[11]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_12(.IN(gpio_w_data_0[12]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_13(.IN(gpio_w_data_0[13]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_14(.IN(gpio_w_data_0[14]));
  //pad80_ls_buf_out PAD_gpio_w_data_0_15(.IN(gpio_w_data_0[15]));
  //
  //
  //// Ring Oscillator
  //pad80_inDig_PD PAD_ring_osc_en(.BUF_OUT(ring_osc_en));
  //pad80_ls_buf_out PAD_ring_osc_out(.IN(ring_osc_out));
  //pad80_vdd PAD_VDD_RO(.VDD(vdd));
  //pad80_vdd PAD_VSS_RO(.VSS(gnd));
  //
  //// Blanks
  //pad80_no_ls_buf_out PAD_BLANK0_S();
  //pad80_no_ls_buf_out PAD_BLANK1_S();
  //pad80_no_ls_buf_out PAD_BLANK0_E();
  //pad80_no_ls_buf_out PAD_BLANK1_E();
  //pad80_no_ls_buf_out PAD_BLANK0_N();
  //pad80_no_ls_buf_out PAD_BLANK1_N();
  //pad80_no_ls_buf_out PAD_BLANK0_W();
  //pad80_no_ls_buf_out PAD_BLANK1_W();

  //// Power Pads
  //pad80_vdd PAD_VDD_N(.VDD(vdd));
  //pad80_vdd PAD_VDD_S(.VDD(vdd));
  //pad80_vdd PAD_VDD_E(.VDD(vdd));
  //pad80_vdd PAD_VDD_W(.VDD(vdd));
  //pad80_vss PAD_GND_N(.VSS(gnd));
  //pad80_vss PAD_GND_S(.VSS(gnd));
  //pad80_vss PAD_GND_E(.VSS(gnd));
  //pad80_vss PAD_GND_W(.VSS(gnd));
  //pad80_vddio PAD_VDDIO_N();
  //pad80_vddio PAD_VDDIO_S();
  //pad80_vddio PAD_VDDIO_E();
  //pad80_vddio PAD_VDDIO_W();
  //pad80_vssio PAD_VSSIO_N();
  //pad80_vssio PAD_VSSIO_S();
  //pad80_vssio PAD_VSSIO_E();
  //pad80_vssio PAD_VSSIO_W();
  //
  //// Corners
  //corner CORNER_SW();
  //corner CORNER_SE();
  //corner CORNER_NE();
  //corner CORNER_NW();

endmodule
