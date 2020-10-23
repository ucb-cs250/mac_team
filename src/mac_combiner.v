`include "mac_const.vh"

module mac_combiner (
  input clk,
  input rst,
  input en,
  input [4*`MAC_ACC_WIDTH+`MAC_CONF_WIDTH-1:0] cfg,
  input [`MAC_INT_WIDTH-1:0] partial0,      
  input [`MAC_INT_WIDTH-1:0] partial1,
  input [`MAC_INT_WIDTH-1:0] partial2,
  input [`MAC_INT_WIDTH-1:0] partial3,

  output [`MAC_ACC_WIDTH-1:0] out0,         // Output passed through in single mode
  output [`MAC_ACC_WIDTH-1:0] out1,         // Output split across one+two, three+four in dual mode
  output [`MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output [`MAC_ACC_WIDTH-1:0] out3
);

reg [`MAC_ACC_WIDTH-1:0] mult_out0;
reg [`MAC_ACC_WIDTH-1:0] mult_out1;
reg [`MAC_ACC_WIDTH-1:0] mult_out2;
reg [`MAC_ACC_WIDTH-1:0] mult_out3;
reg [`MAC_ACC_WIDTH-1:0] mult_only_out0;
reg [`MAC_ACC_WIDTH-1:0] mult_only_out1;
reg [`MAC_ACC_WIDTH-1:0] mult_only_out2;
reg [`MAC_ACC_WIDTH-1:0] mult_only_out3;
wire [`MAC_ACC_WIDTH-1:0] acc_out0;
wire [`MAC_ACC_WIDTH-1:0] acc_out1;
wire [`MAC_ACC_WIDTH-1:0] acc_out2;
wire [`MAC_ACC_WIDTH-1:0] acc_out3;

always @(*) begin
  case (cfg[`MAC_CONF_WIDTH-2:0])
    `MAC_DUAL: begin
      // TODO: optimize this to account for the fact there there are some non-overlapping bits
      {mult_out1, mult_out0} = partial0 + {partial1, {`MAC_MIN_WIDTH{1'b0}}};
      {mult_out3, mult_out2} = partial2 + {partial3, {`MAC_MIN_WIDTH{1'b0}}};
    end
    `MAC_QUAD: begin
      // TODO: optimize this to account for the fact there there are some non-overlapping bits
      {mult_out3, mult_out2, mult_out1, mult_out0} = partial0 + {partial1, {`MAC_MIN_WIDTH{1'b0}}} + {partial2, {2*`MAC_MIN_WIDTH{1'b0}}} + {partial3, {3*`MAC_MIN_WIDTH{1'b0}}};
    end
    default: begin
      mult_out0 = partial0;
      mult_out1 = partial1;
      mult_out2 = partial2;
      mult_out3 = partial3;
    end
  endcase
end

// The accumulate block
accumulate acc_block0
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH+`MAC_CONF_WIDTH-1:`MAC_CONF_WIDTH]), 
  .din(mult_out0), 
  .acc(acc_out0)
);

// The accumulate block
accumulate acc_block1
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH*2-1:`MAC_ACC_WIDTH+`MAC_CONF_WIDTH]), 
  .din(mult_out1), 
  .acc(acc_out1)
);

// The accumulate block
accumulate acc_block2
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH*3-1:`MAC_ACC_WIDTH*2+`MAC_CONF_WIDTH]), 
  .din(mult_out2), 
  .acc(acc_out2)
);

// The accumulate block
accumulate acc_block3
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH*4-1:`MAC_ACC_WIDTH*3+`MAC_CONF_WIDTH]), 
  .din(mult_out3), 
  .acc(acc_out3)
);

always @(posedge clk) begin
  mult_only_out0 <= mult_out0;
  mult_only_out1 <= mult_out1;
  mult_only_out2 <= mult_out2;
  mult_only_out3 <= mult_out3;
end

assign out0 = cfg[`MAC_CONF_WIDTH-1] ? acc_out0 : mult_only_out0;
assign out1 = cfg[`MAC_CONF_WIDTH-1] ? acc_out1 : mult_only_out1;
assign out2 = cfg[`MAC_CONF_WIDTH-1] ? acc_out2 : mult_only_out2;
assign out3 = cfg[`MAC_CONF_WIDTH-1] ? acc_out3 : mult_only_out3;

endmodule
