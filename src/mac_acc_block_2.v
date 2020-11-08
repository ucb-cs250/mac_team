`include "mac_const.vh"

module mac_acc_block_2 #(
  parameter MAC_CONF_WIDTH=3,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input [4*MAC_ACC_WIDTH + MAC_CONF_WIDTH - 1:0] cfg, // 4 * MAC_ACC_WIDTH initial register values + MAC_CONF_WIDTH config bits
  input [MAC_INT_WIDTH-1:0] partial0,      
  input [MAC_INT_WIDTH-1:0] partial1,
  input [MAC_INT_WIDTH-1:0] partial2,
  input [MAC_INT_WIDTH-1:0] partial3,

  output [MAC_ACC_WIDTH-1:0] out0,       // Output passed through in single mode
  output [MAC_ACC_WIDTH-1:0] out1,       // Output split across one+two, three+four in dual mode
  output [MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output [MAC_ACC_WIDTH-1:0] out3
);

reg [MAC_ACC_WIDTH-1:0] mult_only_out0;  // Non-pipelined
reg [MAC_ACC_WIDTH-1:0] mult_only_out1;
reg [MAC_ACC_WIDTH-1:0] mult_only_out2;
reg [MAC_ACC_WIDTH-1:0] mult_only_out3;

reg [MAC_ACC_WIDTH-1:0] mult_only_out0_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out1_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out2_reg;
reg [MAC_ACC_WIDTH-1:0] mult_only_out3_reg;

reg [MAC_ACC_WIDTH-1:0] acc_out0;
reg [MAC_ACC_WIDTH-1:0] acc_out1;
reg [MAC_ACC_WIDTH-1:0] acc_out2;
reg [MAC_ACC_WIDTH-1:0] acc_out3;

// Pipelining multiply-only results
always @(posedge clk) begin
  mult_only_out0_reg <= mult_only_out0;
  mult_only_out1_reg <= mult_only_out1;
  mult_only_out2_reg <= mult_only_out2;
  mult_only_out3_reg <= mult_only_out3;
end

always @(*) begin
  case (cfg[MAC_CONF_WIDTH-2:0])
    `MAC_DUAL: begin
      {mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH);
      {mult_only_out3, mult_only_out2} = partial2 + (partial3 << MAC_MIN_WIDTH);
    end
    `MAC_QUAD: begin
      {mult_only_out3, mult_only_out2, mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH) + (partial2 << 2*MAC_MIN_WIDTH) + (partial3 << 3*MAC_MIN_WIDTH);
    end
    default: begin
      mult_only_out0 = partial0;
      mult_only_out1 = partial1;
      mult_only_out2 = partial2;
      mult_only_out3 = partial3;
    end
  endcase
end

// Accumulators
wire carry_0_out;
wire carry_1_in;
wire carry_1_out;
wire carry_2_in;
wire carry_2_out;
wire carry_3_in;

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc0 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(1'b0),
  .init(cfg[MAC_ACC_WIDTH*1-1:MAC_ACC_WIDTH*0+MAC_CONF_WIDTH]),
  .acc_in(mult_only_out0),
  .carry_out(carry_0_out),
  .out(acc_out0)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc1 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_1_in),
  .init(cfg[MAC_ACC_WIDTH*2-1:MAC_ACC_WIDTH*1+MAC_CONF_WIDTH]),
  .acc_in(mult_only_out1),
  .carry_out(carry_1_out),
  .out(acc_out1)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc2 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_2_in),
  .init(cfg[MAC_ACC_WIDTH*3-1:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH]),
  .acc_in(mult_only_out2),
  .carry_out(carry_2_out),
  .out(acc_out2)
);

accumulate #(
  .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
  .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
) acc3 (
  .clk(clk),
  .rst(rst),
  .en(en),
  .carry_in(carry_3_in),
  .init(cfg[MAC_ACC_WIDTH*4-1:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH]),
  .acc_in(mult_only_out3),
  .carry_out(), // Empty, will overflow
  .out(acc_out3)
);

// Assigning Carry Signals
assign carry_1_in = (cfg[MAC_CONF_WIDTH-2:0] == `MAC_SINGLE) ? 1'b0 : carry_0_out;
assign carry_2_in = (cfg[MAC_CONF_WIDTH-2:0] == `MAC_QUAD) ? carry_1_out : 1'b0;
assign carry_3_in = (cfg[MAC_CONF_WIDTH-2:0] == `MAC_SINGLE) ? 1'b0 : carry_2_out;

// Assigning outputs
assign out0 = cfg[MAC_CONF_WIDTH-1] ? acc_out0 : mult_only_out0_reg;
assign out1 = cfg[MAC_CONF_WIDTH-1] ? acc_out1 : mult_only_out1_reg;
assign out2 = cfg[MAC_CONF_WIDTH-1] ? acc_out2 : mult_only_out2_reg;
assign out3 = cfg[MAC_CONF_WIDTH-1] ? acc_out3 : mult_only_out3_reg;

endmodule
