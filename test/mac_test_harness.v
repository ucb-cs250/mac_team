// Test harness for EECS151 RISC-V Processor
`include "mac_const.vh"

module macTestHarness(
  input clk,
  input reset
);

  //reg [31:0] seed;
  //initial seed = $get_initial_random_seed();

  //-----------------------------------------------
  // Setup clocking and reset
  reg r_reset;
  reg start = 0;

  reg [`MAC_MIN_WIDTH-1:0] A0;
  reg [`MAC_MIN_WIDTH-1:0] B0;
  reg [`MAC_MIN_WIDTH-1:0] A1;
  reg [`MAC_MIN_WIDTH-1:0] B1;
  reg [`MAC_MIN_WIDTH-1:0] A2;
  reg [`MAC_MIN_WIDTH-1:0] B2;
  reg [`MAC_MIN_WIDTH-1:0] A3;
  reg [`MAC_MIN_WIDTH-1:0] B3;
  reg [4*`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:0] cfg;

  wire [`MAC_ACC_WIDTH-1:0] out0;
  wire [`MAC_ACC_WIDTH-1:0] out1;
  wire [`MAC_ACC_WIDTH-1:0] out2;
  wire [`MAC_ACC_WIDTH-1:0] out3;

  //-----------------------------------------------
  // Instantiate the dut

  mac_cluster dut
    (
      .clk(clk),
      .rst(r_reset),
      .en(1'b1),
      .A0(A0),
      .B0(B0),
      .A1(A1),
      .B1(B1),
      .A2(A2),
      .B2(B2),
      .A3(A3),
      .B3(B3),
      .cfg(cfg),
      .out0(out0),
      .out1(out1),
      .out2(out2),
      .out3(out3)
    );

  
  //-----------------------------------------------
  // Memory interface

  always @(negedge clk)
  begin
    r_reset <= reset;
  end

  //-----------------------------------------------
  // Golden Model
  reg [`MAC_ACC_WIDTH-1:0] golden_out0;
  reg [`MAC_ACC_WIDTH-1:0] golden_out1;
  reg [`MAC_ACC_WIDTH-1:0] golden_out2;
  reg [`MAC_ACC_WIDTH-1:0] golden_out3;

  reg [`MAC_ACC_WIDTH-1:0] pipelined_golden_out0;
  reg [`MAC_ACC_WIDTH-1:0] pipelined_golden_out1;
  reg [`MAC_ACC_WIDTH-1:0] pipelined_golden_out2;
  reg [`MAC_ACC_WIDTH-1:0] pipelined_golden_out3;

  always @(posedge clk) begin
    case (cfg[`MAC_CONF_WIDTH - 2:0])
      `MAC_SINGLE: begin
        if (cfg[`MAC_CONF_WIDTH - 1]) begin // Accumulate
          golden_out0 <= (A0 * B0) + golden_out0;
          golden_out1 <= (A1 * B1) + golden_out1;
          golden_out2 <= (A2 * B2) + golden_out2;
          golden_out3 <= (A3 * B3) + golden_out3;
        end else begin
          golden_out0 <= A0 * B0;
          golden_out1 <= A1 * B1;
          golden_out2 <= A2 * B2;
          golden_out3 <= A3 * B3;
        end
      end
      `MAC_DUAL: begin
        if (cfg[`MAC_CONF_WIDTH - 1]) begin // Accumulate
          {golden_out1, golden_out0} <= ({A1, A0} * {B1, B0}) + {golden_out1, golden_out0};
          {golden_out3, golden_out2} <= ({A3, A2} * {B3, B2}) + {golden_out3, golden_out2};
        end else begin
          {golden_out1, golden_out0} <= {A1, A0} * {B1, B0};
          {golden_out3, golden_out2} <= {A3, A2} * {B3, B2};
        end
      end
      `MAC_QUAD: begin
        if (cfg[`MAC_CONF_WIDTH - 1]) begin // Accumulate
          {golden_out3, golden_out2, golden_out1, golden_out0} <= {A3, A2, A1, A0} * {B3, B2, B1, B0} + {golden_out3, golden_out2, golden_out1, golden_out0};
        end else begin
          {golden_out3, golden_out2, golden_out1, golden_out0} <= ({A3, A2, A1, A0} * {B3, B2, B1, B0});
        end
      end
    endcase
  end

  always @(posedge clk) begin
    pipelined_golden_out0 <= golden_out0;
    pipelined_golden_out1 <= golden_out1;
    pipelined_golden_out2 <= golden_out2;
    pipelined_golden_out3 <= golden_out3;
  end

  //-----------------------------------------------
  // Initialization
  initial begin
    cfg = 0;
    golden_out0 = 0;
    golden_out1 = 0;
    golden_out2 = 0;
    golden_out3 = 0;
  end

  //-----------------------------------------------
  // Start the simulation
  reg [31:0] test = 1;
  reg [31:0] num_tests = 10;
  reg [31:0] curr_cfg = 0;
  reg [31:0] num_cfgs = 6;

  always @(posedge clk) begin
    A0 = $urandom;
    A1 = $urandom;
    A2 = $urandom;
    A3 = $urandom;
    B0 = $urandom;
    B1 = $urandom;
    B2 = $urandom;
    B3 = $urandom;

    if (out0 != pipelined_golden_out0 || out1 != pipelined_golden_out1 || out2 != pipelined_golden_out2 || out3 != pipelined_golden_out3 ) begin
      $display("FAILED: On test %0d of %0d for cfg: %3b", test, num_tests, cfg[`MAC_CONF_WIDTH-1:0]);
      $display("out0: Got %0d, expected %0d", out0, pipelined_golden_out0);
      $display("out1: Got %0d, expected %0d", out1, pipelined_golden_out1);
      $display("out2: Got %0d, expected %0d", out2, pipelined_golden_out2);
      $display("out3: Got %0d, expected %0d", out3, pipelined_golden_out3);
      $finish; 
    end
  end

  //-----------------------------------------------
  // Count cycles 
  always @(posedge clk) begin
    if (test > num_tests) begin
      $display("PASSED: cfg %3b", cfg[`MAC_CONF_WIDTH-1:0]);
      test = 1;
      curr_cfg = curr_cfg + 1;
      cfg = (cfg & ~{`MAC_CONF_WIDTH{1'b1}}) | (curr_cfg < `MAC_CONF_WIDTH ? 1'b0 : 1'b1) << (`MAC_CONF_WIDTH-1) | curr_cfg % `MAC_CONF_WIDTH; //clear lower bits and set next cfg
    end else begin
      test = test + 1;
      curr_cfg = curr_cfg;
      cfg = cfg;
    end

    if (curr_cfg == num_cfgs) begin
      $display("PASSED ALL CFGS");
      $finish;
    end
  end

endmodule