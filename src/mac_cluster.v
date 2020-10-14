`include const.vh

module #(
  parameter MIN_WIDTH = 8,
  parameter MUL_WIDTH = 2*MIN_WIDTH,
  parameter ACC_WIDTH = 2*MUL_WIDTH,
  parameter CONF_WIDTH = 3  // 1 bit for mac or mul, 2 bits for Single, Dual, or Quad
) mac_cluster (
  input clk,
  input rst,
  input en,
  input [MIN_WIDTH-1:0] A0,
  input [MIN_WIDTH-1:0] B0,
  input [MIN_WIDTH-1:0] A1,
  input [MIN_WIDTH-1:0] B1,
  input [MIN_WIDTH-1:0] A2,
  input [MIN_WIDTH-1:0] B2,
  input [MIN_WIDTH-1:0] A3,
  input [MIN_WIDTH-1:0] B3,
  input [4*ACC_WIDTH + CONF_WIDTH - 1:0] cfg, // 4 * ACC_WIDTH initial register values + CONF_WIDTH config bits

  output [ACC_WIDTH-1:0] out0,
  output [ACC_WIDTH-1:0] out1,
  output [ACC_WIDTH-1:0] out2,
  output [ACC_WIDTH-1:0] out3
);

wire carry_from_mac0;
wire carry_from_mac1;
wire carry_from_mac2;

wire [MIN_WIDTH-1:0] dual_from_mac0;
wire [MIN_WIDTH-1:0] dual_from_mac1;
wire [MIN_WIDTH-1:0] dual_from_mac2;
wire [MIN_WIDTH-1:0] dual_from_mac3;

wire [MIN_WIDTH-1:0] quad_from_mac0;
wire [MIN_WIDTH-1:0] quad_from_mac1;
wire [MIN_WIDTH-1:0] quad_from_mac2;
wire [MIN_WIDTH-1:0] quad_from_mac3;

wire [ACC_WIDTH-1:0] mac0_out;
wire [ACC_WIDTH-1:0] mac1_out;
wire [ACC_WIDTH-1:0] mac2_out;
wire [ACC_WIDTH-1:0] mac3_out;


// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_block #(.MIN_WIDTH(MIN_WIDTH)) mac0 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(1'b0),
  .A(A0),
  .B(B0),
  .dual_in(dual_from_mac1),
  .quad_in1(quad_from_mac2),
  .quad_in2(quad_from_mac3),
  .cfg({cfg[ACC_WIDTH + CONF_WIDTH - 1:CONF_WIDTH], cfg[CONF_WIDTH-1:0]}),
  .carry_out(carry_from_mac0),
  .dual_out(dual_from_mac0),
  .quad_out(quad_from_mac0),
  .C(mac0_out)
);

mac_block #(.MIN_WIDTH(MIN_WIDTH)) mac1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_from_mac0),
  .A(A1),
  .B(B1),
  .dual_in(dual_from_mac0),
  .quad_in1(quad_from_mac2),
  .quad_in2(quad_from_mac3),
  .cfg({cfg[ACC_WIDTH*2 - 1:ACC_WIDTH + CONF_WIDTH], cfg[CONF_WIDTH-1:0]}),
  .carry_out(carry_from_mac1),
  .dual_out(dual_from_mac1),
  .quad_out(quad_from_mac1),
  .C(mac1_out)
);

mac_block #(.MIN_WIDTH(MIN_WIDTH)) mac2 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_from_mac1),
  .A(A2),
  .B(B2),
  .dual_in(dual_from_mac3),
  .quad_in1(quad_from_mac0),
  .quad_in2(quad_from_mac1),
  .cfg({cfg[ACC_WIDTH*3 - 1 : ACC_WIDTH*2 + CONF_WIDTH], cfg[CONF_WIDTH-1:0]}),
  .carry_out(carry_from_mac2),
  .dual_out(dual_from_mac2),
  .quad_out(quad_from_mac2),
  .C(mac2_out)
);

mac_block #(.MIN_WIDTH(MIN_WIDTH)) mac3 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_from_mac2),
  .A(A3),
  .B(B3),
  .dual_in(dual_from_mac2),
  .quad_in1(quad_from_mac0),
  .quad_in2(quad_from_mac1),
  .cfg({cfg[ACC_WIDTH*4 - 1 : ACC_WIDTH*3 + CONF_WIDTH], cfg[CONF_WIDTH-1:0]}),
  .carry_out(),
  .dual_out(dual_from_mac3),
  .quad_out(quad_from_mac3),
  .C(mac3_out)
);

// Combiner
combiner #(.MIN_WIDTH(MIN_WIDTH)) comb1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(cfg[2:0]), // Only taking the last 2 bits for Single, Dual or Quad
  .partial0(mac0_out),
  .partial1(mac1_out),
  .partial2(mac2_out),
  .partial3(mac3_out),
  .out0(out0),
  .out1(out1),
  .out2(out2),
  .out3(out3)
);

endmodule