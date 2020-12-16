`timescale 1ns / 1ps
`include "mac_const.vh"

module mac_golden_model #(
  parameter MAC_CONF_WIDTH=4,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH
)(
  input clk,
  input reset,
  input cset,
  input [4*MAC_ACC_WIDTH+MAC_CONF_WIDTH-1:0] cfg,
  input [MAC_MIN_WIDTH-1:0] A0,
  input [MAC_MIN_WIDTH-1:0] A1,
  input [MAC_MIN_WIDTH-1:0] A2,
  input [MAC_MIN_WIDTH-1:0] A3,
  input [MAC_MIN_WIDTH-1:0] B0,
  input [MAC_MIN_WIDTH-1:0] B1,
  input [MAC_MIN_WIDTH-1:0] B2,
  input [MAC_MIN_WIDTH-1:0] B3,
  output reg [MAC_ACC_WIDTH-1:0] out0,
  output reg [MAC_ACC_WIDTH-1:0] out1,
  output reg [MAC_ACC_WIDTH-1:0] out2,
  output reg [MAC_ACC_WIDTH-1:0] out3
);

always @(posedge clk) begin
if (reset) begin
  out0 <= {MAC_ACC_WIDTH{1'b0}};
  out1 <= {MAC_ACC_WIDTH{1'b0}};
  out2 <= {MAC_ACC_WIDTH{1'b0}};
  out3 <= {MAC_ACC_WIDTH{1'b0}};
end else if (cset) begin
  out0 <= cfg[MAC_ACC_WIDTH+MAC_CONF_WIDTH-1:MAC_CONF_WIDTH];
  out1 <= cfg[MAC_ACC_WIDTH*2+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH+MAC_CONF_WIDTH];
  out2 <= cfg[MAC_ACC_WIDTH*3+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH];
  out3 <= cfg[MAC_ACC_WIDTH*4+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH];
end else begin
  case (cfg[1:0])
    `MAC_SINGLE: begin
      if (cfg[2]) begin // Accumulate
        if (cfg[3]) begin // Signed
          out0 <= ($signed(A0) * $signed(B0)) + $signed(out0);
          out1 <= ($signed(A1) * $signed(B1)) + $signed(out1);
          out2 <= ($signed(A2) * $signed(B2)) + $signed(out2);
          out3 <= ($signed(A3) * $signed(B3)) + $signed(out3);
        end else begin
          out0 <= (A0 * B0) + out0;
          out1 <= (A1 * B1) + out1;
          out2 <= (A2 * B2) + out2;
          out3 <= (A3 * B3) + out3;
        end
      end else begin
        if (cfg[3]) begin // Signed
          out0 <= $signed(A0) * $signed(B0);
          out1 <= $signed(A1) * $signed(B1);
          out2 <= $signed(A2) * $signed(B2);
          out3 <= $signed(A3) * $signed(B3);
        end else begin
          out0 <= A0 * B0;
          out1 <= A1 * B1;
          out2 <= A2 * B2;
          out3 <= A3 * B3;
        end
      end
    end
    `MAC_DUAL: begin
      if (cfg[2]) begin // Accumulate
        if (cfg[3]) begin // Signed
          {out1, out0} <= ($signed({A1, A0}) * $signed({B1, B0})) + $signed({out1, out0});
          {out3, out2} <= ($signed({A3, A2}) * $signed({B3, B2})) + $signed({out3, out2});
        end else begin
          {out1, out0} <= ({A1, A0} * {B1, B0}) + {out1, out0};
          {out3, out2} <= ({A3, A2} * {B3, B2}) + {out3, out2};
        end
      end else begin
        if (cfg[3]) begin // Signed 
          {out1, out0} <= $signed({A1, A0}) * $signed({B1, B0});
          {out3, out2} <= $signed({A3, A2}) * $signed({B3, B2});
        end else begin
          {out1, out0} <= {A1, A0} * {B1, B0};
          {out3, out2} <= {A3, A2} * {B3, B2};
        end
      end
    end
    `MAC_QUAD: begin
      if (cfg[2]) begin // Accumulate
        if (cfg[3]) begin // Signed
          {out3, out2, out1, out0} <= ($signed({A3, A2, A1, A0}) * $signed({B3, B2, B1, B0})) + $signed({out3, out2, out1, out0});
        end else begin
          {out3, out2, out1, out0} <= ({A3, A2, A1, A0} * {B3, B2, B1, B0}) + {out3, out2, out1, out0};
        end
      end else begin
        if (cfg[3]) begin // Signed
          {out3, out2, out1, out0} <= $signed({A3, A2, A1, A0}) * $signed({B3, B2, B1, B0});
        end else begin
          {out3, out2, out1, out0} <= {A3, A2, A1, A0} * {B3, B2, B1, B0};
        end
      end
    end
  endcase
end
end

endmodule 