`timescale 1ns / 1ps
`include "mac_const.vh"

module macTestHarness #(
  parameter MAC_CONF_WIDTH=4,
  parameter MAC_MIN_WIDTH=8,
  parameter MAC_ACC_WIDTH=4*MAC_MIN_WIDTH
)(
  input clk,
  input reset,
  input cset
);

  //reg [31:0] seed;
  //initial seed = $get_initial_random_seed();

  //-----------------------------------------------

  reg [MAC_MIN_WIDTH-1:0] A0;
  reg [MAC_MIN_WIDTH-1:0] B0;
  reg [MAC_MIN_WIDTH-1:0] A1;
  reg [MAC_MIN_WIDTH-1:0] B1;
  reg [MAC_MIN_WIDTH-1:0] A2;
  reg [MAC_MIN_WIDTH-1:0] B2;
  reg [MAC_MIN_WIDTH-1:0] A3;
  reg [MAC_MIN_WIDTH-1:0] B3;

  reg [MAC_CONF_WIDTH-1:0] cfg_reg = 0;
  reg [MAC_ACC_WIDTH-1:0] initial0_reg = 0;
  reg [MAC_ACC_WIDTH-1:0] initial1_reg = 0;
  reg [MAC_ACC_WIDTH-1:0] initial2_reg = 0;
  reg [MAC_ACC_WIDTH-1:0] initial3_reg = 0;

  wire [4*MAC_ACC_WIDTH + MAC_CONF_WIDTH - 1:0] cfg = {initial3_reg, initial2_reg, initial1_reg, initial0_reg, cfg_reg}; 
  wire [MAC_ACC_WIDTH-1:0] out0;
  wire [MAC_ACC_WIDTH-1:0] out1;
  wire [MAC_ACC_WIDTH-1:0] out2;
  wire [MAC_ACC_WIDTH-1:0] out3;

  //-----------------------------------------------
  // Instantiate the dut

  mac_cluster #(
    .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
    .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
    .MAC_MULT_WIDTH(2*MAC_MIN_WIDTH),
    .MAC_ACC_WIDTH(MAC_ACC_WIDTH),
    .MAC_INT_WIDTH(5*MAC_MIN_WIDTH)
  ) dut (
      .clk(clk),
      .rst(reset),
      .cset(cset),
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
  // Golden Model

  reg [MAC_MIN_WIDTH-1:0] pipelined0_A0;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_A1;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_A2;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_A3;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_B0;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_B1;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_B2;
  reg [MAC_MIN_WIDTH-1:0] pipelined0_B3;

  reg [MAC_MIN_WIDTH-1:0] pipelined1_A0;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_A1;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_A2;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_A3;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_B0;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_B1;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_B2;
  reg [MAC_MIN_WIDTH-1:0] pipelined1_B3;

  always @(posedge clk) begin
    if (reset | cset) begin
      pipelined0_A0 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_A1 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_A2 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_A3 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_B0 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_B1 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_B2 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined0_B3 <= {MAC_MIN_WIDTH{1'b0}};

      pipelined1_A0 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_A1 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_A2 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_A3 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_B0 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_B1 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_B2 <= {MAC_MIN_WIDTH{1'b0}};
      pipelined1_B3 <= {MAC_MIN_WIDTH{1'b0}};
    end else begin
      pipelined0_A0 <= A0;
      pipelined0_A1 <= A1;
      pipelined0_A2 <= A2;
      pipelined0_A3 <= A3;
      pipelined0_B0 <= B0;
      pipelined0_B1 <= B1;
      pipelined0_B2 <= B2;
      pipelined0_B3 <= B3;

      pipelined1_A0 <= pipelined0_A0;
      pipelined1_A1 <= pipelined0_A1;
      pipelined1_A2 <= pipelined0_A2;
      pipelined1_A3 <= pipelined0_A3;
      pipelined1_B0 <= pipelined0_B0;
      pipelined1_B1 <= pipelined0_B1;
      pipelined1_B2 <= pipelined0_B2;
      pipelined1_B3 <= pipelined0_B3;
    end
  end


  reg [MAC_ACC_WIDTH-1:0] golden_out0;
  reg [MAC_ACC_WIDTH-1:0] golden_out1;
  reg [MAC_ACC_WIDTH-1:0] golden_out2;
  reg [MAC_ACC_WIDTH-1:0] golden_out3;

  always @(posedge clk) begin
    if (reset) begin
      golden_out0 <= {MAC_ACC_WIDTH{1'b0}};
      golden_out1 <= {MAC_ACC_WIDTH{1'b0}};
      golden_out2 <= {MAC_ACC_WIDTH{1'b0}};
      golden_out3 <= {MAC_ACC_WIDTH{1'b0}};
    end else if (cset) begin
      golden_out0 <= cfg[MAC_ACC_WIDTH+MAC_CONF_WIDTH-1:MAC_CONF_WIDTH];
      golden_out1 <= cfg[MAC_ACC_WIDTH*2+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH+MAC_CONF_WIDTH];
      golden_out2 <= cfg[MAC_ACC_WIDTH*3+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH];
      golden_out3 <= cfg[MAC_ACC_WIDTH*4+MAC_CONF_WIDTH-1:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH];
    end else begin
      case (cfg[1:0])
        `MAC_SINGLE: begin
          if (cfg[2]) begin // Accumulate
            if (cfg[3]) begin // Signed
              golden_out0 <= ($signed(pipelined1_A0) * $signed(pipelined1_B0)) + $signed(golden_out0);
              golden_out1 <= ($signed(pipelined1_A1) * $signed(pipelined1_B1)) + $signed(golden_out1);
              golden_out2 <= ($signed(pipelined1_A2) * $signed(pipelined1_B2)) + $signed(golden_out2);
              golden_out3 <= ($signed(pipelined1_A3) * $signed(pipelined1_B3)) + $signed(golden_out3);
            end else begin
              golden_out0 <= (pipelined1_A0 * pipelined1_B0) + golden_out0;
              golden_out1 <= (pipelined1_A1 * pipelined1_B1) + golden_out1;
              golden_out2 <= (pipelined1_A2 * pipelined1_B2) + golden_out2;
              golden_out3 <= (pipelined1_A3 * pipelined1_B3) + golden_out3;
            end
          end else begin
            if (cfg[3]) begin // Signed
              golden_out0 <= $signed(pipelined1_A0) * $signed(pipelined1_B0);
              golden_out1 <= $signed(pipelined1_A1) * $signed(pipelined1_B1);
              golden_out2 <= $signed(pipelined1_A2) * $signed(pipelined1_B2);
              golden_out3 <= $signed(pipelined1_A3) * $signed(pipelined1_B3);
            end else begin
              golden_out0 <= pipelined1_A0 * pipelined1_B0;
              golden_out1 <= pipelined1_A1 * pipelined1_B1;
              golden_out2 <= pipelined1_A2 * pipelined1_B2;
              golden_out3 <= pipelined1_A3 * pipelined1_B3;
            end
          end
        end
        `MAC_DUAL: begin
          if (cfg[2]) begin // Accumulate
            if (cfg[3]) begin // Signed
              {golden_out1, golden_out0} <= ($signed({pipelined1_A1, pipelined1_A0}) * $signed({pipelined1_B1, pipelined1_B0})) + $signed({golden_out1, golden_out0});
              {golden_out3, golden_out2} <= ($signed({pipelined1_A3, pipelined1_A2}) * $signed({pipelined1_B3, pipelined1_B2})) + $signed({golden_out3, golden_out2});
            end else begin
              {golden_out1, golden_out0} <= ({pipelined1_A1, pipelined1_A0} * {pipelined1_B1, pipelined1_B0}) + {golden_out1, golden_out0};
              {golden_out3, golden_out2} <= ({pipelined1_A3, pipelined1_A2} * {pipelined1_B3, pipelined1_B2}) + {golden_out3, golden_out2};
            end
          end else begin
            if (cfg[3]) begin // Signed 
              {golden_out1, golden_out0} <= $signed({pipelined1_A1, pipelined1_A0}) * $signed({pipelined1_B1, pipelined1_B0});
              {golden_out3, golden_out2} <= $signed({pipelined1_A3, pipelined1_A2}) * $signed({pipelined1_B3, pipelined1_B2});
            end else begin
              {golden_out1, golden_out0} <= {pipelined1_A1, pipelined1_A0} * {pipelined1_B1, pipelined1_B0};
              {golden_out3, golden_out2} <= {pipelined1_A3, pipelined1_A2} * {pipelined1_B3, pipelined1_B2};
            end
          end
        end
        `MAC_QUAD: begin
          if (cfg[2]) begin // Accumulate
            if (cfg[3]) begin // Signed
              {golden_out3, golden_out2, golden_out1, golden_out0} <= ($signed({pipelined1_A3, pipelined1_A2, pipelined1_A1, pipelined1_A0}) * $signed({pipelined1_B3, pipelined1_B2, pipelined1_B1, pipelined1_B0})) + $signed({golden_out3, golden_out2, golden_out1, golden_out0});
            end else begin
              {golden_out3, golden_out2, golden_out1, golden_out0} <= ({pipelined1_A3, pipelined1_A2, pipelined1_A1, pipelined1_A0} * {pipelined1_B3, pipelined1_B2, pipelined1_B1, pipelined1_B0}) + {golden_out3, golden_out2, golden_out1, golden_out0};
            end
          end else begin
            if (cfg[3]) begin // Signed
              {golden_out3, golden_out2, golden_out1, golden_out0} <= $signed({pipelined1_A3, pipelined1_A2, pipelined1_A1, pipelined1_A0}) * $signed({pipelined1_B3, pipelined1_B2, pipelined1_B1, pipelined1_B0});
            end else begin
              {golden_out3, golden_out2, golden_out1, golden_out0} <= {pipelined1_A3, pipelined1_A2, pipelined1_A1, pipelined1_A0} * {pipelined1_B3, pipelined1_B2, pipelined1_B1, pipelined1_B0};
            end
          end
        end
      endcase
    end
  end

  //-----------------------------------------------
  // Initialization
  reg [31:0] test = 1;
  reg [31:0] num_tests = 10;
  reg verbose = 0;

  initial begin
    $value$plusargs("cfg=%d", cfg_reg);
    $value$plusargs("initial0=%d", initial0_reg);
    $value$plusargs("initial1=%d", initial1_reg);
    $value$plusargs("initial2=%d", initial2_reg);
    $value$plusargs("initial3=%d", initial3_reg);
    $value$plusargs("num_tests=%d", num_tests);
    $value$plusargs("verbose=%d", verbose);
  end

  //-----------------------------------------------
  // Start the simulation

  always @(posedge clk) begin
    if (~reset & ~cset) begin
      A0 <= $urandom;
      A1 <= $urandom;
      A2 <= $urandom;
      A3 <= $urandom;
      B0 <= $urandom;
      B1 <= $urandom;
      B2 <= $urandom;
      B3 <= $urandom;

      if (verbose) begin
        $display("---");
        $display("A0: %d A1: %d A2: %d A3: %d", A0, A1, A2, A3);
        $display("B0: %d B1: %d B2: %d B3: %d", B0, B1, B2, B3);
      end

      if (out0 != golden_out0 || out1 != golden_out1 || out2 != golden_out2 || out3 != golden_out3 ) begin
        $display("FAILED: On test %0d of %0d", test, num_tests);
        $display("With cfg: %3b", cfg[MAC_CONF_WIDTH-1:0]);
        $display("Initial 0: %0d, Initial 1: %0d, Initial 2: %0d, Initial 3: %0d", 
          cfg[MAC_ACC_WIDTH+MAC_CONF_WIDTH-1:MAC_CONF_WIDTH], 
          cfg[MAC_ACC_WIDTH*2-1:MAC_ACC_WIDTH+MAC_CONF_WIDTH], 
          cfg[MAC_ACC_WIDTH*3-1:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH],
          cfg[MAC_ACC_WIDTH*4-1:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH]);
        $display("out0: Got %0d, Expected %0d", out0, golden_out0);
        $display("out1: Got %0d, Expected %0d", out1, golden_out1);
        $display("out2: Got %0d, Expected %0d", out2, golden_out2);
        $display("out3: Got %0d, Expected %0d", out3, golden_out3);
        $finish; 
      end
    end
  end

  //-----------------------------------------------
  // Count cycles 
  always @(posedge clk) begin
    if (~reset & ~cset) begin
      if (test > num_tests) begin
        $display("PASSED: %0d tests", num_tests);
        $display("With cfg: %4b", cfg[MAC_CONF_WIDTH-1:0]);
        $display("Initial 0: %0d, Initial 1: %0d, Initial 2: %0d, Initial 3: %0d", 
          cfg[MAC_ACC_WIDTH+MAC_CONF_WIDTH-1:MAC_CONF_WIDTH], 
          cfg[MAC_ACC_WIDTH*2-1:MAC_ACC_WIDTH+MAC_CONF_WIDTH], 
          cfg[MAC_ACC_WIDTH*3-1:MAC_ACC_WIDTH*2+MAC_CONF_WIDTH],
          cfg[MAC_ACC_WIDTH*4-1:MAC_ACC_WIDTH*3+MAC_CONF_WIDTH]);
        $finish;
      end else begin
        test <= test + 1;
      end
    end else begin
      test <= test;
    end
  end

endmodule