module IN_DDR (
	input D,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output Q1,
	output Q0
);

//wire Q_ff;

flip_flop_d ffD_a(
	.D(D),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);

/*
flip_flop_d ffD(
	.D(Q_ff),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);
*/


flip_flop_d ffD_b(
	.D(D),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);





endmodule
