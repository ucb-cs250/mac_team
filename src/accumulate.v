`include "mac_const.vh"

module accumulate (
  input wire clk, 
  input wire reset, 
  input wire en, 
  input wire [`MAC_ACC_WIDTH-1:0] init_val, 
  input wire [`MAC_ACC_WIDTH-1:0] din, 
  output wire [`MAC_ACC_WIDTH-1:0] acc
);

reg [`MAC_ACC_WIDTH-1: 0] accumulator;

always @(posedge clk) begin
	if (reset) begin
		accumulator <= init_val;
	end else begin
		accumulator <= accumulator + din;
	end
end

assign acc = accumulator;

endmodule
