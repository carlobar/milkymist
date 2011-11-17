module DDR_in_buf #(
	parameter size = 16
)
(
	input [size-1:0] D,
	output [size-1:0] Q0,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output [size-1:0] Q1
);


genvar i;
generate

	for(i = 0; i<size; i=i+1) begin: ddr_gen
DDR_in_reg ddr_reg(
	.D(D[i]),
	.Q0(Q0[i]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.R(R),
	.S(S),
	.Q1(Q1[i])
);
	end

endgenerate



endmodule
