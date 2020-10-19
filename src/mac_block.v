`include mac_const.vh

module mac_block (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] A,
  input [`MAC_MIN_WIDTH-1:0] B,
  input [`MAC_MIN_WIDTH-1:0] dual_in,     // Used for cross-multiply when chaining   
  input [`MAC_MIN_WIDTH-1:0] quad_in1,    // Will solidify signals names later
  input [`MAC_MIN_WIDTH-1:0] quad_in2,
  input [`MAC_ACC_WIDTH + `CONF_WIDTH - 1:0] cfg, // Initial accumulate value + config

  output [`MAC_MIN_WIDTH-1:0] input_fwd, 
  output [`MAC_ACC_WIDTH-1:0] C
);

wire [`MAC_MUL_WIDTH-1:0] main_mul_out;
wire [`MAC_MUL_WIDTH-1:0] dual_mul_out;
wire [`MAC_MUL_WIDTH-1:0] quad_one_mul_out;
wire [`MAC_MUL_WIDTH-1:0] quad_two_mul_out;
wire [`MAC_MUL_WIDTH-1:0] accumulate_out;

reg [`MAC_ACC_WIDTH-1:0] mult_only_out;
reg [`MAC_ACC_WIDTH-1:0] mult_only_reg_out;

// Multiplication-only output
always @(*) begin
  case (cfg[1:0]) begin
    `MAC_SINGLE:    mult_only_out = main_mul_out;  
    `MAC_DUAL:    mult_only_out = main_mul_out + (dual_mul_out << `MAC_MIN_WIDTH);
    `MAC_QUAD:    mult_only_out = main_mul_out + (dual_mul_out << `MAC_MIN_WIDTH) + (quad_one_mul_out << 2*`MAC_MIN_WIDTH) + (quad_two_mul_out << 3*`MAC_MIN_WIDTH);
    default:  mult_only_out = 0;
  end
end

// Pipelining the multiplication-only output
always @(posedge clk) begin 
  mult_only_reg_out <= mult_only_out;
end

// The multiply unit used for all configurations
multiply main_mul 
(
  .A(A), 
  .B(B), 
  .C(main_mul_out)
);

// The secondary mul unit used for dual configs
multiply dual_mul 
(
  .A(dual_in), 
  .B(B), 
  .C(dual_mul_out)
);

// The third and fourth mul unit used for quad configs
multiply quad_one_mul 
(
  .A(quad_one_mul), 
  .B(B), 
  .C(quad_one_mul_out)
);
multiply quad_two_mul 
(
  .A(quad_two_mul), 
  .B(B), 
  .C(quad_two_mul_out)
);

// The accumulate block
accumulate acc 
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[`MAC_ACC_WIDTH + `CONF_WIDTH - 1:`CONF_WIDTH]), 
  .din(mult_only_out), 
  .acc(accumulate_out)
);

// Output is either just multiply or the accumulate output (last bit of the CONF_WIDTH)
// Note that the multiply only output is also pipelined to match accumulator
assign C = cfg[`CONF_WIDTH - 1] ? accumulate_out : mult_only_reg_out;

// Input-forward is always A input
assign input_fwd = A;

endmodule