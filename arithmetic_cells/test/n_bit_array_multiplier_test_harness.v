`timescale 1ns / 1ps

module n_bit_array_multiplier_test_harness #(
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
reg [N-1:0] B;

wire [2*N-1:0] PROD;

//-----------------------------------------------
// Instantiate the dut

n_bit_array_multiplier #(
  .N(N)
) dut (
    .A(A),
    .B(B),
    .PROD(PROD)
);

//-----------------------------------------------
// Golden Model
wire [2*N-1:0] golden_PROD = A * B;


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
  B = $urandom;
end

always @(negedge clk) begin
  if (PROD != golden_PROD) begin
    $display("FAILED: On test %0d of %0d", test, num_tests);
    $display("PROD: Got %0d, Expected %0d", PROD, golden_PROD);
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