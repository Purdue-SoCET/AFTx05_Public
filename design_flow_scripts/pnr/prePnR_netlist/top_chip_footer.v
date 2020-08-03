module POLI_standalone(output_select, A, B, orient, X);
  input output_select, A, B, orient;
  output X;
  wire output_select, A, B, orient;
  wire X;
  wire NAND_NOR_X, XOR_BUF_X;
  dig_poly_NAND_NOR2_x1 D0(.A (A), .B (B), .orient (orient), .X
       (NAND_NOR_X));
  dig_poly_XOR_BUF2_x1 D1(.A (A), .B (B), .orient (orient), .X
       (XOR_BUF_X));

  mux2_1x A3 (.X(X), .D0(NAND_NOR_X), .D1(XOR_BUF_X), .S(output_select));


endmodule


module top_chip( mem_data_pad, gpio_pad, timer_pad, ring_osc_out_pad, 
                 pwm_w_data_0_pad, poli_X_pad, offchip_sramif_nWE_pad, offchip_sramif_nOE_pad, 
                 offchip_sramif_external_addr_pad, tx_pad, scan_out_1_pad, poli_output_select_pad,
                 poli_A_pad, poli_B_pad, poli_orient_pad, test_sig_pad, scan_en_pad, scan_in_1_pad, 
                 clk_pad, asyncrst_n_pad, rx_pad, \vdd! , \vss! , VDDIO, VSSIO

);
  inout \vdd! , \vss! ;
  inout VDDIO, VSSIO;
  inout [31:0] mem_data_pad;
  inout [7:0] gpio_pad;
  inout timer_pad;
  output ring_osc_out_pad;
  output pwm_w_data_0_pad;
  output poli_X_pad;
  output [3:0] offchip_sramif_nWE_pad;
  output offchip_sramif_nOE_pad;
  output [18:0] offchip_sramif_external_addr_pad;
  output tx_pad;
  output scan_out_1_pad;
  input poli_output_select_pad;
  input poli_A_pad;
  input poli_B_pad;
  input poli_orient_pad;
  input test_sig_pad;
  input scan_en_pad;
  input scan_in_1_pad;
  input clk_pad;
  input asyncrst_n_pad;
  input rx_pad; //17


  wire [31:0] mem_data_pad;
  wire [7:0] gpio_pad;
  wire timer_pad;
  wire ring_osc_out_pad;
  wire pwm_w_data_0_pad;
  wire poli_X_pad;
  wire [3:0] offchip_sramif_nWE_pad;
  wire offchip_sramif_nOE_pad;
  wire [18:0] offchip_sramif_external_addr_pad;
  wire tx_pad;
  wire scan_out_1_pad;
  wire poli_output_select_pad;
  wire poli_A_pad;
  wire poli_B_pad;
  wire poli_orient_pad;
  wire test_sig_pad;
  wire scan_en_pad;
  wire scan_in_1_pad;
  wire clk_pad;
  wire asyncrst_n_pad;
  wire rx_pad;
  



  wire clk, asyncrst_n, rx, scan_en, test_sig, scan_in_1;
  wire tx, offchip_sramif_nOE, scan_out_1;
  wire [7:0] gpio_sel_out, gpio_sel_sub;
  wire [0:0] pwm_w_data_0, timer_sel_out, timer_sel_sub;
  wire [18:0] offchip_sramif_external_addr;
  wire [3:0] offchip_sramif_WE_out, offchip_sramif_nWE_out;
  wire [7:0] gpio_bidir_io;
  wire [0:0] timer_bidir_0;
  wire [31:0] offchip_sramif_external_bidir;

  //wire [3:0] fixnWE;
  //wire [3:0] fixWE;
  //wire [3:0] midnWE;
  //wire [3:0] midWE;


  top_level_bASIC bASIC(.clk(clk), .asyncrst_n(asyncrst_n), .rx(rx), .tx(tx), .gpio_bidir_io(gpio_bidir_io),
     .gpio_sel_out(gpio_sel_out), .gpio_sel_sub(gpio_sel_sub), .pwm_w_data_0(pwm_w_data_0), .timer_bidir_0(timer_bidir_0),
     .timer_sel_out(timer_sel_out), .timer_sel_sub(timer_sel_sub),
     .offchip_sramif_external_addr(offchip_sramif_external_addr), .offchip_sramif_WE_out(offchip_sramif_WE_out),
     .offchip_sramif_nWE_out(offchip_sramif_nWE_out), .offchip_sramif_external_bidir(offchip_sramif_external_bidir),
     .offchip_sramif_nOE(offchip_sramif_nOE), .scan_en(scan_en), .test_sig(test_sig), .scan_in_1(scan_in_1), .scan_out_1(scan_out_1));


  wire ring_en;
  wire ring_osc_out;
  tiehi_1x tie_hi_cell20000(.X (ring_en));

  //EMT
  //EMT_1 emt1(.A());
  //EMT_2 emt2();  
  //EMT_3 emt3();  
  //EMT_4 emt4();  
  //EMT_5 emt5();  
  //EMT_6 emt6();  
 


  //RO
  ring_161x ring_oscillator(.EN(ring_en), .OUT(ring_osc_out));
  pad80_ls_buf_out PAD_ring_osc_out(.IN(ring_osc_out), .PAD_OUT(ring_osc_out_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  //nWE and WE fixes
  //buf_32x buffix01(.A (offchip_sramif_nWE_out[0]), .X (midnWE[0]));
  //buf_32x buffix02(.A (offchip_sramif_nWE_out[1]), .X (midnWE[1]));
  //buf_32x buffix03(.A (offchip_sramif_nWE_out[2]), .X (midnWE[2]));
  //buf_32x buffix04(.A (offchip_sramif_nWE_out[3]), .X (midnWE[3]));
 
  //buf_32x buffix05(.A (offchip_sramif_WE_out[0]), .X (midWE[0])); 
  //buf_32x buffix06(.A (offchip_sramif_WE_out[1]), .X (midWE[1]));
  //buf_32x buffix07(.A (offchip_sramif_WE_out[2]), .X (midWE[2]));
  //buf_32x buffix08(.A (offchip_sramif_WE_out[3]), .X (midWE[3]));

  //and2_4x andfix01(.A (midnWE[0]), .B (offchip_sramif_nWE_out[0]), .X (fixnWE[0]));
  //and2_4x andfix02(.A (midnWE[1]), .B (offchip_sramif_nWE_out[1]), .X (fixnWE[1]));
  //and2_4x andfix03(.A (midnWE[2]), .B (offchip_sramif_nWE_out[2]), .X (fixnWE[2]));
  //and2_4x andfix04(.A (midnWE[3]), .B (offchip_sramif_nWE_out[3]), .X (fixnWE[3]));

  //and2_4x andfix05(.A (midWE[0]), .B (offchip_sramif_WE_out[0]), .X (fixWE[0]));
  //and2_4x andfix06(.A (midWE[0]), .B (offchip_sramif_WE_out[0]), .X (fixWE[0]));
  //and2_4x andfix07(.A (midWE[0]), .B (offchip_sramif_WE_out[0]), .X (fixWE[0]));
  //and2_4x andfix08(.A (midWE[0]), .B (offchip_sramif_WE_out[0]), .X (fixWE[0]));


  //POLI_standalone
  
  wire poli_output_select;
  wire poli_A;
  wire poli_B;
  wire poli_X;
  wire poli_orient;
  POLI_standalone poli_standalone(.output_select(poli_output_select), .A(poli_A), .B(poli_B), .orient(poli_orient), .X(poli_X));


  pad80_ls_buf_out PAD_poli_X(.IN(poli_X), .PAD_OUT(poli_X_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_poli_select(.BUF_OUT(poli_output_select), .PAD_IN(poli_output_select_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_poli_A(.BUF_OUT(poli_A), .PAD_IN(poli_A_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_poli_B(.BUF_OUT(poli_B), .PAD_IN(poli_B_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_poli_orient(.BUF_OUT(poli_orient), .PAD_IN(poli_orient_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  //PWM
  pad80_ls_buf_out PAD_pwm_out_0(.IN(pwm_w_data_0), .PAD_OUT(pwm_w_data_0_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  
  //Timer
  pad80_inDig_buf_out_cdm PAD_timer_out_0(.SEL_OUT(timer_sel_out), .SEL_SUBh(timer_sel_sub), .CORE(timer_bidir_0), .PAD(timer_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));


  //GPIO R/W
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_7(.SEL_OUT(gpio_sel_out[7]), .SEL_SUBh(gpio_sel_sub[7]), .CORE(gpio_bidir_io[7]), .PAD(gpio_pad[7]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_6(.SEL_OUT(gpio_sel_out[6]), .SEL_SUBh(gpio_sel_sub[6]), .CORE(gpio_bidir_io[6]), .PAD(gpio_pad[6]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_5(.SEL_OUT(gpio_sel_out[5]), .SEL_SUBh(gpio_sel_sub[5]), .CORE(gpio_bidir_io[5]), .PAD(gpio_pad[5]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_4(.SEL_OUT(gpio_sel_out[4]), .SEL_SUBh(gpio_sel_sub[4]), .CORE(gpio_bidir_io[4]), .PAD(gpio_pad[4]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_3(.SEL_OUT(gpio_sel_out[3]), .SEL_SUBh(gpio_sel_sub[3]), .CORE(gpio_bidir_io[3]), .PAD(gpio_pad[3]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_2(.SEL_OUT(gpio_sel_out[2]), .SEL_SUBh(gpio_sel_sub[2]), .CORE(gpio_bidir_io[2]), .PAD(gpio_pad[2]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_1(.SEL_OUT(gpio_sel_out[1]), .SEL_SUBh(gpio_sel_sub[1]), .CORE(gpio_bidir_io[1]), .PAD(gpio_pad[1]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_gpio_bidir_0(.SEL_OUT(gpio_sel_out[0]), .SEL_SUBh(gpio_sel_sub[0]), .CORE(gpio_bidir_io[0]), .PAD(gpio_pad[0]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  //Scan Chain
  pad80_inDig_PD PAD_testmode(.BUF_OUT(test_sig), .PAD_IN(test_sig_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_scan_en(.BUF_OUT(scan_en), .PAD_IN(scan_en_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_scan_in(.BUF_OUT(scan_in_1), .PAD_IN(scan_in_1_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_scan_out(.IN(scan_out_1), .PAD_OUT(scan_out_1_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));



  // Off-chip Memory
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_31(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[31]), .PAD(mem_data_pad[31]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_30(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[30]), .PAD(mem_data_pad[30]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_29(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[29]), .PAD(mem_data_pad[29]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_28(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[28]), .PAD(mem_data_pad[28]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_27(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[27]), .PAD(mem_data_pad[27]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_26(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[26]), .PAD(mem_data_pad[26]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_25(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[25]), .PAD(mem_data_pad[25]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_24(.SEL_OUT(offchip_sramif_WE_out[3]), .SEL_SUBh(offchip_sramif_nWE_out[3]), .CORE(offchip_sramif_external_bidir[24]), .PAD(mem_data_pad[24]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_23(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[23]), .PAD(mem_data_pad[23]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_22(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[22]), .PAD(mem_data_pad[22]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_21(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[21]), .PAD(mem_data_pad[21]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_20(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[20]), .PAD(mem_data_pad[20]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_19(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[19]), .PAD(mem_data_pad[19]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_18(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[18]), .PAD(mem_data_pad[18]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_17(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[17]), .PAD(mem_data_pad[17]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_16(.SEL_OUT(offchip_sramif_WE_out[2]), .SEL_SUBh(offchip_sramif_nWE_out[2]), .CORE(offchip_sramif_external_bidir[16]), .PAD(mem_data_pad[16]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_15(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[15]), .PAD(mem_data_pad[15]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_14(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[14]), .PAD(mem_data_pad[14]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_13(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[13]), .PAD(mem_data_pad[13]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_12(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[12]), .PAD(mem_data_pad[12]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_11(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[11]), .PAD(mem_data_pad[11]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_10(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[10]), .PAD(mem_data_pad[10]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_9(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[9]), .PAD(mem_data_pad[9]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_8(.SEL_OUT(offchip_sramif_WE_out[1]), .SEL_SUBh(offchip_sramif_nWE_out[1]), .CORE(offchip_sramif_external_bidir[8]), .PAD(mem_data_pad[8]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_7(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[7]), .PAD(mem_data_pad[7]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_6(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[6]), .PAD(mem_data_pad[6]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_5(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[5]), .PAD(mem_data_pad[5]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_4(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[4]), .PAD(mem_data_pad[4]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_3(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[3]), .PAD(mem_data_pad[3]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_2(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[2]), .PAD(mem_data_pad[2]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_1(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[1]), .PAD(mem_data_pad[1]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_buf_out_cdm PAD_mem_data_bidir_0(.SEL_OUT(offchip_sramif_WE_out[0]), .SEL_SUBh(offchip_sramif_nWE_out[0]), .CORE(offchip_sramif_external_bidir[0]), .PAD(mem_data_pad[0]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  pad80_ls_buf_out PAD_nOE(.IN(offchip_sramif_nOE), .PAD_OUT(offchip_sramif_nOE_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));


  //pad80_ls_buf_out PAD_nCE(.IN(offchip_sramif_nCE));
  pad80_ls_buf_out PAD_BYTE_nWE_3(.IN(offchip_sramif_nWE_out[3]), .PAD_OUT(offchip_sramif_nWE_pad[3]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_BYTE_nWE_2(.IN(offchip_sramif_nWE_out[2]), .PAD_OUT(offchip_sramif_nWE_pad[2]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_BYTE_nWE_1(.IN(offchip_sramif_nWE_out[1]), .PAD_OUT(offchip_sramif_nWE_pad[1]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_BYTE_nWE_0(.IN(offchip_sramif_nWE_out[0]), .PAD_OUT(offchip_sramif_nWE_pad[0]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  pad80_ls_buf_out PAD_mem_addr_18(.IN(offchip_sramif_external_addr[18]), .PAD_OUT(offchip_sramif_external_addr_pad[18]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_17(.IN(offchip_sramif_external_addr[17]), .PAD_OUT(offchip_sramif_external_addr_pad[17]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_16(.IN(offchip_sramif_external_addr[16]), .PAD_OUT(offchip_sramif_external_addr_pad[16]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_15(.IN(offchip_sramif_external_addr[15]), .PAD_OUT(offchip_sramif_external_addr_pad[15]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_14(.IN(offchip_sramif_external_addr[14]), .PAD_OUT(offchip_sramif_external_addr_pad[14]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_13(.IN(offchip_sramif_external_addr[13]), .PAD_OUT(offchip_sramif_external_addr_pad[13]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_12(.IN(offchip_sramif_external_addr[12]), .PAD_OUT(offchip_sramif_external_addr_pad[12]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_11(.IN(offchip_sramif_external_addr[11]), .PAD_OUT(offchip_sramif_external_addr_pad[11]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_10(.IN(offchip_sramif_external_addr[10]), .PAD_OUT(offchip_sramif_external_addr_pad[10]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_9(.IN(offchip_sramif_external_addr[9]), .PAD_OUT(offchip_sramif_external_addr_pad[9]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_8(.IN(offchip_sramif_external_addr[8]), .PAD_OUT(offchip_sramif_external_addr_pad[8]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_7(.IN(offchip_sramif_external_addr[7]), .PAD_OUT(offchip_sramif_external_addr_pad[7]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_6(.IN(offchip_sramif_external_addr[6]), .PAD_OUT(offchip_sramif_external_addr_pad[6]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_5(.IN(offchip_sramif_external_addr[5]), .PAD_OUT(offchip_sramif_external_addr_pad[5]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_4(.IN(offchip_sramif_external_addr[4]), .PAD_OUT(offchip_sramif_external_addr_pad[4]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_3(.IN(offchip_sramif_external_addr[3]), .PAD_OUT(offchip_sramif_external_addr_pad[3]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_2(.IN(offchip_sramif_external_addr[2]), .PAD_OUT(offchip_sramif_external_addr_pad[2]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_1(.IN(offchip_sramif_external_addr[1]), .PAD_OUT(offchip_sramif_external_addr_pad[1]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_mem_addr_0(.IN(offchip_sramif_external_addr[0]), .PAD_OUT(offchip_sramif_external_addr_pad[0]), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));




  // Power Pads
  pad80_vdd PAD_VDD_N(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vdd PAD_VDD_S(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vdd PAD_VDD_E(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vdd PAD_VDD_W(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vss PAD_GND_N(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vss PAD_GND_S(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vss PAD_GND_E(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vss PAD_GND_W(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vddio PAD_VDDIO_N(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vddio PAD_VDDIO_S(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vddio PAD_VDDIO_E(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vddio PAD_VDDIO_W(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vssio PAD_VSSIO_N(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vssio PAD_VSSIO_S(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vssio PAD_VSSIO_E(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_vssio PAD_VSSIO_W(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  
  // Corners
  corner CORNER_SW(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  corner CORNER_SE(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  corner CORNER_NE(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  corner CORNER_NW(.VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));

  //CLK, RST, UART
  pad80_inDig_PD PAD_clk(.BUF_OUT(clk), .PAD_IN(clk_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_asyncrst_n(.BUF_OUT(asyncrst_n), .PAD_IN(asyncrst_n_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_ls_buf_out PAD_tx(.IN(tx), .PAD_OUT(tx_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));
  pad80_inDig_PD PAD_rx(.BUF_OUT(rx), .PAD_IN(rx_pad), .VDD(\vdd! ), .VSS(\vss! ), .VDDIO(VDDIO), .VSSIO(VSSIO));


endmodule
