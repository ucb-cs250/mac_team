`timescale 1ns / 1ps

module n_bit_cla_adder #(
    parameter N=32
)(
    input [N-1:0]   A,
    input [N-1:0]   B,
    input           cin,
    output [N-1:0]  SUM,
    output          cout,
    output          PG,
    output          GG
);
  
  if (N <= 4) begin
    one_level_cla_adder #(
      .N(N)
    ) adder (
      .A(A),
      .B(B),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG),
      .GG(GG)
    );
  end else if (N <= 16) begin
    two_level_cla_adder #(
      .N(N)
    ) adder (
      .A(A),
      .B(B),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG),
      .GG(GG)
    );
  end else if (N <= 64) begin
    three_level_cla_adder #(
      .N(N)
    ) adder (
      .A(A),
      .B(B),
      .cin(cin),
      .SUM(SUM),
      .cout(cout),
      .PG(PG),
      .GG(GG)
    ); 
  end else begin
    $error($sformatf("Illegal value for n_bit_cla_adder parameter N (%0d)", N));
  end

endmodule

module propagate_generate_unit #(
  parameter N=4
)(
  input [N-1:0] A,
  input [N-1:0] B,
  output [N-1:0] P,
  output [N-1:0] G
);
  
  // Generate block only elaborated in error case
  if (N > 4) begin
    $error($sformatf("Illegal value for propagate_generate_unit parameter N (%0d)", N));
  end

  assign G = A & B;
  assign P = A | B;

endmodule

// One level CLA adder supports widths 1-4 
module one_level_cla_adder #(
  parameter N=4
)(
  input [N-1:0]   A,
  input [N-1:0]   B,
  input         cin,
  output [N-1:0]  SUM,
  output        cout,
  output        GG,
  output        PG
);
  
  // Generate block only elaborated in error case
  if (N > 4 | N < 1) begin
    $error($sformatf("Illegal value for one_level_cla_adder parameter N (%0d)", N));
  end

  wire [N-1:0] C;
  wire [N-1:0] P;
  wire [N-1:0] G;

  propagate_generate_unit #(
    .N(N)
  ) propgen (
    .A(A),
    .B(B),
    .P(P),
    .G(G)
  );

  wire [N-1:0] C_bus;

  if (N == 1) begin
    assign cout = C_bus;
  end else begin
    assign {cout, C[N-1:1]} = C_bus;
  end

  carry_lookahead_unit #(
    .N(N)
  ) clu (
    .cin(cin),
    .P(P),
    .G(G),
    .C(C_bus),
    .GG(GG),
    .PG(PG)
  );

  assign C[0] = cin;
  generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin: adders
       sky130_fd_sc_hd__fa_4 adder (
        .COUT(),
        .SUM(SUM[i]),
        .A(A[i]),
        .B(B[i]),
        .CIN(C[i])
      );
    end
  endgenerate

endmodule 

module two_level_cla_adder #(
  parameter N=16
)(
  input [N-1:0]   A,
  input [N-1:0]   B,
  input           cin,
  output [N-1:0]  SUM,
  output          cout,
  output          GG,
  output          PG
);
  
  localparam NUM_ONE_LEVEL_ADDERS = (N+3)/4; //CEIL approx
  localparam NUM_FULL_ONE_LEVEL_ADDERS = N/4; //FLOOR

  wire [NUM_ONE_LEVEL_ADDERS-1:0] GG_bus;
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
      one_level_cla_adder #(
        .N(4)
      ) adder (
        .A(A[4*(i+1)-1: 4*i]),
        .B(B[4*(i+1)-1: 4*i]),
        .cin(C_bus[i]),
        .SUM(SUM[4*(i+1)-1: 4*i]),
        .cout(),
        .GG(GG_bus[i]),
        .PG(PG_bus[i])
      );
    end
  endgenerate

  // Handle remaining bits
  if (NUM_ONE_LEVEL_ADDERS != NUM_FULL_ONE_LEVEL_ADDERS) begin
     one_level_cla_adder #(
      .N(N-(4*NUM_FULL_ONE_LEVEL_ADDERS))
    ) adder (
      .A(A[N-1:4*NUM_FULL_ONE_LEVEL_ADDERS]),
      .B(B[N-1:4*NUM_FULL_ONE_LEVEL_ADDERS]),
      .cin(C_bus[NUM_ONE_LEVEL_ADDERS-1]),
      .SUM(SUM[N-1:4*NUM_FULL_ONE_LEVEL_ADDERS]),
      .cout(),
      .GG(GG_bus[NUM_ONE_LEVEL_ADDERS-1]),
      .PG(PG_bus[NUM_ONE_LEVEL_ADDERS-1])
    );
  end

  wire [NUM_ONE_LEVEL_ADDERS-1:0] C_clu;

  if (NUM_ONE_LEVEL_ADDERS == 1) begin
    assign cout = C_clu;
  end else begin
    assign {cout, C_bus[NUM_ONE_LEVEL_ADDERS-1:1]} = C_clu;
  end

  carry_lookahead_unit #(
    .N(NUM_ONE_LEVEL_ADDERS)
  ) clu (
    .cin(cin),
    .P(PG_bus),
    .G(GG_bus),
    .C(C_clu),
    .GG(GG),
    .PG(PG)
  );

endmodule 

module three_level_cla_adder #(
  parameter N=64
)(
  input [N-1:0]   A,
  input [N-1:0]   B,
  input           cin,
  output [N-1:0]  SUM,
  output          cout,
  output          GG,
  output          PG
);
  
  localparam NUM_TWO_LEVEL_ADDERS = (N+15)/16; //CEIL
  localparam NUM_FULL_TWO_LEVEL_ADDERS = N/16; //FLOOR

  wire [NUM_TWO_LEVEL_ADDERS-1:0] GG_bus;
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
      two_level_cla_adder #(
        .N(16)
      ) adder (
        .A(A[16*(i+1)-1: 16*i]),
        .B(B[16*(i+1)-1: 16*i]),
        .cin(C_bus[i]),
        .SUM(SUM[16*(i+1)-1: 16*i]),
        .cout(),
        .GG(GG_bus[i]),
        .PG(PG_bus[i])
      );
    end
  endgenerate

  // Handle remaining bits
  if (NUM_TWO_LEVEL_ADDERS != NUM_FULL_TWO_LEVEL_ADDERS) begin
    if (N-(16*NUM_FULL_TWO_LEVEL_ADDERS) <= 4) begin
      one_level_cla_adder #(
        .N(N-(16*NUM_FULL_TWO_LEVEL_ADDERS))
      ) adder (
        .A(A[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .B(B[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cin(C_bus[NUM_TWO_LEVEL_ADDERS-1]),
        .SUM(SUM[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cout(),
        .GG(GG_bus[NUM_TWO_LEVEL_ADDERS-1]),
        .PG(PG_bus[NUM_TWO_LEVEL_ADDERS-1])
      );
    end else begin
      two_level_cla_adder #(
        .N(N-(16*NUM_FULL_TWO_LEVEL_ADDERS))
      ) adder (
        .A(A[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .B(B[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cin(C_bus[NUM_TWO_LEVEL_ADDERS-1]),
        .SUM(SUM[N-1:16*NUM_FULL_TWO_LEVEL_ADDERS]),
        .cout(),
        .GG(GG_bus[NUM_TWO_LEVEL_ADDERS-1]),
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

  carry_lookahead_unit #(
    .N(NUM_TWO_LEVEL_ADDERS)
  ) clu (
    .cin(cin),
    .P(PG_bus),
    .G(GG_bus),
    .C(C_clu),
    .GG(GG),
    .PG(PG)
  );

endmodule 


























