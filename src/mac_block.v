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
  input carry_in,
  input [MIN_WIDTH-1:0] A,
  input [MIN_WIDTH-1:0] B,
  input [MIN_WIDTH-1:0] dual_in,     // Used for cross-multiply when chaining   
  input [MIN_WIDTH-1:0] quad_in1,    // Will solidify signals names later
  input [MIN_WIDTH-1:0] quad_in2,
  input [ACC_WIDTH + CONF_WIDTH - 1:0] cfg, // Initial accumulate value + config

  output carry_out,
  output [MIN_WIDTH-1:0] dual_out, 
  output [MIN_WIDTH-1:0] quad_out, 
  output [ACC_WIDTH-1:0] C
);

// Could either have a separate control block

// The multiply unit used for all configurations
multiply #() main_mul ();

// The secondary mul unit used for dual configs
multiply #() dual_mul ();

// The third and fourth mul unit used for quad configs
multiply #() quad_one_mul ();
multiply #() quad_two_mul ();

// The accumulate block
accumulate #() acc ();

endmodule