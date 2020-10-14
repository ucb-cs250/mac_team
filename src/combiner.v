`include const.vh

module #(
  parameter MIN_WIDTH = 8
) mac_block (
  input clk,
  input rst,
  input en,
  input [1:0] cfg,                          // Single, Dual or Quad
  input [2*MIN_WIDTH-1:0] partial0,      
  input [2*MIN_WIDTH-1:0] partial1,
  input [2*MIN_WIDTH-1:0] partial2,
  input [2*MIN_WIDTH-1:0] partial3,

  output reg [2*MIN_WIDTH-1:0] out0,         // Output passed through in single mode
  output reg [2*MIN_WIDTH-1:0] out1,         // Output split across one+two, three+four in dual mode
  output reg [2*MIN_WIDTH-1:0] out2,       // Output split across all in quad mode
  output reg [2*MIN_WIDTH-1:0] out3,
);

always @(*) begin
  case (cfg)
    `DUAL:
      {out1, out0} = partial0 + (partial1 << MIN_WIDTH);
      {out3, out2} = partial3 + (partial2 << MIN_WIDTH);
    `QUAD:
      {out3, out2, out1, out0} = partial0 + (partial1 << MIN_WIDTH) + (partial2 << 2*MIN_WIDTH) + (partial3 << 3*MIN_WIDTH);
    default: begin
      out0 = partial0;
      out1 = partial1;
      out2 = partial2;
      out3 = partial3;
    end

end



endmodule