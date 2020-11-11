`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_combiner_block #(
  parameter MAC_CONF_WIDTH=3,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input [MAC_CONF_WIDTH - 1:0] cfg, // 4 * MAC_ACC_WIDTH initial register values + MAC_CONF_WIDTH config bits
  input [MAC_INT_WIDTH-1:0] partial0,      
  input [MAC_INT_WIDTH-1:0] partial1,
  input [MAC_INT_WIDTH-1:0] partial2,
  input [MAC_INT_WIDTH-1:0] partial3,

  output [MAC_ACC_WIDTH-1:0] out0,       // Output passed through in single mode
  output [MAC_ACC_WIDTH-1:0] out1,       // Output split across one+two, three+four in dual mode
  output [MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output [MAC_ACC_WIDTH-1:0] out3
);

// reg [MAC_ACC_WIDTH-1:0] mult_only_out0;  
// reg [MAC_ACC_WIDTH-1:0] mult_only_out1;
// reg [MAC_ACC_WIDTH-1:0] mult_only_out2;
// reg [MAC_ACC_WIDTH-1:0] mult_only_out3;

wire quad = cfg[1] & ~cfg[0];
wire dual = ~cfg[1] & cfg[0];
wire single = ~(cfg[1] | cfg[0]);

wire partial0_upper_partial1_full_cout;
wire partial2_upper_partial3_full_cout;
wire quad_full_adder_cout;

wire [MAC_INT_WIDTH-1:0] partial0_upper_partial1_full_sum;
wire [MAC_INT_WIDTH-1:0] partial2_upper_partial3_full_sum;
wire [MAC_INT_WIDTH+MAC_MIN_WIDTH:0] quad_full_adder_sum;

n_bit_adder #(
  .N(MAC_INT_WIDTH)
) partial0_upper_partial1_full_adder (
  .A({{MAC_MIN_WIDTH{1'b0}}, partial0[MAC_INT_WIDTH-1:MAC_MIN_WIDTH]}),
  .B(partial1),
  .cin(1'b0),
  .SUM(partial0_upper_partial1_full_sum),
  .cout(partial0_upper_partial1_full_cout)
);

n_bit_adder #(
  .N(MAC_INT_WIDTH)
) partial2_upper_partial3_full_adder (
  .A({{MAC_MIN_WIDTH{1'b0}}, partial2[MAC_INT_WIDTH-1:MAC_MIN_WIDTH]}),
  .B(partial3),
  .cin(1'b0),
  .SUM(partial2_upper_partial3_full_sum),
  .cout(partial2_upper_partial3_full_cout)
);

n_bit_adder #(
  .N(MAC_INT_WIDTH+MAC_MIN_WIDTH+1)
) quad_full_adder (
  .A({{2*MAC_MIN_WIDTH-1{1'b0}}, partial0_upper_partial1_full_cout, partial0_upper_partial1_full_sum[MAC_INT_WIDTH-1:2*MAC_MIN_WIDTH]}),
  .B({partial2_upper_partial3_full_cout, partial2_upper_partial3_full_sum, partial2[MAC_MIN_WIDTH-1:0]}),
  .cin(1'b0),
  .SUM(quad_full_adder_sum),
  .cout(quad_full_adder_cout)
);

// out0 assignment
assign out0[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = partial0[MAC_MIN_WIDTH-1:0];
assign out0[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? partial0[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] : partial0_upper_partial1_full_sum[MAC_MIN_WIDTH-1:0];
assign out0[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? partial0[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : (dual ? partial0_upper_partial1_full_sum[2*MAC_MIN_WIDTH-1:MAC_MIN_WIDTH] : quad_full_adder_sum[MAC_MIN_WIDTH-1:0]);
assign out0[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = single ? partial0[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : (dual ? partial0_upper_partial1_full_sum[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : quad_full_adder_sum[2*MAC_MIN_WIDTH-1:MAC_MIN_WIDTH]);

// out1  assignment
assign out1[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = single ? partial1[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] : (dual ? partial0_upper_partial1_full_sum[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : quad_full_adder_sum[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH]);
assign out1[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? partial1[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] : (dual ? partial0_upper_partial1_full_sum[5*MAC_MIN_WIDTH-1:4*MAC_MIN_WIDTH] : quad_full_adder_sum[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH]);
assign out1[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? partial1[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : (dual ? {{MAC_MIN_WIDTH-1{1'b0}}, partial0_upper_partial1_full_cout} : quad_full_adder_sum[5*MAC_MIN_WIDTH-1:4*MAC_MIN_WIDTH]);
assign out1[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = single ? partial1[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : (dual ? {MAC_MIN_WIDTH{1'b0}} : quad_full_adder_sum[6*MAC_MIN_WIDTH-1:5*MAC_MIN_WIDTH]);

// out2 assignment
assign out2[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = quad ? {{MAC_MIN_WIDTH-2{1'b0}}, quad_full_adder_cout, quad_full_adder_sum[6*MAC_MIN_WIDTH]} : partial2[MAC_MIN_WIDTH-1:0];
assign out2[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? partial2[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] : (dual ? partial2_upper_partial3_full_sum[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] : {MAC_MIN_WIDTH{1'b0}});
assign out2[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? partial2[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : (dual ? partial2_upper_partial3_full_sum[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] : {MAC_MIN_WIDTH{1'b0}});
assign out2[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = single ? partial2[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : (dual ? partial2_upper_partial3_full_sum[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : {MAC_MIN_WIDTH{1'b0}});

// out3  assignment
assign out3[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] = single ? partial3[1*MAC_MIN_WIDTH-1:0*MAC_MIN_WIDTH] : (dual ? partial2_upper_partial3_full_sum[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : {MAC_MIN_WIDTH{1'b0}});
assign out3[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] = single ? partial3[2*MAC_MIN_WIDTH-1:1*MAC_MIN_WIDTH] : (dual ? partial2_upper_partial3_full_sum[5*MAC_MIN_WIDTH-1:4*MAC_MIN_WIDTH] : {MAC_MIN_WIDTH{1'b0}});
assign out3[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] = single ? partial3[3*MAC_MIN_WIDTH-1:2*MAC_MIN_WIDTH] : (dual ? {{MAC_MIN_WIDTH-1{1'b0}}, partial2_upper_partial3_full_cout} : {MAC_MIN_WIDTH{1'b0}});
assign out3[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] = single ? partial3[4*MAC_MIN_WIDTH-1:3*MAC_MIN_WIDTH] : (dual ? {MAC_MIN_WIDTH{1'b0}} : {MAC_MIN_WIDTH{1'b0}});




// always @(*) begin
//   case (cfg[1:0])
//     `MAC_DUAL: begin
//       {mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH);
//       {mult_only_out3, mult_only_out2} = partial2 + (partial3 << MAC_MIN_WIDTH);
//     end
//     `MAC_QUAD: begin
//       {mult_only_out3, mult_only_out2, mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH) + (partial2 << 2*MAC_MIN_WIDTH) + (partial3 << 3*MAC_MIN_WIDTH);
//     end
//     default: begin
//       mult_only_out0 = partial0;
//       mult_only_out1 = partial1;
//       mult_only_out2 = partial2;
//       mult_only_out3 = partial3;
//     end
//   endcase
// end


// // Assigning outputs
// assign out0 = mult_only_out0;
// assign out1 = mult_only_out1;
// assign out2 = mult_only_out2;
// assign out3 = mult_only_out3;

endmodule
