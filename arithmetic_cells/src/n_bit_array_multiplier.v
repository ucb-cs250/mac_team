`timescale 1ns / 1ps

module array_multiplier_cell (
  input a,
  input b,
  input sum_in,
  input cin,
  output sum_out,
  output cout
);

wire ab = a & b;

sky130_fd_sc_hd__fa adder (
  .COUT(cout),
  .SUM(sum_out),
  .A(sum_in),
  .B(ab),
  .CIN(cin)
);
endmodule

module n_bit_array_multiplier #(
	parameter N=8
)(
	input [N-1:0] 		A,
	input [N-1:0] 		B,
	output [2*N-1:0]	PROD
);

wire carry_bus [N-1:0][N-1:0];
wire sum_bus  [N-1:0][N-1:0];

generate
	genvar i;
	for (i = 0; i < N; i = i + 1) begin: horizontal
		genvar j;
		for (j = 0; j < N; j = j + 1) begin: vertical
      wire cin;
      wire sum_in;
      // Positional carry in assignment
      if (i == 0) begin
        assign cin = 0;
      end else begin
        assign cin = carry_bus[i-1][j];
      end
      // Positional sum in assignment
      if (j == 0) begin
        assign sum_in = 0;
      end else if (i == N-1) begin
        assign sum_in = carry_bus[N-1][j-1];
      end else begin
        assign sum_in = sum_bus[i+1][j-1];
      end
 
			array_multiplier_cell multiplier_cell (
				.a(A[j]),
				.b(B[i]),
        .sum_in(sum_in),
        .cin(cin),
        .sum_out(sum_bus[i][j]),
        .cout(carry_bus[i][j])
			);

      // Positional prod assignment
      if (i == 0) begin
        assign PROD[j] = sum_bus[i][j];
      end else if (j == N-1) begin
        assign PROD[N-1+i] = sum_bus[i][j];
      end
		end
	end
endgenerate

assign PROD[2*N-1] = carry_bus[N-1][N-1];
endmodule