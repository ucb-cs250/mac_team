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

  reg [2:0] edgecase = 0;

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
      .cfg(cfg),
      .A0(A0),
      .B0(B0),
      .A1(A1),
      .B1(B1),
      .A2(A2),
      .B2(B2),
      .A3(A3),
      .B3(B3),
      .out0(out0),
      .out1(out1),
      .out2(out2),
      .out3(out3)
    );

  //-----------------------------------------------
  // Golden Model
  wire [MAC_MIN_WIDTH-1:0] pipelined_A0;
  wire [MAC_MIN_WIDTH-1:0] pipelined_A1;
  wire [MAC_MIN_WIDTH-1:0] pipelined_A2;
  wire [MAC_MIN_WIDTH-1:0] pipelined_A3;
  wire [MAC_MIN_WIDTH-1:0] pipelined_B0;
  wire [MAC_MIN_WIDTH-1:0] pipelined_B1;
  wire [MAC_MIN_WIDTH-1:0] pipelined_B2;
  wire [MAC_MIN_WIDTH-1:0] pipelined_B3;

  mac_golden_delay #(
    .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
    .DELAY(2)
  ) golden_delay (
    .clk(clk),
    .A0_in(A0),
    .A1_in(A1),
    .A2_in(A2),
    .A3_in(A3),
    .B0_in(B0),
    .B1_in(B1),
    .B2_in(B2),
    .B3_in(B3),
    .A0_out(pipelined_A0),
    .A1_out(pipelined_A1),
    .A2_out(pipelined_A2),
    .A3_out(pipelined_A3),
    .B0_out(pipelined_B0),
    .B1_out(pipelined_B1),
    .B2_out(pipelined_B2),
    .B3_out(pipelined_B3)
  );

  wire [MAC_ACC_WIDTH-1:0] golden_out0;
  wire [MAC_ACC_WIDTH-1:0] golden_out1;
  wire [MAC_ACC_WIDTH-1:0] golden_out2;
  wire [MAC_ACC_WIDTH-1:0] golden_out3;

  mac_golden_model #(
    .MAC_CONF_WIDTH(MAC_CONF_WIDTH),
    .MAC_MIN_WIDTH(MAC_MIN_WIDTH),
    .MAC_ACC_WIDTH(MAC_ACC_WIDTH)
  ) golden_model (
    .clk(clk),
    .reset(reset),
    .cset(cset),
    .cfg(cfg),
    .A0(pipelined_A0),
    .B0(pipelined_B0),
    .A1(pipelined_A1),
    .B1(pipelined_B1),
    .A2(pipelined_A2),
    .B2(pipelined_B2),
    .A3(pipelined_A3),
    .B3(pipelined_B3),
    .out0(golden_out0),
    .out1(golden_out1),
    .out2(golden_out2),
    .out3(golden_out3)
  );

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
    $value$plusargs("edgecase=%d", edgecase);
  end

  //-----------------------------------------------
  // Start the simulation

  always @(posedge clk) begin
    if (~reset & ~cset) begin
      A0 <= edgecase == 1 ? 0 : (edgecase == 2 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      A1 <= edgecase == 1 ? 0 : (edgecase == 2 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      A2 <= edgecase == 1 ? 0 : (edgecase == 2 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      A3 <= edgecase == 1 ? 0 : (edgecase == 2 ? {MAC_MIN_WIDTH{1'b1}} : $urandom); 
      B0 <= edgecase == 3 ? 0 : (edgecase == 4 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      B1 <= edgecase == 3 ? 0 : (edgecase == 4 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      B2 <= edgecase == 3 ? 0 : (edgecase == 4 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);
      B3 <= edgecase == 3 ? 0 : (edgecase == 4 ? {MAC_MIN_WIDTH{1'b1}} : $urandom);

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