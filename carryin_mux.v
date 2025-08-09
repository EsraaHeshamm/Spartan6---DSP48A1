module carryin_mux(carryin,opmode5,out);
parameter CARRYINSEL_MUX ="OPMODE5";
input carryin ,opmode5; 
output reg out;
always@(*) begin
 if(CARRYINSEL_MUX =="OPMODE5") begin
  out=opmode5;
 end
 else if (CARRYINSEL_MUX =="CARRYIN") begin
  out=carryin;    
 end
 else begin
  out=0;
 end
end
endmodule