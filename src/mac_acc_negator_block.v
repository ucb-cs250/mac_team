`include "mac_const.vh"

module mac_acc_negator_block #(
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

  input [MAC_ACC_WIDTH-1:0] C0_in,
  input [MAC_ACC_WIDTH-1:0] C1_in,
  input [MAC_ACC_WIDTH-1:0] C2_in,
  input [MAC_ACC_WIDTH-1:0] C3_in,

  // Is the multiplication result of Ai * Bi negative
  input C0_neg,
  input C1_neg,
  input C2_neg,
  input C3_neg,

  output [MAC_ACC_WIDTH-1:0] C0_out,
  output [MAC_ACC_WIDTH-1:0] C1_out,
  output [MAC_ACC_WIDTH-1:0] C2_out,
  output [MAC_ACC_WIDTH-1:0] C3_out
);

wire [MAC_ACC_WIDTH-1:0] C0_bar;
wire [MAC_ACC_WIDTH-1:0] C1_bar;
wire [MAC_ACC_WIDTH-1:0] C2_bar;
wire [MAC_ACC_WIDTH-1:0] C3_bar;

wire C0_cout;
wire C1_cout;
wire C2_cout;

wire C1_cin;
wire C2_cin;
wire C3_cin;

wire quad = cfg[1] & ~cfg[0];
wire dual = ~cfg[1] & cfg[0];
wire single = ~(quad | dual);

wire C0_msb = C0_in[MAC_ACC_WIDTH-1];
wire C1_msb = C1_in[MAC_ACC_WIDTH-1];
wire C2_msb = C2_in[MAC_ACC_WIDTH-1];
wire C3_msb = C3_in[MAC_ACC_WIDTH-1];

// Configurable negation chain
assign C0_bar = ~C0_in + 1;
assign C0_cout = &(~C0_in);

assign C1_cin = ~single ? C0_cout : 1;
assign C1_bar = ~C1_in + C1_cin;
assign C1_cout = &(~C1_in);

assign C2_cin = quad ? C1_cout : 1;
assign C2_bar = ~C2_in + C2_cin;
assign C2_cout = &(~C2_in);

assign C3_cin = ~single ? C2_cout : 1;
assign C3_bar = ~C3_in + C3_cin;

// Select negated or normal output based on cfg[1:0] -> single dual quad, is neg inputs
// 1 for negated, 0 for normal
wire C0_select = (single & C0_neg) | (dual & C1_neg) | (quad & C3_neg);
wire C1_select = (~quad & C1_neg) | (quad & C3_neg);
wire C2_select = (single & C2_neg) | (~single & C3_neg);
wire C3_select = C3_neg;

assign C0_out = C0_select & cfg[3] ? C0_bar : C0_in;
assign C1_out = C1_select & cfg[3] ? C1_bar : C1_in;
assign C2_out = C2_select & cfg[3] ? C2_bar : C2_in;
assign C3_out = C3_select & cfg[3] ? C3_bar : C3_in;

endmodule
