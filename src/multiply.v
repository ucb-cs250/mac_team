`include "mac_const.vh"

module multiply #(
  parameter MAC_MIN_WIDTH = 8,
  parameter MAC_MULT_WIDTH = 2*MAC_MIN_WIDTH
)(
  input [MAC_MIN_WIDTH-1:0] A,
  input [MAC_MIN_WIDTH-1:0] B,

  output [MAC_MULT_WIDTH-1:0] C
);

// Separate file in case we want to modify how we do multiply...
assign C = A * B;

endmodule
