module DDR_buf #(
	parameter size = 16
)
(
	input [size-1:0] D0,
	input [size-1:0] D1,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output [size-1:0] Q
);


genvar i;
generate

	for(i = 0; i<size; i=i+1) begin: ddr_gen
DDR_reg ddr_reg(
	.D0(D0[i]),
	.D1(D1[i]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.R(R),
	.S(S),
	.Q(Q[i])
);
	end

endgenerate



endmodule
