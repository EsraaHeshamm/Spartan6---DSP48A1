module Add_Sub_pre(in0,in1,operation,out);
parameter ADD_SUB_SIZE=1;
input operation;
input [ADD_SUB_SIZE-1:0] in0 , in1;
output reg [ADD_SUB_SIZE-1:0] out;
always @(*) begin
 if(operation==0) begin
  out=in0+in1;
 end
 else begin
  out=in1-in0;
 end
end
endmodule
