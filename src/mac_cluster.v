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

wire [`MAC_INT_WIDTH-1:0] mac0_out;
wire [`MAC_INT_WIDTH-1:0] mac1_out;
wire [`MAC_INT_WIDTH-1:0] mac2_out;
wire [`MAC_INT_WIDTH-1:0] mac3_out;


// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_block_0 mac0 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B0(B0),
  .cfg({cfg[`MAC_ACC_WIDTH+`MAC_CONF_WIDTH-1:`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .C(mac0_out)
);

mac_block_1 mac1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B1(B1),
  .cfg({cfg[`MAC_ACC_WIDTH*2-1:`MAC_ACC_WIDTH+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .C(mac1_out)
);

mac_block_2 mac2 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B2(B2),
  .cfg({cfg[`MAC_ACC_WIDTH*3-1:`MAC_ACC_WIDTH*2+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
  .C(mac2_out)
);

mac_block_3 mac3 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B3(B3),
  .cfg({cfg[`MAC_ACC_WIDTH*4-1:`MAC_ACC_WIDTH*3+`MAC_CONF_WIDTH],cfg[`MAC_CONF_WIDTH-1:0]}),
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
