(* blackbox *)
module mac_cluster #(
  // 1 (MSB) but for signed (1) or unsigned (0), 1 bit for mac or mul, 2 (LSB) bits for Single, Dual, or Quad.
  parameter MAC_CONF_WIDTH=4,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_MULT_WIDTH=2*MAC_MIN_WIDTH,
  parameter MAC_ACC_WIDTH=2*MAC_MULT_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,

  // Shift configuration across cfg bus. When this signal goes high, register
  // the values on the cfg bus.
  input cset,

  // Most significant 4*MAC_ACC_WIDTH: Initial MAC accumulator state, for
  //                                   4 blocks.
  // Least significant MAC_CONF_WIDTH as above.
  input [4*MAC_ACC_WIDTH + MAC_CONF_WIDTH - 1:0] cfg,

  input [MAC_MIN_WIDTH-1:0] A0,
  input [MAC_MIN_WIDTH-1:0] B0,
  input [MAC_MIN_WIDTH-1:0] A1,
  input [MAC_MIN_WIDTH-1:0] B1,
  input [MAC_MIN_WIDTH-1:0] A2,
  input [MAC_MIN_WIDTH-1:0] B2,
  input [MAC_MIN_WIDTH-1:0] A3,
  input [MAC_MIN_WIDTH-1:0] B3,

  output [MAC_ACC_WIDTH-1:0] out0,
  output [MAC_ACC_WIDTH-1:0] out1,
  output [MAC_ACC_WIDTH-1:0] out2,
  output [MAC_ACC_WIDTH-1:0] out3
);

endmodule
