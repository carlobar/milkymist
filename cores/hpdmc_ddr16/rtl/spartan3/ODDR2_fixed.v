module ODDR2_fixed #(
	parameter DDR_ALIGNMENT = "NONE",
	parameter INIT = 1'b0,
	parameter SRTYPE = "ASYNC"
)(
	input D0,
	input D1,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output Q
);

//wire D_ff;

//////////////////////////////////
/*
flip_flop_d ffD(
	.D(D1),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(D_ff)
);
*/
/*

flip_flop_d ffD0(
	.D(D0),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);


flip_flop_d ffD1(
	.D(D_ff),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);

//assign Q = (C0 & ~C1) ? Q0 : 1'bz;
//assign Q = (~C0 & C1) ? Q1 : 1'bz;




always @(*) begin
	case ({C1,C0})
		2'b00:
			Q = Q0;
		2'b01:
			Q = Q0;
		2'b10:
			Q = Q1;
		2'b11:
			Q = Q1;
	endcase
end
*/

ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr2_ (
	.Q(Q),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0),
	.D1(D1),//D_ff
	.R(R),
	.S(S)
);


endmodule
