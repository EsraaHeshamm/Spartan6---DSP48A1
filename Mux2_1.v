module Mux2_1(in0,in1,sel,out);
input[17:0] in0 ,in1; //in0=B in1=Pre_adder_output
input  sel;
output reg [17:0] out;
always@(*) begin
 if(sel) begin
  out=in1;
 end
 else begin
  out=in0;
 end
end
endmodule
