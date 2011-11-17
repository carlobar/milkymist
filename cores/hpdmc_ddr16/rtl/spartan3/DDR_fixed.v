module DDR_fixed (
	input D0,
	input D1,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output reg Q
);

wire D_ff, Q0, Q1;

//////////////////////////////////
flip_flop_d ffD(
	.D(D1),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(D_ff)
);


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





//////////////////////////////////////////////////////
////// generate sel signal ////////

wire q_1, q_2, sel;

flip_flop_d reg_1(
	.D(~q_2),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(q_1)
);


flip_flop_d reg_2(
	.D(q_1),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(q_2)
);

assign sel = q_1 ~^ q_2;
/////////////////////////////////////////////////




always @(*) begin
	case (sel)
		1'b0:
			Q = Q0;
		1'b1:
			Q = Q1;
	endcase
end

endmodule
