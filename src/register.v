`timescale 1ns / 1ps

module register #(
  parameter WIDTH=32
)(
  input clk,
  input rst,
  input en,

  input [WIDTH-1:0] D,
  output [WIDTH-1:0] Q
);

reg [WIDTH-1:0] Q_reg;

always @(posedge clk) begin
  if (rst) begin
    Q_reg <= 0;
  end else if (en) begin
    Q_reg <= D;
  end else begin
    Q_reg <= Q_reg;
  end
end

assign Q = Q_reg;

endmodule