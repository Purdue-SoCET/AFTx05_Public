`timescale 1ns / 10ps

module tb_pwmchannel();

	localparam clkprd = 2.5;
	localparam delay = 1;

	localparam PERIOD_IND = 0;
	localparam DUTY_IND = 1;

	reg tb_clk, tb_n_rst;
	reg tb_pwm_out;

	reg tb_cont_wen;
	reg [2:0] tb_control_in;

	reg [1:0] tb_data_wen;
	reg [1:0][31:0] tb_data_in;

	pwmchannel DUT(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.pwm_out(tb_pwm_out), 
		.cont_wen(tb_cont_wen), 
		.duty_wen(tb_data_wen[DUTY_IND]), 
		.period_wen(tb_data_wen[PERIOD_IND]),
		.control_in(tb_control_in), 
		.duty_in(tb_data_in[DUTY_IND]),
		.period_in(tb_data_in[PERIOD_IND])
		);


	always
	begin
		tb_clk = 1'b0;
		#(clkprd/2.0);
		tb_clk = 1'b1;
		#(clkprd/2.0);
	end

	//pwm control {alignment, polarity, enable}

	initial
	begin
		tb_n_rst = 0;
		tb_cont_wen = 0;
		tb_data_wen = 0;
		@(posedge tb_clk);
		tb_n_rst = 1;
		@(posedge tb_clk);
		#(delay);
		tb_cont_wen = 1;
		tb_control_in = 3'b001;
		tb_data_wen = 2'b11;
		tb_data_in[0] = 32'h0000000F;
		tb_data_in[1] = 32'h0000000A;
		$info("Period 0xF, Duty 0xA, alignment 0, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 15 * 4);

		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000008;
		$info("Period 0x10, Duty 0x08, alignment 0, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);

		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000000;
		$info("Period 0x10, Duty 0x0, alignment 0, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);

		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000010;
		$info("Peritb_clkod 0x10, Duty 0x10, alignment 0, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);


		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_cont_wen = 1;
		tb_control_in = 3'b101;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000008;
		$info("Period 0x10, Duty 0x08, alignment 1, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);

		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_cont_wen = 1;
		tb_control_in = 3'b001;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000008;
		$info("Period 0x10, Duty 0x08, alignment 0, polarity 0, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);

		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b11;
		tb_cont_wen = 1;
		tb_control_in = 3'b011;
		tb_data_in[0] = 32'h00000010;
		tb_data_in[1] = 32'h00000008;
		$info("Period 0x10, Duty 0x08, alignment 0, polarity 1, enable 1, start at %d", $time);
		@(posedge tb_clk);
		#(delay);
		tb_data_wen = 2'b00;
		tb_cont_wen = 0;
		#(clkprd * 16 * 4);;

	end
endmodule



