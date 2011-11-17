module coder(
	input data,
	output [1:0] out
);

assign out[1] = 1'b0;
assign out[0] = data;

endmodule
