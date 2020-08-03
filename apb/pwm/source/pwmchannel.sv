// $Id: $
// File name:   pwmchannel.sv
// Created:     4/16/15
// Author:      Manik Singhal, John Skubic 
// Version:     1.01  Slightly Revised Initial Design Entry
// Description: pwm channel source code

/*
PWM channel pup

*/

module pwmchannel(
	
	input logic [2:0] control_in,//0 -> enable, 1-> polarity, 2-> alignment(0- left, 1- center)
	input logic [31:0] duty_in, period_in, 
	input logic cont_wen, duty_wen, period_wen, // if any control signals are being written in 
	input logic clk, n_rst,
	output logic pwm_out
	);

	localparam PERIOD_IND = 0;
	localparam DUTY_IND = 1;

	logic [1:0][31:0] data_in; //0-> period, 1-> duty
	logic [1:0] data_wen; // if duty and period are being written in 

	logic [1:0][31:0] data_buff; //0th array is period, 1st array is duty
	logic [1:0][31:0] data_double_buff; //0th array is period, 1st array is duty
	logic [1: 0] data_mod;//if the period and duty inputs have been modified

	logic [31:0] f_count;//count value

	logic [31:0] period, duty;
	logic [31:0] half_period, half_duty;

	logic [2:0] control_buff;//pwm_enable, polarity, alignment
	logic [2:0] control_mod;//pwm_enable, polarity, alignment//kinda for debigging purposes

	logic pwm_enable, polarity, alignment, pwm_low, high_la, high_ca;
	logic pwm_next;
	logic rollover_flag;

	//flex counter
	flex_counter #(.NUM_CNT_BITS(32)) fcnt(
		.clk(clk),
		.n_rst(n_rst),
		.clear(1'b0), 
		.count_enable(pwm_enable), 
		.rollover_val(period), 
		.count_out(f_count), 
		.rollover_flag(rollover_flag)
		);

	genvar i;

	assign data_in[PERIOD_IND] = period_in;
	assign data_in[DUTY_IND] = duty_in;

	assign data_wen[PERIOD_IND] = period_wen;
	assign data_wen[DUTY_IND] = duty_wen;

	assign duty = data_double_buff[1];
	assign period = data_double_buff[0];
	assign half_period = period >> 1;
	assign half_duty = duty >> 1;

	assign pwm_enable = control_buff[0];
	assign polarity = control_buff[1];
	assign alignment = control_buff[2];
	// Combinational logic for toggling for left aligned pwm
	// high_la will be high until one cycle before duty is reached, this allows for pwm_next to go low/high
	// as appropriate on the next rising clock edge
	assign high_la = f_count < duty;
	//combinational logic for toggling for center aligned pwm
	assign high_ca = ( f_count < (half_period + half_duty + duty[0])) &&
					 ( f_count >= (half_period - half_duty));

	//logic for the control bits (alignment, enable, polarity)
	//control logic doesn't need double buffering
	always_ff @ (posedge clk, negedge n_rst) begin
		if (~n_rst)
		begin
			control_buff <= '0;
			control_mod <= '0;
		end
		else if(cont_wen)
		begin
			control_mod <= 1'b1;
			control_buff <= control_in;
		end
		else
		begin
			control_buff <= control_buff;
		end
	end

	//The data buffers (pwm period and duty cycle) are double buffered

	//logic for data bits 
	generate
		for (genvar i = 0; i < 2; i++) begin
			always_ff @(posedge clk, negedge n_rst)
			begin
				if (~n_rst)
				begin
					data_buff[i] <= '0;
					data_mod[i] <= '0;
				end
				else if(data_wen[i])
				begin
					data_mod[i] <= 1'b1;
					data_buff[i] <= data_in[i];
				end
				else if(rollover_flag) 
				begin
					data_mod[i] <= '0;
					data_buff[i] <= data_buff[i];
				end
			end

			always_ff @(posedge clk, negedge n_rst)
			begin
				if(~n_rst)
					data_double_buff[i] <= '0;
				else if (data_mod[i] & rollover_flag)
					data_double_buff[i] <= data_buff[i];
			end
		end
	endgenerate

	//pwm output

	always_ff @(posedge clk, negedge n_rst)
	begin
		if (~n_rst)
			pwm_out <= '0;
		else
			pwm_out <= pwm_next;
	end

	//choosing the pwm_next
	always_comb
	begin
		if (pwm_enable)
		begin
			if (alignment)//center aligned
			begin
				pwm_next = high_ca ^ polarity;
			end
			else if (~alignment)//left aligned
			begin
				pwm_next = high_la ^ polarity;
			end
		end
		else
			pwm_next = '0;
	end

endmodule


	
			

