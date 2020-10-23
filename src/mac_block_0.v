`include "mac_const.vh"

module mac_block_0 (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] B0,
  input [`MAC_MIN_WIDTH-1:0] A0,
  input [`MAC_MIN_WIDTH-1:0] A1,     // Used for cross-multiply when chaining   
  input [`MAC_MIN_WIDTH-1:0] A2,    // Will solidify signals names later
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_CONF_WIDTH-2:0] cfg, // Initial accumulate value + config

  output [`MAC_INT_WIDTH-1:0] C
);

wire [`MAC_MULT_WIDTH-1:0] A0B0;
wire [`MAC_MULT_WIDTH-1:0] A1B0;
wire [`MAC_MULT_WIDTH-1:0] A2B0;
wire [`MAC_MULT_WIDTH-1:0] A3B0;

reg [`MAC_INT_WIDTH-1:0] mult_only_out;

assign C = mult_only_out;

// Multiplication-only output
always @(*) begin
  case (cfg[`MAC_CONF_WIDTH-2:0])
    `MAC_SINGLE:  mult_only_out = A0B0;  
    `MAC_DUAL:    mult_only_out = A0B0 + {A1B0, {`MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    mult_only_out = A0B0 + {A1B0, {`MAC_MIN_WIDTH{1'b0}}} + {A2B0, {2*`MAC_MIN_WIDTH{1'b0}}} + {A3B0, {3*`MAC_MIN_WIDTH{1'b0}}};
    default:      mult_only_out = 0;
  endcase
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

endmodule
