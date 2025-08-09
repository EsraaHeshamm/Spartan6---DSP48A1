module DSP48A1_tb();
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG  = 1;
parameter DREG  = 1;
parameter MREG  = 1;
parameter PREG  = 1;
parameter CARRYINREG  = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG   = 1;
parameter CARRYINSEL  = "OPMODE5";
parameter B_INPUT     = "DIRECT" ;
parameter RSTTYPE     = "SYNC"   ;
reg [17:0] A,B,D,BCIN;
reg [47:0] C , PCIN ,p_prev,pcout_prev;
reg CARRYIN , CLK ,CEA,CEB,CEC,CED, CEM,CEP,CECARRYIN,CEOPMODE , RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE;
reg [7:0] OPMODE;
reg carryout_prev;
wire [17:0] BCOUT;
wire [47:0]PCOUT ,P;
wire [35:0]M;
wire CARRYOUT,CARRYOUTF;
 // Instantiate DUT with parameters
    DSP48A1 #(
        .A0REG(0),
        .A1REG(1),
        .B0REG(0),
        .B1REG(1),
        .CREG(1),
        .DREG(1),
        .MREG(1),
        .PREG(1),
        .CARRYINREG(1),
        .CARRYOUTREG(1),
        .OPMODEREG(1),
        .CARRYINSEL("OPMODE5"),
        .B_INPUT("DIRECT"),
        .RSTTYPE("SYNC")
    ) DUT (
        .A(A), .B(B), .D(D), .C(C),
        .CLK(CLK), .CARRYIN(CARRYIN), .OPMODE(OPMODE), .BCIN(BCIN),
        .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), .RSTP(RSTP),
        .RSTC(RSTC), .RSTD(RSTD), .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
        .CEA(CEA), .CEB(CEB), .CEC(CEC), .CEP(CEP),
        .CEM(CEM), .CED(CED), .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
        .PCIN(PCIN), .BCOUT(BCOUT), .PCOUT(PCOUT), .P(P), .M(M),
        .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
    );
initial begin
 CLK=0;
 forever
 #1 CLK=~CLK;
end

initial begin
 RSTA=1;
 RSTB=1;
 RSTC=1;
 RSTD=1;
 RSTM=1;
 RSTP=1;
 RSTCARRYIN=1;
 RSTOPMODE=1;
 CEA=$random; 
 CEB=$random;
 CEC=$random;
 CED=$random;
 CEM=$random;
 CEP=$random;
 CECARRYIN=$random;
 CEOPMODE=$random;
 CARRYIN=$random;
 OPMODE=$random;
 A=$random;
 B=$random;
 D=$random;
 BCIN=$random;
 C=$random;
 PCIN=$random;
 carryout_prev=$random;
 p_prev=$random;
 pcout_prev=$random;
 @(negedge CLK);
  if (M == 0 && P == 0 && CARRYOUT == 0 && CARRYOUTF == 0 && BCOUT == 0 && PCOUT == 0) begin
   $display("Reset test - All outputs are zero");
  end 
  else begin
   $display("Error: Reset test - Outputs not zero:\n",   "M=%h, P=%h, CARRYOUT=%b, CARRYOUTF=%b, BCOUT=%h, PCOUT=%h", M, P, CARRYOUT, CARRYOUTF, BCOUT, PCOUT);
   $stop;
  end
 RSTA=0;
 RSTB=0;
 RSTC=0;
 RSTD=0;
 RSTM=0;
 RSTP=0;
 RSTCARRYIN=0;
 RSTOPMODE=0;
 CEA=1; 
 CEB=1;
 CEC=1;
 CED=1;
 CEM=1;
 CEP=1;
 CECARRYIN=1;
 CEOPMODE=1;
 OPMODE = 8'b11011101;
 A=18'd20;
 B=18'd10;
 C=48'd350;
 D=18'd25;
 CARRYIN=$random;
 BCIN=$random;
 PCIN=$random;
repeat(4)@(negedge CLK);
 if (BCOUT == 18'hf && M == 36'h12c && P == 48'h32 && PCOUT == 48'h32 && CARRYOUT == 0 && CARRYOUTF == 0) begin
  $display("DSP Path 1 test passed");
 end
 else begin
  $display("Error: DSP Path 1 test failed");
  $stop;
 end
 OPMODE = 8'b00010000;
 A=18'd20;
 B=18'd10;
 C=48'd350;
 D=18'd25;
 CARRYIN=$random;
 BCIN=$random;
 PCIN=$random;
 repeat(3)@(negedge CLK);
 if (BCOUT == 18'h23 && M == 36'h2bc && P == 48'h0 && PCOUT == 48'h0 && CARRYOUT == 0 && CARRYOUTF == 0) begin
  $display("DSP Path 2 test passed");
 end 
 else begin
  $display("Error: DSP Path 2 test failed");
  $stop;
 end
 p_prev=P;
 carryout_prev=CARRYOUT;
 OPMODE = 8'b00001010;
 A=18'd20;
 B=18'd10;
 C=48'd350;
 D=18'd25;
 CARRYIN=$random;
 BCIN=$random;
 PCIN=$random;
 repeat(3)@(negedge CLK);
  if (BCOUT == 18'ha && M == 36'hc8 && P == p_prev && CARRYOUT == carryout_prev) begin
   $display("DSP Path 3 test passed");
  end 
  else begin
   $display("Error: DSP Path 3 test failed");
   $stop;
  end
 OPMODE = 8'b10100111;
 A=18'd5;
 B=18'd6;
 C=48'd350;
 D=18'd25;
 CARRYIN=$random;
 BCIN=$random;
 PCIN=48'd3000;
 repeat(3)@(negedge CLK);
 if (BCOUT == 18'h6 && M == 36'h1e && P == 48'hfe6fffec0bb1 && PCOUT == 48'hfe6fffec0bb1 && CARRYOUT == 1 && CARRYOUTF == 1) begin
  $display("DSP Path 4 test passed");
 end 
 else begin
  $display("Error: DSP Path 4 test failed");
  $stop;
 end
 $stop;
end
initial begin
 $monitor("P=%h , PCOUT=%h , BCOUT=%h , CARRYOUT=%h , CARRYOUTF=%h , M=%h" , P,PCOUT,BCOUT,CARRYOUT,CARRYOUTF,M);
end
endmodule