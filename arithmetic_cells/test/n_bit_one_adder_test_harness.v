`timescale 1ns / 1ps

module n_bit_one_adder_test_harness #(
  parameter N = 8
)(
  input clk
);

//reg [31:0] seed;
//initial seed = $get_initial_random_seed();

//-----------------------------------------------
// Setup clocking and reset
reg r_reset;

reg [N-1:0] A;
reg cin;

wire [N-1:0] SUM;
wire cout;

//-----------------------------------------------
// Instantiate the dut

n_bit_one_adder #(
  .N(N)
) dut (
    .A(A),
    .cin(cin),
    .SUM(SUM),
    .cout(cout)
);


//-----------------------------------------------
// Golden Model
wire [N-1:0] golden_SUM;
wire [N-1:0] golden_cout;

assign {golden_cout, golden_SUM} = A + cin;

//-----------------------------------------------
// Initialization
reg [31:0] test = 1;
reg [31:0] num_tests = 10;

initial begin
  $value$plusargs("num_tests=%d", num_tests);
end

//-----------------------------------------------
// Start the simulation

always @(posedge clk) begin
  A = $urandom;
  cin = $urandom;
end

always @(negedge clk) begin
  if (SUM != golden_SUM || cout != golden_cout) begin
    $display("FAILED: On test %0d of %0d", test, num_tests);
    $display("SUM: Got %0d, Expected %0d", SUM, golden_SUM);
    $display("cout: Got %0d, Expected %0d", cout, golden_cout);
    $finish; 
  end
end
//-----------------------------------------------
// Count cycles 
always @(posedge clk) begin
  if (test > num_tests) begin
    $display("PASSED: %0d tests", num_tests);
    $finish;
  end else begin
    test = test + 1;
  end
end

endmodule