`include const.vh

module #(
  parameter MIN_WIDTH = 8,
  parameter MUL_WIDTH = 2*MIN_WIDTH,
  parameter ACC_WIDTH = 2*MUL_WIDTH,
  parameter CONF_WIDTH = 3  // 1 bit for mac or mul, 2 bits for Single, Dual, or Quad
) mac_block (
  input clk,
  input rst,
  input en,
  input [MIN_WIDTH-1:0] A,
  input [MIN_WIDTH-1:0] B,
  input [MIN_WIDTH-1:0] dual_in,     // Used for cross-multiply when chaining   
  input [MIN_WIDTH-1:0] quad_in1,    // Will solidify signals names later
  input [MIN_WIDTH-1:0] quad_in2,
  input [ACC_WIDTH + CONF_WIDTH - 1:0] cfg, // Initial accumulate value + config

  output [MIN_WIDTH-1:0] input_fwd, 
  output [ACC_WIDTH-1:0] C
);

wire [MUL_WIDTH-1:0] main_mul_out;
wire [MUL_WIDTH-1:0] dual_mul_out;
wire [MUL_WIDTH-1:0] quad_one_mul_out;
wire [MUL_WIDTH-1:0] quad_two_mul_out;
wire [ACC_WIDTH-1:0] mult_only_out;
wire [ACC_WIDTH-1:0] accumulate_out;

reg [ACC_WIDTH-1:0] mult_only_reg_out;

// Multiplication-only output
case (cfg[1:0]) begin
  2'b00:    mult_only_out = main_mul_out;  
  2'b01:    mult_only_out = main_mul_out + (dual_mul_out << MIN_WIDTH);
  2'b10:    mult_only_out = main_mul_out + (dual_mul_out << MIN_WIDTH) + (quad_one_mul_out << 2*MIN_WIDTH) + (quad_two_mul_out << 3*MIN_WIDTH);
  default:  mult_only_out = 0;
end

// Pipelining the multiplication-only output
always @(posedge clk) begin 
  mult_only_reg_out <= mult_only_out;
end

// The multiply unit used for all configurations
multiply #(.MIN_WIDTH(MIN_WIDTH)) main_mul 
(
  .A(A), 
  .B(B), 
  .C(main_mul_out)
);

// The secondary mul unit used for dual configs
multiply #(.MIN_WIDTH(MIN_WIDTH)) dual_mul 
(
  .A(dual_in), 
  .B(B), 
  .C(dual_mul_out)
);

// The third and fourth mul unit used for quad configs
multiply #(.MIN_WIDTH(MIN_WIDTH)) quad_one_mul 
(
  .A(quad_one_mul), 
  .B(B), 
  .C(quad_one_mul_out)
);
multiply #(.MIN_WIDTH(MIN_WIDTH)) quad_two_mul 
(
  .A(quad_two_mul), 
  .B(B), 
  .C(quad_two_mul_out)
);

// The accumulate block
accumulate #(.MIN_WIDTH(MIN_WIDTH)) acc 
(
  .clk(clk), 
  .reset(reset), 
  .en(en), 
  .init_val(cfg[ACC_WIDTH + CONF_WIDTH - 1:CONF_WIDTH]), 
  .din(mult_only_out), 
  .acc(accumulate_out)
);


// Output is either just multiply or the accumulate output (last bit of the CONF_WIDTH)
// Note that the multiply only output is also pipelined to match accumulator
assign C = cfg[CONF_WIDTH - 1] ? accumulate_out : mult_only_reg_out;

// Input-forward is always A input
assign input_fwd = A;s

endmodule