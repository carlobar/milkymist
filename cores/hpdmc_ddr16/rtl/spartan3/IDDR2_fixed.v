module IDDR2_fixed #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT_Q0 = 1'b0,
	parameter INIT_Q1 = 1'b0,
	parameter SRTYPE = "ASYNC"
)(
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
/*


//////////////////////////////////
flip_flop_d ffD(
	.D(Q_ff),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);

flip_flop_d ffD_a(
	.D(D),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);

flip_flop_d ffD_b(
	.D(D),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q_ff)
);

*/
/*
flip_flop_d ffD(
	.D(Q_ff),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);
*/
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr (
	.Q0(Q0),
	.Q1(Q1),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D),
	.R(R),
	.S(S)
);

endmodule
