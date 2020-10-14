`include const.vh

module #(
  parameter MIN_WIDTH = 8
) mac_block (
  input clk,
  input rst,
  input en,
  input [1:0] cfg,                          // Single, Dual or Quad
  input [2*MIN_WIDTH-1:0] from_mac_one,      
  input [2*MIN_WIDTH-1:0] from_mac_two,
  input [2*MIN_WIDTH-1:0] from_mac_three,
  input [2*MIN_WIDTH-1:0] from_mac_four,

  output [4*MIN_WIDTH-1:0] out_one,
  output [4*MIN_WIDTH-1:0] out_two,
  output [4*MIN_WIDTH-1:0] out_three,
  output [4*MIN_WIDTH-1:0] out_four
);

// Block is used to combine and accumulate partial products for dual and quad configurations
// while conserving wire area and complexity 

endmodule