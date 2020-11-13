`timescale 1ns / 1ps
`include "mac_const.vh"

module accumulate #(
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH
)(
  input clk,
  input rst,
  input en,
  input cset,
  input carry_in,
  input [MAC_ACC_WIDTH - 1:0] init, // Initial value
  input [MAC_ACC_WIDTH - 1:0] acc_in, 

  output carry_out,
  output [MAC_ACC_WIDTH-1:0] out
);

reg [MAC_ACC_WIDTH - 1:0] sum_reg;
wire [MAC_ACC_WIDTH - 1:0] sum;

always @(posedge clk) begin
  if (rst) begin
    sum_reg <= {MAC_ACC_WIDTH{1'b0}};
  end else if (cset) begin
    sum_reg <= init;
  end else if (en) begin
    sum_reg <= sum;
  end else begin
    sum_reg <= sum_reg;
  end
end

n_bit_adder #(
  .N(MAC_ACC_WIDTH)
) accumlate_adder (
  .A(sum_reg),
  .B(acc_in),
  .cin(carry_in),
  .SUM(sum),
  .cout(carry_out)
);

assign out = sum_reg;

endmodule
