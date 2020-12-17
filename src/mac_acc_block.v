`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_acc_block #(
  parameter MAC_CONF_WIDTH=3,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input cset,
  input [MAC_CONF_WIDTH - 1:0] cfg, // 4 * MAC_ACC_WIDTH initial register values + MAC_CONF_WIDTH config bits
  input [MAC_ACC_WIDTH-1:0] initial0,
  input [MAC_ACC_WIDTH-1:0] initial1,
  input [MAC_ACC_WIDTH-1:0] initial2,
  input [MAC_ACC_WIDTH-1:0] initial3,
  input [MAC_ACC_WIDTH-1:0] in0,      
  input [MAC_ACC_WIDTH-1:0] in1,
  input [MAC_ACC_WIDTH-1:0] in2,
  input [MAC_ACC_WIDTH-1:0] in3,

  output [MAC_ACC_WIDTH-1:0] out0,       // Output passed through in single mode
  output [MAC_ACC_WIDTH-1:0] out1,       // Output split across one+two, three+four in dual mode
  output [MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output [MAC_ACC_WIDTH-1:0] out3
);

reg [MAC_ACC_WIDTH-1:0] mult_only_out0_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out1_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out2_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out3_reg;

wire [MAC_ACC_WIDTH-1:0] acc_out0;
wire [MAC_ACC_WIDTH-1:0] acc_out1;
wire [MAC_ACC_WIDTH-1:0] acc_out2;
wire [MAC_ACC_WIDTH-1:0] acc_out3;

// Pipelining multiply-only results
always @(posedge clk) begin
  mult_only_out0_reg <= in0;
  mult_only_out1_reg <= in1;
  mult_only_out2_reg <= in2;
  mult_only_out3_reg <= in3;
end

wire carry_in_1;
wire carry_in_2;
wire carry_in_3;

wire [3:0] P;
wire [3:0] G;
wire [2:0] C;

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc0 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cset(cset),
  .init(initial0),
  .carry_in(1'b0),
  .acc_in(in0),
  .PG(P[0]),
  .GG(G[0]),
  .out(acc_out0)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc1 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cset(cset),
  .init(initial1),
  .carry_in(carry_in_1),
  .acc_in(in1),
  .PG(P[1]),
  .GG(G[1]),
  .out(acc_out1)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc2 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cset(cset),
  .init(initial2),
  .carry_in(carry_in_2),
  .acc_in(in2),
  .PG(P[2]),
  .GG(G[2]),
  .out(acc_out2)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc3 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .cset(cset),
  .init(initial3),
  .carry_in(carry_in_3),
  .acc_in(in3),
  .PG(P[3]),
  .GG(G[3]),
  .out(acc_out3)
);

carry_lookahead_unit #(
  .N(4)
) clu (
  .cin(1'b0),
  .P(P),
  .G(G),
  .C(C),
  .GG(),
  .PG()
);

// Assigning Carry Signals
wire single = ~(cfg[1] | cfg[0]);
wire quad = cfg[1] & ~cfg[0];

assign carry_in_1 = single ? 1'b0 : C[0];
assign carry_in_2 = quad ? C[1] : 1'b0;
assign carry_in_3 = single ? 1'b0 : C[2];

// Assigning outputs
assign out0 = cfg[2] ? acc_out0 : mult_only_out0_reg;
assign out1 = cfg[2] ? acc_out1 : mult_only_out1_reg;
assign out2 = cfg[2] ? acc_out2 : mult_only_out2_reg;
assign out3 = cfg[2] ? acc_out3 : mult_only_out3_reg;

endmodule
