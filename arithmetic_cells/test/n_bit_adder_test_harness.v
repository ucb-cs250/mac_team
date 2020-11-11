`timescale 1ns / 1ps

module n_bit_adder_test_harness #(
  parameter N = 8
)(
  input clk,
  input reset
);

//reg [31:0] seed;
//initial seed = $get_initial_random_seed();

//-----------------------------------------------
// Setup clocking and reset
reg r_reset;

reg [N-1:0] A;
reg [N-1:0] B;
reg cin;

wire [N-1:0] SUM;
wire cout;

//-----------------------------------------------
// Instantiate the dut

n_bit_adder #(
  .N(N)
) dut (
    .A(A),
    .B(B),
    .cin(cin),
    .SUM(SUM),
    .cout(cout)
);


//-----------------------------------------------
// Memory interface

always @(negedge clk)
begin
  r_reset <= reset;
end

//-----------------------------------------------
// Golden Model
reg [N-1:0] golden_SUM;
reg [N-1:0] golden_cout;

always @(posedge clk) begin
  if (!reset) begin
    {golden_cout, golden_SUM} = A + B + cin;
  end else begin
    {golden_cout, golden_SUM} = 0;
  end
end

//-----------------------------------------------
// Initialization
reg [31:0] test = 1;
reg [31:0] num_tests = 10;

initial begin
  $value$plusargs("num_tests=%d", num_tests);
  golden_SUM = 0;
  golden_cout = 0;
end

//-----------------------------------------------
// Start the simulation

always @(posedge clk) begin
  if (!reset) begin
    A = $urandom;
    B = $urandom;
    cin = $urandom;

    if (SUM != golden_SUM || cout != golden_cout) begin
      $display("FAILED: On test %0d of %0d", test, num_tests);
      $display("SUM: Got %0d, Expected %0d", SUM, golden_SUM);
      $display("cout: Got %0d, Expected %0d", cout, golden_cout);
      $finish; 
    end
  end
end

//-----------------------------------------------
// Count cycles 
always @(posedge clk) begin
  if (!reset) begin
    if (test > num_tests) begin
      $display("PASSED: %0d tests", num_tests);
      $finish;
    end else begin
      test = test + 1;
    end
  end else begin
    test = test;
  end
end

endmodule