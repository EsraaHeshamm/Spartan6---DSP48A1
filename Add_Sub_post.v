module Add_Sub_post(in0,in1,cin,op,out,cout);
parameter ADD_SUB_SIZE=1;
input [ADD_SUB_SIZE-1:0] in0 , in1;
input op;
input cin;
output reg [ADD_SUB_SIZE-1:0] out;
output reg cout;
always @(*) begin
 if(op==0) begin
  {cout,out}=in0+in1+cin;
 end
 else begin
  {cout,out}=in1-(in0+cin); //z-(x+CIN)
 end
end
endmodule
