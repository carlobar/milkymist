module DDR_in_reg (
	input D,
	output Q0,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output Q1
);


///////////////////////////////////////////////

flip_flop_d ffD0(
	.D(D),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);


flip_flop_d ffD1(
	.D(D),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);



endmodule
