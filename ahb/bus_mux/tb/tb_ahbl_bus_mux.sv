`include "ahbl_defines.vh"

module tb_foo();

logic clk;

initial begin
    clk = 0;
end

always begin
    #35 clk = ~clk;
end

endmodule

