`include "mac_const.vh"

module mac_cluster #(
  // 1 (MSB) bit for mac or mul, 2 (LSB) bits for Single, Dual, or Quad.
  parameter MAC_CONF_WIDTH=3,
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

wire [MAC_INT_WIDTH-1:0] mac_mul_out0;
wire [MAC_INT_WIDTH-1:0] mac_mul_out1;
wire [MAC_INT_WIDTH-1:0] mac_mul_out2;
wire [MAC_INT_WIDTH-1:0] mac_mul_out3;

// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_mul_block_0 #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul0 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B0(B0),
  .cfg(cfg[MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out0)
);

mac_mul_block_1 #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul1 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B1(B1),
  .cfg(cfg[MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out1)
);

mac_mul_block_2 #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul2 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B2(B2),
  .cfg(cfg[MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out2)
);

mac_mul_block_3 #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul3 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B3(B3),
  .cfg(cfg[MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out3)
);

// Combiner
mac_acc_block_2 #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macacc (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(cfg),
  .partial0(mac_mul_out0),
  .partial1(mac_mul_out1),
  .partial2(mac_mul_out2),
  .partial3(mac_mul_out3),
  .out0(out0),
  .out1(out1),
  .out2(out2),
  .out3(out3)
);

endmodule
