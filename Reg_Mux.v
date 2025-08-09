module Reg_Mux(clk ,rst , sel, CE , in , out);
parameter REG_SIZE=1;
parameter REST_TYPE="SYNC";
input clk , rst , CE , sel;
input [REG_SIZE-1:0] in;
output reg [REG_SIZE-1:0] out;
reg [REG_SIZE-1:0] out_reg;


always@(*) begin
  if(sel==0) begin
   out=in;
  end
  else begin
   out=out_reg;
  end
 end

generate
 
 if(REST_TYPE=="SYNC" ) begin
  always @(posedge clk ) begin
   if(rst) begin
    out_reg<=0;
   end
   else if(CE) begin
    out_reg<=in;
   end
  end
 end
 else if (REST_TYPE=="ASYNC" ) begin
  always@(posedge clk or posedge rst) begin
   if(rst) begin
    out_reg<=0;
   end
   else if(CE) begin
    out_reg<=in;
   end
  end	
 end
endgenerate
endmodule




