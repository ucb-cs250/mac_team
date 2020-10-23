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
  input [`MAC_CONF_WIDTH-2:0] cfg, // Initial accumulate value + config

  output [`MAC_INT_WIDTH-1:0] C
);

wire [`MAC_MULT_WIDTH-1:0] A3B3;
wire [`MAC_MULT_WIDTH-1:0] A0B3;
wire [`MAC_MULT_WIDTH-1:0] A1B3;
wire [`MAC_MULT_WIDTH-1:0] A2B3;

reg [`MAC_INT_WIDTH-1:0] mult_only_out;

assign C = mult_only_out;

// Multiplication-only output
always @(*) begin
  case (cfg[1:0])
    `MAC_SINGLE:  mult_only_out = A3B3;  
    `MAC_DUAL:    mult_only_out = A2B3 + {A3B3, {`MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    mult_only_out = A0B3 + {A1B3, {`MAC_MIN_WIDTH{1'b0}}} + {A2B3, {2*`MAC_MIN_WIDTH{1'b0}}} + {A3B3, {3*`MAC_MIN_WIDTH{1'b0}}};
    default:      mult_only_out = 0;
  endcase
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

endmodule
