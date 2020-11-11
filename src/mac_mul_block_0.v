`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_mul_block_0 #(
  parameter MAC_CONF_WIDTH=3,
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

  output reg [MAC_INT_WIDTH-1:0] C  // Non-pipelined
);

wire [MAC_MULT_WIDTH-1:0] A0B0;
wire [MAC_MULT_WIDTH-1:0] A1B0;
wire [MAC_MULT_WIDTH-1:0] A2B0;
wire [MAC_MULT_WIDTH-1:0] A3B0;

// Multiplication output
always @(*) begin
  case (cfg[1:0])
    `MAC_SINGLE:  C = A0B0;  
    `MAC_DUAL:    C = A0B0 + {A1B0, {MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    C = A0B0 + {A1B0, {MAC_MIN_WIDTH{1'b0}}} + {A2B0, {2*MAC_MIN_WIDTH{1'b0}}} + {A3B0, {3*MAC_MIN_WIDTH{1'b0}}};
    default:      C = 0;
  endcase
end

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

endmodule
