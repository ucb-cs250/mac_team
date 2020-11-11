`timescale 1ns / 1ps
`include "mac_const.vh"

module accumulate #(
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH
)(
  input clk,
  input rst,
  input en,
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
    sum_reg <= init;
  end else begin
    sum_reg <= sum;
  end
end

assign {carry_out, sum} = sum_reg + acc_in + carry_in;
assign out = sum_reg;

endmodule