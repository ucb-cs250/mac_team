`timescale 1ns / 1ps

module n_bit_acc_negator_adder #(
    parameter N=32
)(
    input [N-1:0]   A,
    input           cin,
    output [N-1:0]  SUM,
    output          cout,
    output          PG // GG always 0
);
  
  if (N <= 4) begin
    one_level_acc_negator_adder #(
      .N(N)
    ) adder (
      .A(A),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG)
    );
  end else if (N <= 16) begin
    two_level_acc_negator_adder #(
      .N(N)
    ) adder (
      .A(A),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG)
    );
  end else if (N <= 64) begin
    three_level_acc_negator_adder #(
      .N(N)
    ) adder (
      .A(A),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG)
    ); 
  end else begin
    $error($sformatf("Illegal value for n_bit_cla_adder parameter N (%0d)", N));
  end
endmodule

module acc_negator_cla #(
  parameter N=4 
)(
  input         cin,
  input [N-1:0]   P,
  output [N-1:0]  C,
  output        PG
);
  
  // Generate block only elaborated in error case
  if (N > 4 | N < 1) begin
    $error($sformatf("Illegal value for carry_lookahead_unit parameter N (%0d)", N));
  end

  wire C0_and_P0 = P[0] & cin;
  wire C0_and_P0_and_P1;
  wire C0_and_P0_and_P1_and_P2;

  assign C[0] = C0_and_P0;

  if (N > 1) begin
    assign C0_and_P0_and_P1 = C0_and_P0 & P[1];
    assign C[1] = (C0_and_P0_and_P1);
  end

  if (N > 2) begin
    assign C0_and_P0_and_P1_and_P2 = C0_and_P0 & (P[1] & P[2]);
    assign C[2] = C0_and_P0_and_P1_and_P2;
  end

  if (N > 3) begin
    assign C[3] = (C0_and_P0_and_P1_and_P2 & P[3]);
  end

  assign PG = &P;
endmodule

// One level CLA adder supports widths 1-4 
module one_level_acc_negator_adder #(
  parameter N=4
)(
  input [N-1:0]   A,
  input         cin,
  output [N-1:0]  SUM,
  output        cout,
  output        PG
);
  
  // Generate block only elaborated in error case
  if (N > 4 | N < 1) begin
    $error($sformatf("Illegal value for one_level_cla_adder parameter N (%0d)", N));
  end

  wire [N-1:0] C;

  wire [N-1:0] C_bus;

  if (N == 1) begin
    assign cout = C_bus;
  end else begin
    assign {cout, C[N-1:1]} = C_bus;
  end

  acc_negator_cla #(
    .N(N)
  ) clu (
    .cin(cin),
    .P(A),
    .C(C_bus),
    .PG(PG)
  );

  assign C[0] = cin;
  generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin: adders
       sky130_fd_sc_hd__ha_4 adder (
        .COUT(),
        .SUM(SUM[i]),
        .A(A[i]),
        .B(C[i])
      );
    end
  endgenerate

endmodule 

module two_level_acc_negator_adder #(
  parameter N=16
)(
  input [N-1:0]   A,
  input           cin,
  output [N-1:0]  SUM,
  output          cout,
  output          PG
);
  
  localparam NUM_ONE_LEVEL_ADDERS = (N+3)/4; //CEIL approx
  localparam NUM_FULL_ONE_LEVEL_ADDERS = N/4; //FLOOR

  wire [NUM_ONE_LEVEL_ADDERS-1:0] PG_bus;
  wire [NUM_ONE_LEVEL_ADDERS-1:0] C_bus;

  assign C_bus[0] = cin;

  // Generate block only elaborated in error case
  if (N > 16 | N < 5) begin
    $error($sformatf("Illegal value for two_level_cla_adder parameter N (%0d)", N));
  end

  generate
    genvar i;
    // Handle 4-bit groups
    for (i = 0; i < NUM_FULL_ONE_LEVEL_ADDERS; i = i + 1) begin: adders
      one_level_acc_negator_adder #(
        .N(4)
      ) adder (
        .A(A[4*(i+1)-1: 4*i]),
        .cin(C_bus[i]),
        .SUM(SUM[4*(i+1)-1: 4*i]),
        .cout(),
        .PG(PG_bus[i])
      );
    end
  endgenerate

  // Handle remaining bits
  if (NUM_ONE_LEVEL_ADDERS != NUM_FULL_ONE_LEVEL_ADDERS) begin
     one_level_acc_negator_adder #(
      .N(N-(4*NUM_FULL_ONE_LEVEL_ADDERS))
    ) adder (
      .A(A[N-1:4*NUM_FULL_ONE_LEVEL_ADDERS]),
      .cin(C_bus[NUM_ONE_LEVEL_ADDERS-1]),
      .SUM(SUM[N-1:4*NUM_FULL_ONE_LEVEL_ADDERS]),
      .cout(),
      .PG(PG_bus[NUM_ONE_LEVEL_ADDERS-1])
    );
  end

  wire [NUM_ONE_LEVEL_ADDERS-1:0] C_clu;

  if (NUM_ONE_LEVEL_ADDERS == 1) begin
    assign cout = C_clu;
  end else begin
    assign {cout, C_bus[NUM_ONE_LEVEL_ADDERS-1:1]} = C_clu;
  end

  acc_negator_cla #(
    .N(NUM_ONE_LEVEL_ADDERS)
  ) clu (
    .cin(cin),
    .P(PG_bus),
    .C(C_clu),
    .PG(PG)
  );

endmodule 

module three_level_acc_negator_adder #(
  parameter N=64
)(
  input [N-1:0]   A,
  input           cin,
  output [N-1:0]  SUM,
  output          cout,
  output          PG
);
  
  localparam NUM_TWO_LEVEL_ADDERS = (N+15)/16; //CEIL
  localparam NUM_FULL_TWO_LEVEL_ADDERS = N/16; //FLOOR

  wire [NUM_TWO_LEVEL_ADDERS-1:0] PG_bus;
  wire [NUM_TWO_LEVEL_ADDERS-1:0] C_bus;

  assign C_bus[0] = cin;

  // Generate block only elaborated in error case
  if (N > 64 | N < 17) begin
    $error($sformatf("Illegal value for three_level_cla_adder parameter N (%0d)", N));
  end

  generate
    genvar i;
    // Handle 4-bit groups
    for (i = 0; i < NUM_FULL_TWO_LEVEL_ADDERS; i = i + 1) begin: adders
      two_level_acc_negator_adder #(
        .N(16)
      ) adder (
        .A(A[16*(i+1)-1: 16*i]),
        .cin(C_bus[i]),
        .SUM(SUM[16*(i+1)-1: 16*i]),
        .cout(),
        .PG(PG_bus[i])
      );
    end
  endgenerate

  // Handle remaining bits
  if (NUM_TWO_LEVEL_ADDERS != NUM_FULL_TWO_LEVEL_ADDERS) begin
    if (N-(16*NUM_FULL_TWO_LEVEL_ADDERS) <= 4) begin
      one_level_acc_negator_adder #(
        .N(N-(16*NUM_FULL_TWO_LEVEL_ADDERS))
      ) adder (
        .A(A[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cin(C_bus[NUM_TWO_LEVEL_ADDERS-1]),
        .SUM(SUM[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cout(),
        .PG(PG_bus[NUM_TWO_LEVEL_ADDERS-1])
      );
    end else begin
      two_level_acc_negator_adder #(
        .N(N-(16*NUM_FULL_TWO_LEVEL_ADDERS))
      ) adder (
        .A(A[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cin(C_bus[NUM_TWO_LEVEL_ADDERS-1]),
        .SUM(SUM[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cout(),
        .PG(PG_bus[NUM_TWO_LEVEL_ADDERS-1])
      );
    end
  end

  wire [NUM_TWO_LEVEL_ADDERS-1:0] C_clu;

  if (NUM_TWO_LEVEL_ADDERS == 1) begin
    assign cout = C_clu;
  end else begin
    assign {cout, C_bus[NUM_TWO_LEVEL_ADDERS-1:1]} = C_clu;
  end

  acc_negator_cla #(
    .N(NUM_TWO_LEVEL_ADDERS)
  ) clu (
    .cin(cin),
    .P(PG_bus),
    .C(C_clu),
    .PG(PG)
  );

endmodule 


























