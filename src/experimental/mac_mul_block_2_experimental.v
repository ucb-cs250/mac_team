`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_mul_block_2 #(
  parameter MAC_CONF_WIDTH=2,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_MULT_WIDTH=2*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input [MAC_MIN_WIDTH-1:0] B2,
  input [MAC_MIN_WIDTH-1:0] A0,     // Used for cross-multiply when chaining   
  input [MAC_MIN_WIDTH-1:0] A1,     // Will solidify signals names later
  input [MAC_MIN_WIDTH-1:0] A2,
  input [MAC_MIN_WIDTH-1:0] A3,
  input [MAC_CONF_WIDTH - 1:0] cfg, // Single, Dual or Quad

  output [MAC_INT_WIDTH-1:0] C  // Non-pipelined
);

wire single = ~(cfg[0] | cfg[1]);
wire dual = ~cfg[1] & cfg[0];
wire quad = cfg[1] & ~cfg[0];

wire [MAC_MULT_WIDTH-1:0] A2B2;
wire [MAC_MULT_WIDTH-1:0] A0B2;
wire [MAC_MULT_WIDTH-1:0] A1B2;
wire [MAC_MULT_WIDTH-1:0] A3B2;

// The multiply unit used for all configurations
multiply_experimental A2B2_mul_block
(
  .sign(cfg[1]),
  .A(A2), 
  .B(B2), 
  .C(A2B2)
);

// The secondary mul unit used for dual configs
multiply_experimental A0B2_mul_block 
(
  .sign(cfg[1]),
  .A(A0), 
  .B(B2), 
  .C(A0B2)
);

// The third and fourth mul unit used for quad configs
multiply_experimental A1B2_mul_block
(
  .sign(cfg[1]),
  .A(A1), 
  .B(B2), 
  .C(A1B2)
);
multiply_experimental A3B2_mul_block
(
  .sign(cfg[1]),
  .A(A3), 
  .B(B2), 
  .C(A3B2)
);

// Multiplication Output
wire [MAC_MIN_WIDTH-1:0] block_1_sum;
wire [MAC_MIN_WIDTH-1:0] block_2_sum;
wire [MAC_MIN_WIDTH-1:0] block_3_sum;
wire [MAC_MIN_WIDTH-1:0] block_4_sum;

wire block_1_cout;
wire block_2_cout;
wire block_3_cout;

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_1_adder (
  .A(A0B2[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(A1B2[MAC_MIN_WIDTH-1:0]),
  .cin(1'b0),
  .SUM(block_1_sum),
  .cout(block_1_cout)
);

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_2_adder (
  .A(A1B2[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(A2B2[MAC_MIN_WIDTH-1:0]),
  .cin(block_1_cout),
  .SUM(block_2_sum),
  .cout(block_2_cout)
);

wire block_3_cin = quad ? block_2_cout : 1'b0;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_3_adder (
  .A(A2B2[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(A3B2[MAC_MIN_WIDTH-1:0]),
  .cin(block_3_cin),
  .SUM(block_3_sum),
  .cout(block_3_cout)
);

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_4_adder (
  .A(A3B2[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B({MAC_MIN_WIDTH{1'b0}}),
  .cin(block_3_cout),
  .SUM(block_4_sum),
  .cout()
);

assign C[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = quad ? A0B2[MAC_MIN_WIDTH-1:0] : A2B2[MAC_MIN_WIDTH-1:0];
assign C[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? A2B2[2*MAC_MIN_WIDTH-1:MAC_MIN_WIDTH] : (dual ? block_3_sum : block_1_sum);
assign C[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? {MAC_MIN_WIDTH{1'b0}} : (dual ? block_4_sum : block_2_sum);
assign C[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = quad ? block_3_sum : {MAC_MIN_WIDTH{1'b0}};
assign C[5*MAC_MIN_WIDTH-1:4*MAC_MIN_WIDTH] = quad ? block_4_sum : {MAC_MIN_WIDTH{1'b0}};

endmodule
