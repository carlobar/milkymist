module LUT(a,b,sel,out);


input a;
input b;
input sel;
output out;	
reg out;
always @(a or b or sel) begin
	case(sel)
		1'b0: 
			out = a;
		1'b1:
			out = b;
	endcase
end


endmodule
