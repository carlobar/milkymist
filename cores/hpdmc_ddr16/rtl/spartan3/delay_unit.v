module delay_unit #(
	parameter LUTs = 2
	)(
	input in,
	input [LUTs-1:0] sel,
	output out
);

wire [LUTs:0] data;
//wire [LUTs-1:0] sel;
assign out = data[LUTs];

genvar i;
generate
	for (i=0; i< LUTs; i=i+1) begin: LUTs_gen
		LUT n(in, data[i], sel[i], data[i+1]);
	end
endgenerate



endmodule
