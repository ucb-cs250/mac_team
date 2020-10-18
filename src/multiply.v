`include const.vh

module #(
  parameter MIN_WIDTH = 8,
  parameter MUL_WIDTH = 2*MIN_WIDTH
) multiply (
  input [MIN_WIDTH-1:0] A,
  input [MIN_WIDTH-1:0] B,

  output [MUL_WIDTH-1:0] C
)

// Separate file in case we want to modify how we do multiply...
assign C = A * B;

endmodule