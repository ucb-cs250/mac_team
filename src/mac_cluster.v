`include "mac_const.vh"

module mac_cluster (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] A0,
  input [`MAC_MIN_WIDTH-1:0] B0,
  input [`MAC_MIN_WIDTH-1:0] A1,
  input [`MAC_MIN_WIDTH-1:0] B1,
  input [`MAC_MIN_WIDTH-1:0] A2,
  input [`MAC_MIN_WIDTH-1:0] B2,
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_MIN_WIDTH-1:0] B3,
  input [4*`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:0] cfg, // 4 * `MAC_ACC_WIDTH initial register values + `MAC_CONF_WIDTH config bits

  output [`MAC_ACC_WIDTH-1:0] out0,
  output [`MAC_ACC_WIDTH-1:0] out1,
  output [`MAC_ACC_WIDTH-1:0] out2,
  output [`MAC_ACC_WIDTH-1:0] out3
);

wire [`MAC_MIN_WIDTH-1:0] input_fwd_from_mac0;
wire [`MAC_MIN_WIDTH-1:0] input_fwd_from_mac1;
wire [`MAC_MIN_WIDTH-1:0] input_fwd_from_mac2;
wire [`MAC_MIN_WIDTH-1:0] input_fwd_from_mac3;

wire [`MAC_ACC_WIDTH-1:0] mac0_out;
wire [`MAC_ACC_WIDTH-1:0] mac1_out;
wire [`MAC_ACC_WIDTH-1:0] mac2_out;
wire [`MAC_ACC_WIDTH-1:0] mac3_out;


// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_block mac0 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A(A0),
  .B(B0),
  .dual_in(dual_from_mac1),
  .quad_in1(input_fwd_from_mac2),
  .quad_in2(input_fwd_from_mac3),
  .cfg({cfg[`MAC_ACC_WIDTH+`MAC_CONF_WIDTH-1:`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .input_fwd(input_fwd_from_mac0),
  .C(mac0_out)
);

mac_block mac1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A(A1),
  .B(B1),
  .dual_in(dual_from_mac0),
  .quad_in1(input_fwd_from_mac2),
  .quad_in2(input_fwd_from_mac3),
  .cfg({cfg[`MAC_ACC_WIDTH*2-1:`MAC_ACC_WIDTH+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .input_fwd(input_fwd_from_mac1),
  .C(mac1_out)
);

mac_block mac2 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A(A2),
  .B(B2),
  .dual_in(dual_from_mac3),
  .quad_in1(input_fwd_from_mac0),
  .quad_in2(input_fwd_from_mac1),
  .cfg({cfg[`MAC_ACC_WIDTH*3-1:`MAC_ACC_WIDTH*2+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .input_fwd(input_fwd_from_mac2),
  .C(mac2_out)
);

mac_block mac3 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A(A3),
  .B(B3),
  .dual_in(dual_from_mac2),
  .quad_in1(input_fwd_from_mac0),
  .quad_in2(input_fwd_from_mac1),
  .cfg({cfg[`MAC_ACC_WIDTH*4-1:`MAC_ACC_WIDTH*3+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .input_fwd(input_fwd_from_mac3),
  .C(mac3_out)
);

// Combiner
mac_combiner comb1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(cfg[1:0]), // Only taking the last 2 bits for Single, Dual or Quad
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
