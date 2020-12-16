`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_golden_delay #(
  parameter MAC_MIN_WIDTH=8,
  parameter DELAY=0
)(
  input clk,
  input [MAC_MIN_WIDTH-1:0] A0_in,
  input [MAC_MIN_WIDTH-1:0] A1_in,
  input [MAC_MIN_WIDTH-1:0] A2_in,
  input [MAC_MIN_WIDTH-1:0] A3_in,
  input [MAC_MIN_WIDTH-1:0] B0_in,
  input [MAC_MIN_WIDTH-1:0] B1_in,
  input [MAC_MIN_WIDTH-1:0] B2_in,
  input [MAC_MIN_WIDTH-1:0] B3_in,
  output [MAC_MIN_WIDTH-1:0] A0_out,
  output [MAC_MIN_WIDTH-1:0] A1_out,
  output [MAC_MIN_WIDTH-1:0] A2_out,
  output [MAC_MIN_WIDTH-1:0] A3_out,
  output [MAC_MIN_WIDTH-1:0] B0_out,
  output [MAC_MIN_WIDTH-1:0] B1_out,
  output [MAC_MIN_WIDTH-1:0] B2_out,
  output [MAC_MIN_WIDTH-1:0] B3_out
);
generate
  if (DELAY == 0) begin
    assign A0_out = A0_in;
    assign A1_out = A1_in;
    assign A2_out = A2_in;
    assign A3_out = A3_in;
    assign B0_out = B0_in;
    assign B1_out = B1_in;
    assign B2_out = B2_in;
    assign B3_out = B3_in;
  end else begin
    reg [MAC_MIN_WIDTH-1:0] A0_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] A1_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] A2_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] A3_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] B0_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] B1_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] B2_delay_bus [DELAY-1:0];
    reg [MAC_MIN_WIDTH-1:0] B3_delay_bus [DELAY-1:0];

    always @(posedge clk) begin
      A0_delay_bus[0] <= A0_in;
      A1_delay_bus[0] <= A1_in;
      A2_delay_bus[0] <= A2_in;
      A3_delay_bus[0] <= A3_in;
      B0_delay_bus[0] <= B0_in;
      B1_delay_bus[0] <= B1_in;
      B2_delay_bus[0] <= B2_in;
      B3_delay_bus[0] <= B3_in;  
    end

    genvar i;
    for (i = 1; i < DELAY; i = i + 1) begin: delay_wiring
      always @(posedge clk) begin
        A0_delay_bus[i] <= A0_delay_bus[i-1];
        A1_delay_bus[i] <= A1_delay_bus[i-1];
        A2_delay_bus[i] <= A2_delay_bus[i-1];
        A3_delay_bus[i] <= A3_delay_bus[i-1];
        B0_delay_bus[i] <= B0_delay_bus[i-1];
        B1_delay_bus[i] <= B1_delay_bus[i-1];
        B2_delay_bus[i] <= B2_delay_bus[i-1];
        B3_delay_bus[i] <= B3_delay_bus[i-1];
      end
    end

    assign A0_out = A0_delay_bus[DELAY-1];
    assign A1_out = A1_delay_bus[DELAY-1];
    assign A2_out = A2_delay_bus[DELAY-1];
    assign A3_out = A3_delay_bus[DELAY-1];
    assign B0_out = B0_delay_bus[DELAY-1];
    assign B1_out = B1_delay_bus[DELAY-1];
    assign B2_out = B2_delay_bus[DELAY-1];
    assign B3_out = B3_delay_bus[DELAY-1];
  end
endgenerate
endmodule 
