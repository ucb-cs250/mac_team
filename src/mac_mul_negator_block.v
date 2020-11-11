`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_mul_negator_block #(
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

  // Least significant MAC_CONF_WIDTH as above.
  input [MAC_CONF_WIDTH - 1:0] cfg,

  input [MAC_MIN_WIDTH-1:0] A0_in,
  input [MAC_MIN_WIDTH-1:0] B0_in,
  input [MAC_MIN_WIDTH-1:0] A1_in,
  input [MAC_MIN_WIDTH-1:0] B1_in,
  input [MAC_MIN_WIDTH-1:0] A2_in,
  input [MAC_MIN_WIDTH-1:0] B2_in,
  input [MAC_MIN_WIDTH-1:0] A3_in,
  input [MAC_MIN_WIDTH-1:0] B3_in,

  output [MAC_MIN_WIDTH-1:0] A0_out,
  output [MAC_MIN_WIDTH-1:0] B0_out,
  output [MAC_MIN_WIDTH-1:0] A1_out,
  output [MAC_MIN_WIDTH-1:0] B1_out,
  output [MAC_MIN_WIDTH-1:0] A2_out,
  output [MAC_MIN_WIDTH-1:0] B2_out,
  output [MAC_MIN_WIDTH-1:0] A3_out,
  output [MAC_MIN_WIDTH-1:0] B3_out,

  // Is the multiplication result of Ai * Bi negative
  output C0_neg,
  output C1_neg,
  output C2_neg,
  output C3_neg
);

wire [MAC_MIN_WIDTH-1:0] A0_bar;
wire [MAC_MIN_WIDTH-1:0] A1_bar;
wire [MAC_MIN_WIDTH-1:0] A2_bar;
wire [MAC_MIN_WIDTH-1:0] A3_bar;
wire [MAC_MIN_WIDTH-1:0] B0_bar;
wire [MAC_MIN_WIDTH-1:0] B1_bar;
wire [MAC_MIN_WIDTH-1:0] B2_bar;
wire [MAC_MIN_WIDTH-1:0] B3_bar;

wire A0_cout;
wire A1_cout;
wire A2_cout;
wire B0_cout;
wire B1_cout;
wire B2_cout;

wire A1_cin;
wire A2_cin;
wire A3_cin;
wire B1_cin;
wire B2_cin;
wire B3_cin;

wire quad = cfg[1] & ~cfg[0];
wire dual = ~cfg[1] & cfg[0];
wire single = ~(quad | dual);

wire A0_msb = A0_in[MAC_MIN_WIDTH-1];
wire A1_msb = A1_in[MAC_MIN_WIDTH-1];
wire A2_msb = A2_in[MAC_MIN_WIDTH-1];
wire A3_msb = A3_in[MAC_MIN_WIDTH-1];
wire B0_msb = B0_in[MAC_MIN_WIDTH-1];
wire B1_msb = B1_in[MAC_MIN_WIDTH-1];
wire B2_msb = B2_in[MAC_MIN_WIDTH-1];
wire B3_msb = B3_in[MAC_MIN_WIDTH-1];


// Is outcome signed
assign C0_neg = A0_msb ^ B0_msb;
assign C1_neg = A1_msb ^ B1_msb;
assign C2_neg = A2_msb ^ B2_msb;
assign C3_neg = A3_msb ^ B3_msb;

// Configurable negation chain
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) A0_adder (
  .A(~A0_in),
  .B(0),
  .cin(1),
  .SUM(A0_bar),
  .cout(A0_cout)
);

assign A1_cin = ~single ? A0_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) A1_adder (
  .A(~A1_in),
  .B(0),
  .cin(A1_cin),
  .SUM(A1_bar),
  .cout(A1_cout)
);

assign A2_cin = quad ? A1_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) A2_adder (
  .A(~A2_in),
  .B(0),
  .cin(A2_cin),
  .SUM(A2_bar),
  .cout(A2_cout)
);

assign A3_cin = ~single ? A2_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) A3_adder (
  .A(~A3_in),
  .B(0),
  .cin(A3_cin),
  .SUM(A3_bar),
  .cout()
);

n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) B0_adder (
  .A(~B0_in),
  .B(0),
  .cin(1),
  .SUM(B0_bar),
  .cout(B0_cout)
);

assign B1_cin = ~single ? B0_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) B1_adder (
  .A(~B1_in),
  .B(0),
  .cin(B1_cin),
  .SUM(B1_bar),
  .cout(B1_cout)
);

assign B2_cin = quad ? B1_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) B2_adder (
  .A(~B2_in),
  .B(0),
  .cin(B2_cin),
  .SUM(B2_bar),
  .cout(B2_cout)
);

assign B3_cin = ~single ? B2_cout : 1;
n_bit_adder #(
  .N(MAC_MIN_WIDTH)
) B3_adder (
  .A(~B3_in),
  .B(0),
  .cin(B3_cin),
  .SUM(B3_bar),
  .cout()
);

// assign A0_bar = ~A0_in + 1;
// assign A0_cout = &(~A0_in);

// assign A1_cin = ~single ? A0_cout : 1;
// assign A1_bar = ~A1_in + A1_cin;
// assign A1_cout = &(~A1_in) & A1_cin;

// assign A2_cin = quad ? A1_cout : 1;
// assign A2_bar = ~A2_in + A2_cin;
// assign A2_cout = &(~A2_in) & A2_cin;

// assign A3_cin = ~single ? A2_cout : 1;
// assign A3_bar = ~A3_in + A3_cin;

// assign B0_bar = ~B0_in + 1;
// assign B0_cout = &(~B0_in);

// assign B1_cin = ~single ? B0_cout : 1;
// assign B1_bar = ~B1_in + B1_cin;
// assign B1_cout = &(~B1_in) & B1_cin;

// assign B2_cin = quad ? B1_cout : 1;
// assign B2_bar = ~B2_in + B2_cin;
// assign B2_cout = &(~B2_in) & B2_cin;

// assign B3_cin = ~single ? B2_cout : 1;
// assign B3_bar = ~B3_in + B3_cin;

// Select negated or normal output based on cfg[1:0] -> single dual quad, cfg[3] unsigned, signed
// 1 for negated, 0 for normal
wire A0_select = (single & A0_msb) | (dual & A1_msb) | (quad & A3_msb);
wire A1_select = (~quad & A1_msb) | (quad & A3_msb);
wire A2_select = (single & A2_msb) | (~single & A3_msb);
wire A3_select = A3_msb;
wire B0_select = (single & B0_msb) | (dual & B1_msb) | (quad & B3_msb);
wire B1_select = (~quad & B1_msb) | (quad & B3_msb);
wire B2_select = (single & B2_msb) | (~single & B3_msb);
wire B3_select = B3_msb;

assign A0_out = A0_select & cfg[3] ? A0_bar : A0_in;
assign A1_out = A1_select & cfg[3] ? A1_bar : A1_in;
assign A2_out = A2_select & cfg[3] ? A2_bar : A2_in;
assign A3_out = A3_select & cfg[3] ? A3_bar : A3_in;
assign B0_out = B0_select & cfg[3] ? B0_bar : B0_in;
assign B1_out = B1_select & cfg[3] ? B1_bar : B1_in;
assign B2_out = B2_select & cfg[3] ? B2_bar : B2_in;
assign B3_out = B3_select & cfg[3] ? B3_bar : B3_in;

endmodule
