`timescale 1ns / 1ps

module carry_lookahead_unit #(
  parameter N=4 
)(
  input         cin,
  input [N-1:0]   P,
  input [N-1:0]   G,
  output [N-1:0]  C,
  output        GG,
  output        PG
);
  
  // Generate block only elaborated in error case
  if (N > 4 | N < 1) begin
    $error($sformatf("Illegal value for carry_lookahead_unit parameter N (%0d)", N));
  end

  wire C0_and_P0 = P[0] & cin;
  wire G0_and_P1;
  wire C0_and_P0_and_P1;
  wire G1_and_P2;
  wire G0_and_P1_and_P2;
  wire C0_and_P0_and_P1_and_P2;

  assign C[0] = G[0] | C0_and_P0;

  if (N > 1) begin
    assign G0_and_P1 = G[0] & P[1];
    assign C0_and_P0_and_P1 = C0_and_P0 & P[1];
    assign C[1] = G[1] | (G0_and_P1) | (C0_and_P0_and_P1);
  end

  if (N > 2) begin
    assign G1_and_P2 = G[1] & P[2];
    assign G0_and_P1_and_P2 = G0_and_P1 & P[2];
    assign C0_and_P0_and_P1_and_P2 = C0_and_P0 & (P[1] & P[2]);
    assign C[2] = G[2] | (G1_and_P2) | (G0_and_P1_and_P2) | (C0_and_P0_and_P1_and_P2);
  end

  if (N > 3) begin
    assign C[3] = G[3] | (G[2] & P[3]) | (G1_and_P2 & P[3]) | (G0_and_P1_and_P2 & P[3]) | (C0_and_P0_and_P1_and_P2 & P[3]);
  end

  if (N == 1) begin
    assign GG = G[0];
  end else if (N == 2) begin
    assign GG = G[1] | (G[0] & P[1]);
  end else if (N == 3) begin
    assign GG = G[2] | (G[1] & P[2]) | (G[0] & P[1] & P[2]);
  end else begin
    assign GG = G[3] | (G[2] & P[3]) | (G1_and_P2 & P[3]) | (G0_and_P1_and_P2 & P[3]);
  end

  assign PG = &P;




endmodule