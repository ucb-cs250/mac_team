`include "mac_const.vh"

module mac_combiner (
  input clk,
  input rst,
  input en,
  input [1:0] cfg,                          // Single, Dual or Quad
  input [`MAC_INT_WIDTH-1:0] partial0,      
  input [`MAC_INT_WIDTH-1:0] partial1,
  input [`MAC_INT_WIDTH-1:0] partial2,
  input [`MAC_INT_WIDTH-1:0] partial3,

  output reg [`MAC_ACC_WIDTH-1:0] out0,         // Output passed through in single mode
  output reg [`MAC_ACC_WIDTH-1:0] out1,         // Output split across one+two, three+four in dual mode
  output reg [`MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output reg [`MAC_ACC_WIDTH-1:0] out3
);

always @(*) begin
  case (cfg)
    `MAC_DUAL: begin
      {out1, out0} = partial0 + (partial1 << `MAC_MIN_WIDTH);
      {out3, out2} = partial2 + (partial3 << `MAC_MIN_WIDTH);
    end
    `MAC_QUAD: begin
      //{out3, out2, out1, out0} = partial0 + (partial1 << `MAC_MIN_WIDTH) + (partial2 << 2*`MAC_MIN_WIDTH) + (partial3 << 3*`MAC_MIN_WIDTH);
      {out3, out2, out1, out0} = partial0 + {partial1, {`MAC_MIN_WIDTH{1'b0}}} + {partial2, {2*`MAC_MIN_WIDTH{1'b0}}} + {partial3, {3*`MAC_MIN_WIDTH{1'b0}}};
    end
    default: begin
      out0 = partial0;
      out1 = partial1;
      out2 = partial2;
      out3 = partial3;
    end
  endcase
end

endmodule
