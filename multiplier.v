module multiplier(in0,in1,out);
parameter SIZE=1;
input [SIZE-1:0] in0,in1;
output [(SIZE*2)-1:0]out;
assign out = in0*in1 ;
endmodule 