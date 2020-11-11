`timescale 1ns / 1ps

module n_bit_adder #(
	parameter N=8
)(
	input [N-1:0] 	A,
	input [N-1:0] 	B,
	input 			cin,
	output [N-1:0]	SUM,
	output			cout
);

wire [N:0] carry_bus;

assign carry_bus[0] = cin;

generate
	genvar i;
	for (i = 0; i < N; i = i + 1) begin: adder_chain
		sky130_fd_sc_hd__fa adder (
    		.COUT(carry_bus[i+1]),
    		.SUM(SUM[i]),
    		.A(A[i]),
    		.B(B[i]),
    		.CIN(carry_bus[i])
		);
	end
endgenerate

assign cout = carry_bus[N];

endmodule