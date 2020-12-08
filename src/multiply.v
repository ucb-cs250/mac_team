`timescale 1ns / 1ps
`include "mac_const.vh"

module multiply #(
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_MULT_WIDTH=2*MAC_MIN_WIDTH
)(
  input [MAC_MIN_WIDTH-1:0] A,
  input [MAC_MIN_WIDTH-1:0] B,

  output [MAC_MULT_WIDTH-1:0] C
);

// Separate file in case we want to modify how we do multiply...
if (MAC_MIN_WIDTH == 8) begin
	dadda_8_8_mult array_multiplier (
		.A(A),
		.B(B),
		.C(C)
	);
end else begin
	n_bit_array_multiplier #(
		.N(MAC_MIN_WIDTH)
	) array_multiplier (
		.A(A),
		.B(B),
		.PROD(C)
	);
end
endmodule
