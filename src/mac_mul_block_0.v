`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_mul_block_0 #(
  parameter MAC_CONF_WIDTH=2,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_MULT_WIDTH=2*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input [MAC_MIN_WIDTH-1:0] B0,
  input [MAC_MIN_WIDTH-1:0] A0,
  input [MAC_MIN_WIDTH-1:0] A1,     // Used for cross-multiply when chaining   
  input [MAC_MIN_WIDTH-1:0] A2,     // Will solidify signals names later
  input [MAC_MIN_WIDTH-1:0] A3,
  input [MAC_CONF_WIDTH - 1:0] cfg, // Single, Dual or Quad

  output [MAC_INT_WIDTH-1:0] C  // Non-pipelined
);

wire single = ~(cfg[0] | cfg[1]);
wire dual = ~cfg[1] & cfg[0];
wire quad = cfg[1] & ~cfg[0];

wire [MAC_MULT_WIDTH-1:0] A0B0;
wire [MAC_MULT_WIDTH-1:0] A1B0;
wire [MAC_MULT_WIDTH-1:0] A2B0;
wire [MAC_MULT_WIDTH-1:0] A3B0;

// The multiply unit used for all configurations
multiply #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH)
) A0B0_mul_block (
  .A(A0), 
  .B(B0), 
  .C(A0B0)
);

// The secondary mul unit used for dual configs
multiply #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH)
) A1B0_mul_block (
  .A(A1), 
  .B(B0), 
  .C(A1B0)
);

// The third and fourth mul unit used for quad configs
multiply #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH)
) A2B0_mul_block (
  .A(A2), 
  .B(B0), 
  .C(A2B0)
);

multiply #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_MULT_WIDTH(MAC_MULT_WIDTH)
) A3B0_mul_block (
  .A(A3), 
  .B(B0), 
  .C(A3B0)
);

// Multiply output
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
  .A(A0B0[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(A1B0[MAC_MIN_WIDTH-1:0]),
  .cin(1'b0),
  .SUM(block_1_sum),
  .cout(block_1_cout)
);

wire [MAC_MIN_WIDTH-1:0] block_2_B = quad ? A2B0[MAC_MIN_WIDTH-1:0] : {MAC_MIN_WIDTH{1'b0}};
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_2_adder (
  .A(A1B0[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(block_2_B),
  .cin(block_1_cout),
  .SUM(block_2_sum),
  .cout(block_2_cout)
);

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_3_adder (
  .A(A2B0[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B(A3B0[MAC_MIN_WIDTH-1:0]),
  .cin(block_2_cout),
  .SUM(block_3_sum),
  .cout(block_3_cout)
);

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) block_4_adder (
  .A(A3B0[MAC_MULT_WIDTH-1:MAC_MIN_WIDTH]),
  .B({MAC_MIN_WIDTH{1'b0}}),
  .cin(block_3_cout),
  .SUM(block_4_sum),
  .cout()
);

assign C[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = A0B0[MAC_MIN_WIDTH-1:0];
assign C[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? A0B0[2*MAC_MIN_WIDTH-1:MAC_MIN_WIDTH] : block_1_sum;
assign C[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? {MAC_MIN_WIDTH{1'b0}} : block_2_sum;
assign C[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = quad ? block_3_sum : {MAC_MIN_WIDTH{1'b0}};
assign C[5*MAC_MIN_WIDTH-1:4*MAC_MIN_WIDTH] = quad ? block_4_sum : {MAC_MIN_WIDTH{1'b0}};

endmodule
