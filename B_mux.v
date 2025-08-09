module B_mux(b,bcin,out);
parameter B_SEL ="DIRECT";
input[17:0] b ,bcin;
output reg [17:0] out; 
always@(*) begin
 if(B_SEL =="DIRECT") begin
  out=b;
 end
 else if (B_SEL =="CASCADE") begin
  out=bcin;    
 end
 else begin
  out=0;
 end
end
endmodule
