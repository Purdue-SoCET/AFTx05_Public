/*
 John Martinuk
 jmartinu@purdue.edu
 
 Isaiah Grace
 igrace@purdue.edu
 */
`include "crc_generator_if.vh"

module poly_crc32 (
	      input CLK, nRST, 
	      crc_generator_if.crc_generator crc
	      );
   
   logic [5:0] 	    count;
   logic [5:0] 	    n_count;
   logic [31:0]     n_crc_data_out;
   logic [31:0]     curr_data;
   logic [31:0]     n_curr_data;
   logic 	    crc_enable;
   logic [31:0]     curr_orient;
   
   assign crc_enable = (crc.crc_start || (count != 6'd0));
   assign crc.crc_ready = (count == '0) ? 1'b1 : 1'b0;

   // Counter
   always_ff @(posedge CLK, negedge nRST)
     begin
	if(!nRST)
	  begin
	     count <= '0;
	  end
	else
	  begin
	     count <= n_count;
	  end
     end // always_ff @ (posedge CLK, negedge nRST)

   // next count logic
   always_comb
     begin
	n_count = count;
	if(count != 6'd0 && count != 6'd32)
	  begin
	     n_count = count + 1;
	  end
	else if(crc.crc_start && count == 6'd0)
	  begin
	     n_count = 6'd1;
	  end
	else if(count == 6'd32)
	  begin
	     n_count = '0;
	  end
     end // always_comb


   //Data and CRC data
   always_ff @(posedge CLK, negedge nRST)
     begin
	if(!nRST)
	  begin
	     crc.crc_data_out <= '0;
             curr_data <= '0;
	  end
	else
	  begin
             crc.crc_data_out <= crc.crc_data_out;
             curr_data <= curr_data;
             curr_orient <= (count == '0) ? crc.crc_orient : curr_orient;
	     
             if (crc_enable) begin
	        crc.crc_data_out <= n_crc_data_out;
		curr_data <= n_curr_data;
             end
             else if (crc.crc_reset && crc.crc_ready) begin
		crc.crc_data_out <= crc.crc_data_in;
		curr_data <= crc.crc_data_in;
             end
	  end
     end // always_ff @ (posedge CLK, negedge nRST)
   
   
   //next data logic
   //assign n_curr_data = (crc.crc_ready) ? crc.crc_data_in : {curr_data[30:0], 1'b0};
   //assign n_curr_data = (crc.crc_ready) ? crc.crc_data_in : {curr_data[30:0], 1'b0};
   
   always_comb
     begin
	n_curr_data = {curr_data[30:0], 1'b0};
	if (count == '0) begin
	   n_curr_data = crc.crc_data_in;
	end
     end
      
   
   sim_wrapper_XOR_BUF A0 (
			   .A(curr_data[31]),
			   .B(crc.crc_data_out[31]),
			   .orient(curr_orient[0]),
			   .X(n_crc_data_out[0])
			   );
   
   genvar i;
   generate
      for (i=1; i<=31; i=i+1) 
	begin: XOR_BUF
	   sim_wrapper_XOR_BUF A (
				  .A(crc.crc_data_out[i - 1]),
				  .B(crc.crc_data_out[31]),
				  .orient(curr_orient[i]),
				  .X(n_crc_data_out[i])
				  );
	end
   endgenerate
   
endmodule // crc32
