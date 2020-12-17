`timescale 1ns / 1ps

module n_bit_one_adder #(
	parameter N=8
)(
	input [N-1:0] 	A,
	input 			cin,
	output [N-1:0]	SUM,
	output			cout
);

// Can convert to another syntax if not accepted by Openlane
wire carry_bus [N:0];

assign carry_bus[0] = cin;

generate
	genvar i;
	for (i = 0; i < N; i = i + 1) begin: adder_chain
		sky130_fd_sc_hd__ha_4 adder (
    		.COUT(carry_bus[i+1]),
    		.SUM(SUM[i]),
    		.A(A[i]),
    		.B(carry_bus[i])
		);
	end
endgenerate

assign cout = carry_bus[N];

endmodule
