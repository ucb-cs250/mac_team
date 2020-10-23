`include "mac_const.vh"

module mac_block_0 (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] A0,
  input [`MAC_MIN_WIDTH-1:0] B0,
  input [`MAC_MIN_WIDTH-1:0] A1,     // Used for cross-multiply when chaining   
  input [`MAC_MIN_WIDTH-1:0] A2,    // Will solidify signals names later
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:0] cfg, // Initial accumulate value + config

  output [`MAC_MIN_WIDTH-1:0] A0_out, // this is somewhat redundant but I guess removes this responsibility from fabric? Could this be done in the mac_cluster instead? 
  output [`MAC_ACC_WIDTH-1:0] C
);

wire [`MAC_MULT_WIDTH-1:0] A0B0;
wire [`MAC_MULT_WIDTH-1:0] A1B0;
wire [`MAC_MULT_WIDTH-1:0] A2B0;
wire [`MAC_MULT_WIDTH-1:0] A3B0;
wire [`MAC_MULT_WIDTH-1:0] accumulate_out;

reg [`MAC_ACC_WIDTH-1:0] mult_only_out;
reg [`MAC_ACC_WIDTH-1:0] mult_only_reg_out;

// Multiplication-only output
always @(*) begin
  case (cfg[1:0])
    `MAC_SINGLE:  mult_only_out = A0B0;  
    `MAC_DUAL:    mult_only_out = A0B0 + {A1B0, {`MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    mult_only_out = A0B0 + {A1B0, {`MAC_MIN_WIDTH{1'b0}}} + {A2B0, {2*`MAC_MIN_WIDTH{1'b0}}} + {A3B0, {3*`MAC_MIN_WIDTH{1'b0}}};
    default:      mult_only_out = 0;
  endcase
end

// Pipelining the multiplication-only output
always @(posedge clk) begin 
  mult_only_reg_out <= mult_only_out;
end

// The multiply unit used for all configurations
multiply A0B0_mul_block
(
  .A(A0), 
  .B(B0), 
  .C(A0B0)
);

// The secondary mul unit used for dual configs
multiply A1B0_mul_block 
(
  .A(A1), 
  .B(B0), 
  .C(A1B0)
);

// The third and fourth mul unit used for quad configs
multiply A2B0_mul_block
(
  .A(A2), 
  .B(B0), 
  .C(A2B0)
);
multiply A3B0_mul_block
(
  .A(A3), 
  .B(B0), 
  .C(A3B0)
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
assign A0_out =  A0;

endmodule
