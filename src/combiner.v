`include const.vh

module #(
  parameter MIN_WIDTH = 8
) mac_block (
  input clk,
  input rst,
  input en,
  input [1:0] cfg,                          // Single, Dual or Quad
  input [2*MIN_WIDTH-1:0] partial_one,      
  input [2*MIN_WIDTH-1:0] partial_two,
  input [2*MIN_WIDTH-1:0] partial_three,
  input [2*MIN_WIDTH-1:0] partial_four,

  output [4*MIN_WIDTH-1:0] out_one,         // Output only used for dual or quad configuration
  output [4*MIN_WIDTH-1:0] out_two
);

// Block is used to combine and accumulate partial products for dual and quad configurations
// while conserving wire area and complexity 

endmodule