// $Id: $
// File name:   pwm.sv
// Created:     4/2/15
// Author:      Manik Singhal, John Skubic 
// Version:     1.0  Initial Design Entry
// Description: flexible pwm controled over an apb bus

/*
	PWM PUPPY!

  ZZZ$$$$$$$$$$7$$777$$$$$$$$$$$$$$$$$$$$$ZZZZZZOOOOOOO88   
  Z$Z$$$$$$$$777777777777777777$777$$$$$$$$ZZZZZZOOOOOOO8   
  Z$$$$$$$$777777777777777.........,=$$$$$$$ZZZZZZZZOOOOO   
  $$$$$$$$77777777777+...        .    .~$I$$$ZZZZZZZOOOOO   
 .Z$$$$$$$$77777I?+...  .. ...  .. . ..  ...=$ZZZZZZOOOOO.  
  Z$$$$$$$77777...  ....................,.. ..~$ZZZZZOOOO   
  Z$$$$$$$77=. ... =?,.:.,,,,,,.:,::.....7,... .?ZZZZOOOO.  
  $$$$$$$77. .....~$~,,,,,::~,,::~~:~,.,,,I,..,. .7ZZOOOO   
  $$$$$77 ..,,..,,?8=::::~~=+=~:~=+?+~~:::8=.,.....IZZOOO.  
 .$$$$$7...,::::,,I$=::=+~++=+=++++++~=~~=$?~,~~,~,?ZZOOO.  
 .$$$$$7?~?+~:?+,+7I=~==~~+=+??+?I+?II+:.:?$=,=+?+:7ZZZOO.  
  $$$$$$7~+?=?=,~+O7+~::=I?I?I????I$Z88??=+8+,:I?I+$ZZZZZ.  
 .$$$$$$$?=?+?=:++OI~~=+OOOZ7I?==+?7MMMMD?I8$~,+I+ZZZZZZZ.  
 .$$$$$$$77=??+~~$Z$I?ZMMMDD7+=~,~+?78DOI?+Z$?,~I$$ZZZZZZ.  
 .$777777777I+=~?$$7?++IZO$?=:......,~??++I$?~I.$$$$$ZZZZ.  
  7777777777I?~I?I7$?+??+?+=,........,:++=II=~77$$$$$$ZZZ.  
 .777IIIIIIIII+.=??II=+=I=~,,,,~+?=::.,+==I+:+777$$$$$$$$.  
  IIIIIIIIIII...~+??I=~+++~:,~Z$ZO$?I:,,==?::?$77$$$$$$$$.  
  IIIIIIIIII.. .,=?II++==~:+?=8MMMMD$I:,:~===II77$$$$$$$$.  
 .IIIIIIII+. ..,:~+?I??+==:+?IOMMMMMOI+,~?:??II77$$$$7$$7.  
  777IIIII....,:~+?+II7I?7=+7$ONMMMN87+:=.,+I77$$$$$77777.  
 .77777II+...,,:~=+?I?$7$?$?$O8MMMMN8$++,..:I7$$$$$$$7777.  
 .77III7I. ..::~~+I$777$ZZ$777$ZZZZ7+7?+,..=I$ZZZ$$$$$$$$.  
 .77I7II:...,~~=+~+?II7Z$ZZOZZZOZZZ$7??+=,.=7$ZZZ$$$ZZZZ$.  
  IIIII=...,::~=++???IIZ$ZZZZZ$ZZZI77?+=~:,+$$ZZZZ$ZZZZZZ   
  7III?....:::~=+??III7$$OZ8ZOOZZZ$7I??+=,,$$$$$ZZZZOZZZZ   
 .777I..,.,:~==+??II$$I$$$$Z$$$ZZ$$7$I??=,.I$$$$ZZZOZZZZO   
  I77~..,,~~==I7$I?I$7$$Z$7$$$ZZ$$$7$7I?=:.I7$$ZZZZZZZZZO.  
  77?.,,:~~=+???II7?7$Z$Z$Z$ZZ$$$$$$77I?=~,I7$ZOZZZZZZZOO. 

*/


module pwm 
	#(parameter NUM_CHANNELS = 2)
	(
	input logic [31:0] paddr, pwdata, 
	input logic psel, penable, pwrite,
	output logic [31:0] prdata,
	input logic clk, n_rst, 
	output logic [NUM_CHANNELS - 1 : 0] pwm_out
	);

	localparam NUM_REG_PER_CHAN = 3;
	localparam NUM_REGS = NUM_REG_PER_CHAN * NUM_CHANNELS;

	localparam PERIOD_IND = 0;
	localparam DUTY_IND = 1;
	localparam COUNT_IND = 2;

	logic [NUM_REGS-1:0] wen;
	logic [NUM_REGS-1:0] ren;
	logic [31:0] w_data;

	genvar i;

	//apb slave
	APB_SlaveInterface_general #(.NUM_REGS(NUM_REGS)) apbs (
		.clk(clk), 
		.n_rst(n_rst), 
		.PADDR(paddr), 
		.PWDATA(pwdata), 
		.PENABLE(penable), 
		.PWRITE(pwrite), 
		.PRDATA(prdata), 
		.PSEL(psel), 
		.read_data(0), //write only module

		.w_enable(wen), 
		.r_enable(ren), 
		.w_data(w_data)
	);

	generate
		for(i=0;i < NUM_CHANNELS; i++) begin
			pwmchannel channel (
				.clk(clk),
				.n_rst(n_rst),
				.pwm_out(pwm_out[i]),
				.cont_wen(wen[(i * NUM_REG_PER_CHAN) + COUNT_IND]),
				.period_wen(wen[(i * NUM_REG_PER_CHAN) + PERIOD_IND]), 
				.duty_wen(wen[(i * NUM_REG_PER_CHAN) + DUTY_IND]), 
				.duty_in(w_data),
				.period_in(w_data),
				.control_in(w_data[2:0])
			);
		end 
	endgenerate


endmodule
