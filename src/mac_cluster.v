`timescale 1ns / 1ps
`include "mac_const.vh"

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

/* ---------- GLOBAL WIRES ---------- */
wire pipeline_rst = rst | cset;

/* ---------- CONFIG LATCHING ---------- */
reg [MAC_CONF_WIDTH-1:0] latched_cfg;
always @(posedge clk) begin
  if (rst) begin
    latched_cfg <= {MAC_CONF_WIDTH{1'b0}};
  end else if (cset) begin
    latched_cfg <= cfg[MAC_CONF_WIDTH-1:0];
  end else begin
    latched_cfg <= latched_cfg;
  end
end

/* ---------- PIPELINE STAGE 0 ---------- */
wire [MAC_MIN_WIDTH-1:0] A0_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] A1_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] A2_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] A3_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] B0_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] B1_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] B2_sign_adjusted;
wire [MAC_MIN_WIDTH-1:0] B3_sign_adjusted;
wire C0_neg;
wire C1_neg;
wire C2_neg;
wire C3_neg;


mac_mul_negator_block #(
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmulnegator (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(latched_cfg[3:0]),
  .A0_in(A0),
  .A1_in(A1),
  .A2_in(A2),
  .A3_in(A3),
  .B0_in(B0),
  .B1_in(B1),
  .B2_in(B2),
  .B3_in(B3),
  .A0_out(A0_sign_adjusted),
  .A1_out(A1_sign_adjusted),
  .A2_out(A2_sign_adjusted),
  .A3_out(A3_sign_adjusted),
  .B0_out(B0_sign_adjusted),
  .B1_out(B1_sign_adjusted),
  .B2_out(B2_sign_adjusted),
  .B3_out(B3_sign_adjusted),
  .C0_neg(C0_neg),  
  .C1_neg(C1_neg),
  .C2_neg(C2_neg),
  .C3_neg(C3_neg)
);

/* ---------- PIPELINE REGISTERS ---------- */
wire [MAC_MIN_WIDTH-1:0] A0_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] A1_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] A2_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] A3_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] B0_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] B1_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] B2_sign_adjusted_pipelined;
wire [MAC_MIN_WIDTH-1:0] B3_sign_adjusted_pipelined;

wire C0_neg_pipelined;
wire C1_neg_pipelined;
wire C2_neg_pipelined;
wire C3_neg_pipelined;

register #(
  .WIDTH(MAC_MIN_WIDTH)
) A0_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(A0_sign_adjusted),
  .Q(A0_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) A1_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(A1_sign_adjusted),
  .Q(A1_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) A2_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(A2_sign_adjusted),
  .Q(A2_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) A3_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(A3_sign_adjusted),
  .Q(A3_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) B0_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(B0_sign_adjusted),
  .Q(B0_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) B1_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(B1_sign_adjusted),
  .Q(B1_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) B2_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(B2_sign_adjusted),
  .Q(B2_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_MIN_WIDTH)
) B3_sign_adjusted_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(B3_sign_adjusted),
  .Q(B3_sign_adjusted_pipelined)
);

register #(
  .WIDTH(1)
) C0_neg_register1 (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(C0_neg),
  .Q(C0_neg_pipelined)
);

register #(
  .WIDTH(1)
) C1_neg_register1 (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(C1_neg),
  .Q(C1_neg_pipelined)
);

register #(
  .WIDTH(1)
) C2_neg_register1 (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(C2_neg),
  .Q(C2_neg_pipelined)
);

register #(
  .WIDTH(1)
) C3_neg_register1 (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(C3_neg),
  .Q(C3_neg_pipelined)
);

/* ---------- PIPELINE STAGE 1 ---------- */
wire [MAC_INT_WIDTH-1:0] mac_mul_out0;
wire [MAC_INT_WIDTH-1:0] mac_mul_out1;
wire [MAC_INT_WIDTH-1:0] mac_mul_out2;
wire [MAC_INT_WIDTH-1:0] mac_mul_out3;

// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_mul_block_0 #(
  .MAC_CONF_WIDTH(2),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul0 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0_sign_adjusted_pipelined),
  .A1(A1_sign_adjusted_pipelined),
  .A2(A2_sign_adjusted_pipelined),
  .A3(A3_sign_adjusted_pipelined),
  .B0(B0_sign_adjusted_pipelined),
  .cfg(latched_cfg[1:0]),
  .C(mac_mul_out0)
);

mac_mul_block_1 #(
  .MAC_CONF_WIDTH(2),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul1 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0_sign_adjusted_pipelined),
  .A1(A1_sign_adjusted_pipelined),
  .A2(A2_sign_adjusted_pipelined),
  .A3(A3_sign_adjusted_pipelined),
  .B1(B1_sign_adjusted_pipelined),
  .cfg(latched_cfg[1:0]),
  .C(mac_mul_out1)
);

mac_mul_block_2 #(
  .MAC_CONF_WIDTH(2),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul2 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0_sign_adjusted_pipelined),
  .A1(A1_sign_adjusted_pipelined),
  .A2(A2_sign_adjusted_pipelined),
  .A3(A3_sign_adjusted_pipelined),
  .B2(B2_sign_adjusted_pipelined),
  .cfg(latched_cfg[1:0]),
  .C(mac_mul_out2)
);

mac_mul_block_3 #(
  .MAC_CONF_WIDTH(2),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macmul3 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0_sign_adjusted_pipelined),
  .A1(A1_sign_adjusted_pipelined),
  .A2(A2_sign_adjusted_pipelined),
  .A3(A3_sign_adjusted_pipelined),
  .B3(B3_sign_adjusted_pipelined),
  .cfg(latched_cfg[1:0]),
  .C(mac_mul_out3)
);

/* ---------- PIPELINE REGISTERS ---------- */
// wire [MAC_INT_WIDTH-1:0] mac_mul_out0_pipelined;
// wire [MAC_INT_WIDTH-1:0] mac_mul_out1_pipelined;
// wire [MAC_INT_WIDTH-1:0] mac_mul_out2_pipelined;
// wire [MAC_INT_WIDTH-1:0] mac_mul_out3_pipelined;

// wire C0_neg_pipelined2;
// wire C1_neg_pipelined2;
// wire C2_neg_pipelined2;
// wire C3_neg_pipelined2;

// register #(
//   .WIDTH(MAC_INT_WIDTH)
// ) mac_mul_out0_register (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(mac_mul_out0),
//   .Q(mac_mul_out0_pipelined)
// );

// register #(
//   .WIDTH(MAC_INT_WIDTH)
// ) mac_mul_out1_register (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(mac_mul_out1),
//   .Q(mac_mul_out1_pipelined)
// );

// register #(
//   .WIDTH(MAC_INT_WIDTH)
// ) mac_mul_out2_register (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(mac_mul_out2),
//   .Q(mac_mul_out2_pipelined)
// );

// register #(
//   .WIDTH(MAC_INT_WIDTH)
// ) mac_mul_out3_register (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(mac_mul_out3),
//   .Q(mac_mul_out3_pipelined)
// );

// register #(
//   .WIDTH(1)
// ) C0_neg_register2 (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(C0_neg_pipelined1),
//   .Q(C0_neg_pipelined2)
// );

// register #(
//   .WIDTH(1)
// ) C1_neg_register2 (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(C1_neg_pipelined1),
//   .Q(C1_neg_pipelined2)
// );

// register #(
//   .WIDTH(1)
// ) C2_neg_register2 (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(C2_neg_pipelined1),
//   .Q(C2_neg_pipelined2)
// );

// register #(
//   .WIDTH(1)
// ) C3_neg_register2 (
//   .clk(clk),
//   .rst(pipeline_rst),
//   .en(1'b1),
//   .D(C3_neg_pipelined1),
//   .Q(C3_neg_pipelined2)
// );

wire [MAC_ACC_WIDTH-1:0] mac_combiner_out0;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out1;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out2;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out3;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out0_sign_adjusted;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out1_sign_adjusted;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out2_sign_adjusted;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out3_sign_adjusted;

mac_combiner_block #(
  // 1 (MSB) but for signed (1) or unsigned (0), 1 bit for mac or mul, 2 (LSB) bits for Single, Dual, or Quad.
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH) // Used for internal MAC wires, widest bitwidth according to Quad config
) maccombiner (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(latched_cfg),
  .partial0(mac_mul_out0),
  .partial1(mac_mul_out1),
  .partial2(mac_mul_out2),
  .partial3(mac_mul_out3),
  .out0(mac_combiner_out0),
  .out1(mac_combiner_out1),
  .out2(mac_combiner_out2),
  .out3(mac_combiner_out3)
);

mac_acc_negator_block #(
  // 1 (MSB) but for signed (1) or unsigned (0), 1 bit for mac or mul, 2 (LSB) bits for Single, Dual, or Quad.
  .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH) // Used for internal MAC wires, widest bitwidth according to Quad config
) macaccnegator (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(latched_cfg),
  .C0_in(mac_combiner_out0),
  .C1_in(mac_combiner_out1),
  .C2_in(mac_combiner_out2),
  .C3_in(mac_combiner_out3),
  .C0_neg(C0_neg_pipelined),
  .C1_neg(C1_neg_pipelined),
  .C2_neg(C2_neg_pipelined),
  .C3_neg(C3_neg_pipelined),
  .C0_out(mac_combiner_out0_sign_adjusted),
  .C1_out(mac_combiner_out1_sign_adjusted),
  .C2_out(mac_combiner_out2_sign_adjusted),
  .C3_out(mac_combiner_out3_sign_adjusted)
);

/* ---------- PIPELINE REGISTERS ---------- */
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out0_sign_adjusted_pipelined;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out1_sign_adjusted_pipelined;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out2_sign_adjusted_pipelined;
wire [MAC_ACC_WIDTH-1:0] mac_combiner_out3_sign_adjusted_pipelined;

register #(
  .WIDTH(MAC_ACC_WIDTH)
) mac_mul_out0_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(mac_combiner_out0_sign_adjusted),
  .Q(mac_combiner_out0_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_ACC_WIDTH)
) mac_mul_out1_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(mac_combiner_out1_sign_adjusted),
  .Q(mac_combiner_out1_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_ACC_WIDTH)
) mac_mul_out2_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(mac_combiner_out2_sign_adjusted),
  .Q(mac_combiner_out2_sign_adjusted_pipelined)
);

register #(
  .WIDTH(MAC_ACC_WIDTH)
) mac_mul_out3_register (
  .clk(clk),
  .rst(pipeline_rst),
  .en(1'b1),
  .D(mac_combiner_out3_sign_adjusted),
  .Q(mac_combiner_out3_sign_adjusted_pipelined)
);

/* ---------- PIPELINE STAGE 2 ---------- */
// Accumulator
mac_acc_block #(
  .MAC_CONF_WIDTH(3),
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
  .MAC_INT_WIDTH(MAC_INT_WIDTH)
) macacc (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cset(cset),
  .cfg(latched_cfg[2:0]),
  .initial0(cfg[MAC_ACC_WIDTH*1-1+MAC_CONF_WIDTH:MAC_ACC_WIDTH*0+MAC_CONF_WIDTH]),
  .initial1(cfg[MAC_ACC_WIDTH*2-1+MAC_CONF_WIDTH:MAC_ACC_WIDTH*1+MAC_CONF_WIDTH]),
  .initial2(cfg[MAC_ACC_WIDTH*3-1+MAC_CONF_WIDTH:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH]),
  .initial3(cfg[MAC_ACC_WIDTH*4-1+MAC_CONF_WIDTH:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH]),
  .in0(mac_combiner_out0_sign_adjusted_pipelined),
  .in1(mac_combiner_out1_sign_adjusted_pipelined),
  .in2(mac_combiner_out2_sign_adjusted_pipelined),
  .in3(mac_combiner_out3_sign_adjusted_pipelined),
  .out0(out0),
  .out1(out1),
  .out2(out2),
  .out3(out3)
);

endmodule
