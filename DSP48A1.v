module DSP48A1 (
  A, B, D, C, CLK, CARRYIN, OPMODE, BCIN,
  RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
  CEA, CEB, CEC, CEP, CEM, CED, CECARRYIN, CEOPMODE,
  PCIN, BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF
);

  // Parameters to configure pipelining and reset behavior
  parameter A0REG = 0;           // Enable register stage A0
  parameter A1REG = 1;           // Enable register stage A1
  parameter B0REG = 0;           // Enable register stage B0
  parameter B1REG = 1;           // Enable register stage B1
  parameter CREG  = 1;           // Enable C input register
  parameter DREG  = 1;           // Enable D input register
  parameter MREG  = 1;           // Enable multiplier output register
  parameter PREG  = 1;           // Enable final output P register
  parameter CARRYINREG  = 1;     // Enable carry-in register
  parameter CARRYOUTREG = 1;     // Enable carry-out register
  parameter OPMODEREG   = 1;     // Enable OPMODE register
  parameter CARRYINSEL  = "OPMODE5"; // Carry-in source selection
  parameter B_INPUT     = "DIRECT";  // B input source: DIRECT or CASCADE
  parameter RSTTYPE     = "SYNC";    // Reset type: SYNC or ASYNC

  // Inputs
  input [17:0] A, B, D, BCIN;   // A, B, D operands, BCIN cascade input
  input [47:0] C, PCIN;         // C operand and PCIN cascade input
  input CARRYIN, CLK;           // Carry input and clock
  input CEA, CEB, CEC, CEP;     // Clock Enables for A, B, C, P
  input CEM, CED, CECARRYIN, CEOPMODE; // Clock Enables for Mult, D, CarryIn, OPMODE
  input RSTA, RSTB, RSTC, RSTD; // Resets for A, B, C, D
  input RSTM, RSTP;             // Resets for Mult register and P
  input RSTCARRYIN, RSTOPMODE;  // Resets for CarryIn and OPMODE
  input [7:0] OPMODE;           // Operation mode control bits

  // Outputs
  output [17:0] BCOUT;          // Cascade B output
  output [47:0] PCOUT, P;       // Cascade P output and final result
  output [35:0] M;              // Multiplier output
  output CARRYOUT, CARRYOUTF;   // Carry out signals

  // Internal wires
  wire [17:0] A0, A1, B0, B1, b_reg, d_reg, Add_Sub1_res, B_reg1in;
  wire [47:0] c_reg, P_reg, x_out, z_out, p_out;
  wire [35:0] mul_out, m_reg;
  wire cin, CIN, cout, CARRYOUT1;
  wire [7:0] opmode_reg;

  // D register stage
  Reg_Mux #(.REG_SIZE(18), .REST_TYPE(RSTTYPE)) D_REG (
    .clk(CLK),
    .rst(RSTD),
    .sel(DREG[0]),
    .CE(CED),
    .in(D),
    .out(d_reg)
  );

  // B input select: direct or cascade
  B_mux #(.B_SEL(B_INPUT)) b_select (
    .b(B),
    .bcin(BCIN),
    .out(b_reg)
  );

  // B0 register stage
  Reg_Mux #(.REG_SIZE(18), .REST_TYPE(RSTTYPE)) B0_REG (
    .clk(CLK),
    .rst(RSTB),
    .sel(B0REG[0]),
    .CE(CEB),
    .in(b_reg),
    .out(B0)
  );

  // A0 register stage
  Reg_Mux #(.REG_SIZE(18), .REST_TYPE(RSTTYPE)) A0_REG (
    .clk(CLK),
    .rst(RSTA),
    .sel(A0REG[0]),
    .CE(CEA),
    .in(A),
    .out(A0)
  );

  // C register stage
  Reg_Mux #(.REG_SIZE(48), .REST_TYPE(RSTTYPE)) C_REG (
    .clk(CLK),
    .rst(RSTC),
    .sel(CREG[0]),
    .CE(CEC),
    .in(C),
    .out(c_reg)
  );

  // OPMODE register stage
  Reg_Mux #(.REG_SIZE(8), .REST_TYPE(RSTTYPE)) OPMODE_REG (
    .clk(CLK),
    .rst(RSTOPMODE),
    .sel(OPMODEREG[0]),
    .CE(CEOPMODE),
    .in(OPMODE),
    .out(opmode_reg)
  );

  // Pre-adder or subtractor before B1
  Add_Sub_pre #(.ADD_SUB_SIZE(18)) Pre_Adder_Subtracter (
    .in0(B0),
    .in1(d_reg),
    .operation(opmode_reg[6]), // Control bit to select add/sub
    .out(Add_Sub1_res)
  );

  // Mux to choose between B0 or pre-adder result
  Mux2_1 Pre_result (
    .in0(B0),
    .in1(Add_Sub1_res),
    .sel(opmode_reg[4]),
    .out(B_reg1in)
  );

  // B1 register stage
  Reg_Mux #(.REG_SIZE(18), .REST_TYPE(RSTTYPE)) B1_REG (
    .clk(CLK),
    .rst(RSTB),
    .sel(B1REG[0]),
    .CE(CEB),
    .in(B_reg1in),
    .out(B1)
  );

  // A1 register stage
  Reg_Mux #(.REG_SIZE(18), .REST_TYPE(RSTTYPE)) A1_REG (
    .clk(CLK),
    .rst(RSTA),
    .sel(A1REG[0]),
    .CE(CEA),
    .in(A0),
    .out(A1)
  );

  // Multiplier block
  multiplier #(.SIZE(18)) mult (
    .in0(A1),
    .in1(B1),
    .out(mul_out)
  );

  // Multiplier output register
  Reg_Mux #(.REG_SIZE(36), .REST_TYPE(RSTTYPE)) M_REG (
    .clk(CLK),
    .rst(RSTM),
    .sel(MREG[0]),
    .CE(CEM),
    .in(mul_out),
    .out(m_reg)
  );

  // X mux: selects data for post adder input X
  Mux_4_1 #(.IN1_SIZE(36), .IN2_SIZE(48), .IN3_SIZE(48), .OUT_SIZE(48)) X (
    .in1(m_reg),
    .in2(P),
    .in3({d_reg[11:0], A1, B1}),
    .sel(opmode_reg[1:0]),
    .out(x_out)
  );

  // Z mux: selects data for post adder input Z
  Mux_4_1 #(.IN1_SIZE(48), .IN2_SIZE(48), .IN3_SIZE(48), .OUT_SIZE(48)) Z (
    .in1(PCIN),
    .in2(P),
    .in3(c_reg),
    .sel(opmode_reg[3:2]),
    .out(z_out)
  );

  // Carry-in mux: selects source for carry-in
  carryin_mux #(.CARRYINSEL_MUX(CARRYINSEL)) carry_cascade (
    .carryin(CARRYIN),
    .opmode5(opmode_reg[5]),
    .out(cin)
  );

  // Carry-in register
  Reg_Mux #(.REG_SIZE(1), .REST_TYPE(RSTTYPE)) CYI (
    .clk(CLK),
    .rst(RSTCARRYIN),
    .sel(CARRYINREG[0]),
    .CE(CECARRYIN),
    .in(cin),
    .out(CIN)
  );

  // Post-adder or subtractor block
  Add_Sub_post #(.ADD_SUB_SIZE(48)) Post_Adder_Subtracter (
    .in0(x_out),
    .in1(z_out),
    .cin(CIN),
    .op(opmode_reg[7]),
    .out(p_out),
    .cout(cout)
  );

  // Carry-out register
  Reg_Mux #(.REG_SIZE(1), .REST_TYPE(RSTTYPE)) CYO (
    .clk(CLK),
    .rst(RSTCARRYIN),
    .sel(CARRYOUTREG[0]),
    .CE(CECARRYIN),
    .in(cout),
    .out(CARRYOUT)
  );

  // Final output P register
  Reg_Mux #(.REG_SIZE(48), .REST_TYPE(RSTTYPE)) P_REG (
    .clk(CLK),
    .rst(RSTP),
    .sel(PREG[0]),
    .CE(CEP),
    .in(p_out),
    .out(P)
  );

  // Assign cascade and final outputs
  assign BCOUT = B1;
  assign M = m_reg;
  assign CARRYOUTF = CARRYOUT;
  assign PCOUT = P;

endmodule
