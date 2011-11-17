module delay_unit_b #(
	parameter LUTs = 2
	)(
	input in,
	input [LUTs-1:0] sel,
	output out
);

wire [LUTs:0] data;
assign out = data[LUTs];
assign data[0] = 1'b0;



genvar i;
generate
	for (i=0; i< LUTs; i=i+1) begin: LUTs_gen
		LUT LUT_i( .a(in), .b(data[i]), .sel(sel[i]), .out(data[i+1]) );
	end
endgenerate



endmodule
