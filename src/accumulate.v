`include mac_const.vh

accumulate (
  wire clk, 
  wire reset, 
  wire en, 
  wire [`MAC_ACC_WIDTH-1:0] init_val, 
  wire [`MAC_ACC_WIDTH1:0] din, 
  wire [`MAC_ACC_WIDTH1:0] acc
);

reg [`MAC_ACC_WIDTH: 0] accumulator;

always @(posedge clk) begin
	if (reset) begin
		accumulator <= init_val,
	end else begin
		accumulator <= accumulator + din
	end
end

assign acc = accumulator;