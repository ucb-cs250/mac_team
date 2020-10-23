`include "mac_const.vh"

module mac_block_3 (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] B3,
  input [`MAC_MIN_WIDTH-1:0] A0,     // Used for cross-multiply when chaining   
  input [`MAC_MIN_WIDTH-1:0] A1,    // Will solidify signals names later
  input [`MAC_MIN_WIDTH-1:0] A2,
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:0] cfg, // Initial accumulate value + config

  output [`MAC_MIN_WIDTH-1:0] A3_out, // this is somewhat redundant but I guess removes this responsibility from fabric? Could this be done in the mac_cluster instead? 
  output [`MAC_ACC_WIDTH-1:0] C
);

wire [`MAC_MULT_WIDTH-1:0] A3B3;
wire [`MAC_MULT_WIDTH-1:0] A0B3;
wire [`MAC_MULT_WIDTH-1:0] A1B3;
wire [`MAC_MULT_WIDTH-1:0] A2B3;
wire [`MAC_MULT_WIDTH-1:0] accumulate_out;

reg [`MAC_ACC_WIDTH-1:0] mult_only_out;
reg [`MAC_ACC_WIDTH-1:0] mult_only_reg_out;

// Multiplication-only output
always @(*) begin
  case (cfg[1:0])
    `MAC_SINGLE:  mult_only_out = A3B3;  
    `MAC_DUAL:    mult_only_out = A2B3 + {A3B3, {`MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    mult_only_out = A0B3 + {A1B3, {`MAC_MIN_WIDTH{1'b0}}} + {A2B3, {2*`MAC_MIN_WIDTH{1'b0}}} + {A3B3, {3*`MAC_MIN_WIDTH{1'b0}}};
    default:      mult_only_out = 0;
  endcase
end

// Pipelining the multiplication-only output
always @(posedge clk) begin 
  mult_only_reg_out <= mult_only_out;
end

// The multiply unit used for all configurations
multiply A3B3_mul_block
(
  .A(A3), 
  .B(B3), 
  .C(A3B3)
);

// The secondary mul unit used for dual configs
multiply A0B3_mul_block 
(
  .A(A0), 
  .B(B3), 
  .C(A0B3)
);

// The third and fourth mul unit used for quad configs
multiply A1B3_mul_block
(
  .A(A1), 
  .B(B3), 
  .C(A1B3)
);
multiply A2B3_mul_block
(
  .A(A2), 
  .B(B3), 
  .C(A2B3)
);

// The accumulate block
accumulate acc_block 
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:`MAC_CONF_WIDTH]), 
  .din(mult_only_out), 
  .acc(accumulate_out)
);

// Output is either just multiply or the accumulate output (last bit of the
// MAC_CONF_WIDTH). Note that the multiply only output is also pipelined to
// match accumulator
assign C = cfg[`MAC_CONF_WIDTH - 1] ? accumulate_out : mult_only_reg_out;

// Input-forward is always A input
assign A3_out =  A3;

endmodule
