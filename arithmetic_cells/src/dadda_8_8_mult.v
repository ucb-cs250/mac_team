`timescale 1ns / 1ps

module dadda_8_8_mult (
  input  [7:0]  A,
  input  [7:0]  B,
  output [15:0] C
);

// Yes... I did manually write it out... (easier than writing a generate fn)
// But don't worry, a lot of this is python generated
// Total Cell Count: 8 Half-adders, 48 Full-adders

// HALF-ADDER PORTION
wire [7:0] hsum;
wire [7:0] hcout;

sky130_fd_sc_hd__ha_1 ha_0 (.A(A[6] & B[0]), .B(A[5] & B[1]), .SUM(hsum[0]), .COUT(hcout[0]));
sky130_fd_sc_hd__ha_1 ha_1 (.A(A[4] & B[3]), .B(A[3] & B[4]), .SUM(hsum[1]), .COUT(hcout[1]));
sky130_fd_sc_hd__ha_1 ha_2 (.A(A[4] & B[4]), .B(A[3] & B[5]), .SUM(hsum[2]), .COUT(hcout[2]));
sky130_fd_sc_hd__ha_1 ha_3 (.A(A[4] & B[0]), .B(A[3] & B[1]), .SUM(hsum[3]), .COUT(hcout[3]));
sky130_fd_sc_hd__ha_1 ha_4 (.A(A[2] & B[3]), .B(A[1] & B[4]), .SUM(hsum[4]), .COUT(hcout[4]));
sky130_fd_sc_hd__ha_1 ha_5 (.A(A[3] & B[0]), .B(A[2] & B[1]), .SUM(hsum[5]), .COUT(hcout[5]));
sky130_fd_sc_hd__ha_1 ha_6 (.A(A[2] & B[0]), .B(A[1] & B[1]), .SUM(hsum[6]), .COUT(hcout[6]));
sky130_fd_sc_hd__ha_4 ha_7 (.A(A[1] & B[0]), .B(A[0] & B[1]), .SUM(hsum[7]), .COUT(hcout[7]));

// FULL-ADDER PORTION
wire [47:0] fsum;
wire [47:0] fcout;
sky130_fd_sc_hd__fa_1 fa_0 (.A(A[7] & B[0]), .B(A[6] & B[1]), .CIN(A[5] & B[2]), .SUM(fsum[0]), .COUT(fcout[0]));
sky130_fd_sc_hd__fa_1 fa_1 (.A(A[7] & B[1]), .B(A[6] & B[2]), .CIN(A[5] & B[3]), .SUM(fsum[1]), .COUT(fcout[1]));
sky130_fd_sc_hd__fa_1 fa_2 (.A(A[7] & B[2]), .B(A[6] & B[3]), .CIN(A[5] & B[4]), .SUM(fsum[2]), .COUT(fcout[2]));
sky130_fd_sc_hd__fa_1 fa_3 (.A(A[5] & B[0]), .B(A[4] & B[1]), .CIN(A[3] & B[2]), .SUM(fsum[3]), .COUT(fcout[3]));
sky130_fd_sc_hd__fa_1 fa_4 (.A(hsum[0]), .B(A[4] & B[2]), .CIN(A[3] & B[3]), .SUM(fsum[4]), .COUT(fcout[4]));
sky130_fd_sc_hd__fa_1 fa_5 (.A(A[2] & B[4]), .B(A[1] & B[5]), .CIN(A[0] & B[6]), .SUM(fsum[5]), .COUT(fcout[5]));
sky130_fd_sc_hd__fa_1 fa_6 (.A(hcout[0]), .B(fsum[0]), .CIN(hsum[1]), .SUM(fsum[6]), .COUT(fcout[6]));
sky130_fd_sc_hd__fa_1 fa_7 (.A(A[2] & B[5]), .B(A[1] & B[6]), .CIN(A[0] & B[7]), .SUM(fsum[7]), .COUT(fcout[7]));
sky130_fd_sc_hd__fa_1 fa_8 (.A(hcout[1]), .B(fcout[0]), .CIN(fsum[1]), .SUM(fsum[8]), .COUT(fcout[8]));
sky130_fd_sc_hd__fa_1 fa_9 (.A(hsum[2]), .B(A[2] & B[6]), .CIN(A[1] & B[7]), .SUM(fsum[9]), .COUT(fcout[9]));
sky130_fd_sc_hd__fa_1 fa_10 (.A(hcout[2]), .B(fcout[1]), .CIN(fsum[2]), .SUM(fsum[10]), .COUT(fcout[10]));
sky130_fd_sc_hd__fa_1 fa_11 (.A(A[4] & B[5]), .B(A[3] & B[6]), .CIN(A[2] & B[7]), .SUM(fsum[11]), .COUT(fcout[11]));
sky130_fd_sc_hd__fa_1 fa_12 (.A(fcout[2]), .B(A[7] & B[3]), .CIN(A[6] & B[4]), .SUM(fsum[12]), .COUT(fcout[12]));
sky130_fd_sc_hd__fa_1 fa_13 (.A(A[5] & B[5]), .B(A[4] & B[6]), .CIN(A[3] & B[7]), .SUM(fsum[13]), .COUT(fcout[13]));
sky130_fd_sc_hd__fa_1 fa_14 (.A(A[7] & B[4]), .B(A[6] & B[5]), .CIN(A[5] & B[6]), .SUM(fsum[14]), .COUT(fcout[14]));
sky130_fd_sc_hd__fa_1 fa_15 (.A(hsum[3]), .B(A[2] & B[2]), .CIN(A[1] & B[3]), .SUM(fsum[15]), .COUT(fcout[15]));
sky130_fd_sc_hd__fa_1 fa_16 (.A(hcout[3]), .B(fsum[3]), .CIN(hsum[4]), .SUM(fsum[16]), .COUT(fcout[16]));
sky130_fd_sc_hd__fa_1 fa_17 (.A(hcout[4]), .B(fcout[3]), .CIN(fsum[4]), .SUM(fsum[17]), .COUT(fcout[17]));
sky130_fd_sc_hd__fa_1 fa_18 (.A(fcout[4]), .B(fcout[5]), .CIN(fsum[6]), .SUM(fsum[18]), .COUT(fcout[18]));
sky130_fd_sc_hd__fa_1 fa_19 (.A(fcout[6]), .B(fcout[7]), .CIN(fsum[8]), .SUM(fsum[19]), .COUT(fcout[19]));
sky130_fd_sc_hd__fa_1 fa_20 (.A(fcout[8]), .B(fcout[9]), .CIN(fsum[10]), .SUM(fsum[20]), .COUT(fcout[20]));
sky130_fd_sc_hd__fa_1 fa_21 (.A(fcout[10]), .B(fcout[11]), .CIN(fsum[12]), .SUM(fsum[21]), .COUT(fcout[21]));
sky130_fd_sc_hd__fa_1 fa_22 (.A(fcout[12]), .B(fcout[13]), .CIN(fsum[14]), .SUM(fsum[22]), .COUT(fcout[22]));
sky130_fd_sc_hd__fa_1 fa_23 (.A(fcout[14]), .B(A[7] & B[5]), .CIN(A[6] & B[6]), .SUM(fsum[23]), .COUT(fcout[23]));
sky130_fd_sc_hd__fa_1 fa_24 (.A(hsum[5]), .B(A[1] & B[2]), .CIN(A[0] & B[3]), .SUM(fsum[24]), .COUT(fcout[24]));
sky130_fd_sc_hd__fa_1 fa_25 (.A(hcout[5]), .B(fsum[15]), .CIN(A[0] & B[4]), .SUM(fsum[25]), .COUT(fcout[25]));
sky130_fd_sc_hd__fa_1 fa_26 (.A(fcout[15]), .B(fsum[16]), .CIN(A[0] & B[5]), .SUM(fsum[26]), .COUT(fcout[26]));
sky130_fd_sc_hd__fa_1 fa_27 (.A(fcout[16]), .B(fsum[17]), .CIN(fsum[5]), .SUM(fsum[27]), .COUT(fcout[27]));
sky130_fd_sc_hd__fa_1 fa_28 (.A(fcout[17]), .B(fsum[18]), .CIN(fsum[7]), .SUM(fsum[28]), .COUT(fcout[28]));
sky130_fd_sc_hd__fa_1 fa_29 (.A(fcout[18]), .B(fsum[19]), .CIN(fsum[9]), .SUM(fsum[29]), .COUT(fcout[29]));
sky130_fd_sc_hd__fa_1 fa_30 (.A(fcout[19]), .B(fsum[20]), .CIN(fsum[11]), .SUM(fsum[30]), .COUT(fcout[30]));
sky130_fd_sc_hd__fa_1 fa_31 (.A(fcout[20]), .B(fsum[21]), .CIN(fsum[13]), .SUM(fsum[31]), .COUT(fcout[31]));
sky130_fd_sc_hd__fa_1 fa_32 (.A(fcout[21]), .B(fsum[22]), .CIN(A[4] & B[7]), .SUM(fsum[32]), .COUT(fcout[32]));
sky130_fd_sc_hd__fa_1 fa_33 (.A(fcout[22]), .B(fsum[23]), .CIN(A[5] & B[7]), .SUM(fsum[33]), .COUT(fcout[33]));
sky130_fd_sc_hd__fa_1 fa_34 (.A(fcout[23]), .B(A[7] & B[6]), .CIN(A[6] & B[7]), .SUM(fsum[34]), .COUT(fcout[34]));
sky130_fd_sc_hd__fa_4 fa_35 (.A(hsum[6]), .B(A[0] & B[2]), .CIN(hcout[7]), .SUM(fsum[35]), .COUT(fcout[35]));
sky130_fd_sc_hd__fa_4 fa_36 (.A(hcout[6]), .B(fsum[24]), .CIN(fcout[35]), .SUM(fsum[36]), .COUT(fcout[36]));
sky130_fd_sc_hd__fa_4 fa_37 (.A(fcout[24]), .B(fsum[25]), .CIN(fcout[36]), .SUM(fsum[37]), .COUT(fcout[37]));
sky130_fd_sc_hd__fa_4 fa_38 (.A(fcout[25]), .B(fsum[26]), .CIN(fcout[37]), .SUM(fsum[38]), .COUT(fcout[38]));
sky130_fd_sc_hd__fa_4 fa_39 (.A(fcout[26]), .B(fsum[27]), .CIN(fcout[38]), .SUM(fsum[39]), .COUT(fcout[39]));
sky130_fd_sc_hd__fa_4 fa_40 (.A(fcout[27]), .B(fsum[28]), .CIN(fcout[39]), .SUM(fsum[40]), .COUT(fcout[40]));
sky130_fd_sc_hd__fa_4 fa_41 (.A(fcout[28]), .B(fsum[29]), .CIN(fcout[40]), .SUM(fsum[41]), .COUT(fcout[41]));
sky130_fd_sc_hd__fa_4 fa_42 (.A(fcout[29]), .B(fsum[30]), .CIN(fcout[41]), .SUM(fsum[42]), .COUT(fcout[42]));
sky130_fd_sc_hd__fa_4 fa_43 (.A(fcout[30]), .B(fsum[31]), .CIN(fcout[42]), .SUM(fsum[43]), .COUT(fcout[43]));
sky130_fd_sc_hd__fa_4 fa_44 (.A(fcout[31]), .B(fsum[32]), .CIN(fcout[43]), .SUM(fsum[44]), .COUT(fcout[44]));
sky130_fd_sc_hd__fa_4 fa_45 (.A(fcout[32]), .B(fsum[33]), .CIN(fcout[44]), .SUM(fsum[45]), .COUT(fcout[45]));
sky130_fd_sc_hd__fa_4 fa_46 (.A(fcout[33]), .B(fsum[34]), .CIN(fcout[45]), .SUM(fsum[46]), .COUT(fcout[46]));
sky130_fd_sc_hd__fa_4 fa_47 (.A(fcout[34]), .B(A[7] & B[7]), .CIN(fcout[46]), .SUM(fsum[47]), .COUT(fcout[47]));


// Note that the final adders have a driving power of 4
assign C = {fcout[47], fsum[47], fsum[46], fsum[45], fsum[44], fsum[43], fsum[42], fsum[41], fsum[40], fsum[39], fsum[38],
  fsum[37], fsum[36], fsum[35], hsum[7], A[0] & B[0]};

endmodule
