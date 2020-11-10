`include "mac_const.vh"

module mac_combiner_block #(
  parameter MAC_CONF_WIDTH=3,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH,
  parameter MAC_INT_WIDTH=5*MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config
)(
  input clk,
  input rst,
  input en,
  input [MAC_CONF_WIDTH - 1:0] cfg, // 4 * MAC_ACC_WIDTH initial register values + MAC_CONF_WIDTH config bits
  input [MAC_INT_WIDTH-1:0] partial0,      
  input [MAC_INT_WIDTH-1:0] partial1,
  input [MAC_INT_WIDTH-1:0] partial2,
  input [MAC_INT_WIDTH-1:0] partial3,

  output [MAC_ACC_WIDTH-1:0] out0,       // Output passed through in single mode
  output [MAC_ACC_WIDTH-1:0] out1,       // Output split across one+two, three+four in dual mode
  output [MAC_ACC_WIDTH-1:0] out2,       // Output split across all in quad mode
  output [MAC_ACC_WIDTH-1:0] out3
);

reg [MAC_ACC_WIDTH-1:0] mult_only_out0;  
reg [MAC_ACC_WIDTH-1:0] mult_only_out1;
reg [MAC_ACC_WIDTH-1:0] mult_only_out2;
reg [MAC_ACC_WIDTH-1:0] mult_only_out3;


always @(*) begin
  case (cfg[1:0])
    `MAC_DUAL: begin
      {mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH);
      {mult_only_out3, mult_only_out2} = partial2 + (partial3 << MAC_MIN_WIDTH);
    end
    `MAC_QUAD: begin
      {mult_only_out3, mult_only_out2, mult_only_out1, mult_only_out0} = partial0 + (partial1 << MAC_MIN_WIDTH) + (partial2 << 2*MAC_MIN_WIDTH) + (partial3 << 3*MAC_MIN_WIDTH);
    end
    default: begin
      mult_only_out0 = partial0;
      mult_only_out1 = partial1;
      mult_only_out2 = partial2;
      mult_only_out3 = partial3;
    end
  endcase
end


// Assigning outputs
assign out0 = mult_only_out0;
assign out1 = mult_only_out1;
assign out2 = mult_only_out2;
assign out3 = mult_only_out3;

endmodule
