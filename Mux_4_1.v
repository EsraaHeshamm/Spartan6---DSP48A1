module Mux_4_1(in1,in2,in3,sel,out);
parameter IN1_SIZE=1;
parameter IN2_SIZE=1;
parameter IN3_SIZE=1;
parameter OUT_SIZE=1;
input [IN3_SIZE-1:0] in3; 
input [IN2_SIZE-1:0] in2; 
input [IN1_SIZE-1:0] in1;
input [1:0] sel;
output reg [OUT_SIZE-1:0]out;
always @(*) begin
 case(sel) 
 0:out=0;
 1:out=in1;//mult_product
 2:out=in2;//pout
 3:out=in3;//{d,a,b}
 endcase
end
endmodule
