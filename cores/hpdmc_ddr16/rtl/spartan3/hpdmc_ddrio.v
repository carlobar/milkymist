/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_ddrio(
	input sys_clk,
	input sys_clk_n,
	input dqs_clk,
	input dqs_clk_n,
	
	input rst,

	input direction,
	input direction_r,
	input [3:0] mo,
	input [31:0] do,
	output [31:0] di,
	
	output [1:0] sdram_dqm,
	inout [15:0] sdram_dq,
	inout [1:0] sdram_dqs,
	
	input idelay_rst,
	input idelay_ce,
	input idelay_inc,
	input idelay_cal,
	
	output sdram_dq_t_o,
	output [15:0] sdram_dq_mon
);


wire [15:0] sdram_dq_t;
wire [15:0] sdram_dq_out;
wire [15:0] sdram_dq_in;
wire [15:0] sdram_dq_in_delayed;


assign sdram_dq_t_o = sdram_dq_t;
assign sdram_dq_mon = sdram_dq_out;
/******/
/* DQ */
/******/


hpdmc_iobuf16 iobuf_dq(
	.T(sdram_dq_t),
	.I(sdram_dq_out),
	.O(sdram_dq_in),
	.IO(sdram_dq)
);


hpdmc_oddr16 oddr_dq_t(
	.Q(sdram_dq_t),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0({16{~direction_r}}),
	.D1({16{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_oddr16 oddr_dq(
	.Q(sdram_dq_out),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(do[31:16]),
	.D1(do[15:0]),
	.R(1'b0),
	.S(1'b0)
);

input_delay #(
	.length(16),
	.LUTs(300)
) delay(
	.clk(sys_clk),
	.rst(rst),
	.data_in(sdram_dq_in),
	.data_out(sdram_dq_in_delayed),
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc)
);




hpdmc_iddr16 iddr_dq(
	.Q0(di[15:0]),
	.Q1(di[31:16]),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D(sdram_dq_in_delayed),
	.R(1'b0),
	.S(1'b0)
);


//assign sdram_dq_in_delayed_buf = direction_r ? sdram_dq_in_delayed : 16'bz;


/*
bufg_n_bit #(
	.size(16)
	) buffer_16_bit(
	.in(sdram_dq_in_delayed),
	.out(sdram_dq_in_delayed_buf)
);
*/

/*******/
/* DQM */
/*******/

hpdmc_oddr2 oddr_dqm(
	.Q(sdram_dqm),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(mo[3:2]),
	.D1(mo[1:0]),
	.R(1'b0),
	.S(1'b0)
);

/*******/
/* DQS */
/*******/

wire [1:0] sdram_dqs_t;
wire [1:0] sdram_dqs_out;

wire q1, q2;
assign q1 = sdram_dqs_t[0] ~^ direction_r;

/*
BUFG buffer_q1 (.O (q2),

                    .I (sdram_dqs_out && {2{q1}}));
*/
hpdmc_obuft2 obuft_dqs(
	.T(sdram_dqs_t),
	.I(sdram_dqs_out),
	.O(sdram_dqs)
);


hpdmc_oddr2 oddr_dqs_t(
	.Q(sdram_dqs_t),
	.C0(sys_clk),//dqs
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0({2{~direction_r}}),
	.D1({2{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);
/*
wire dat1, out_1, out_2;
assign dat1 = direction_r ^ q1;


flip_flop_d ffD1(
	.D(dat1),
	.clk(dqs_clk),
	.ce(1'b1),
	.reset(1'b0),
	.set(1'b0),
	.Q(out_1)
);
*/
/*
flip_flop_d ffD2(
	.D(out_1),
	.clk(dqs_clk),
	.ce(1'b1),
	.reset(1'b0),
	.set(1'b0),
	.Q(out_2)
);
*/
hpdmc_oddr2 oddr_dqs(
	.Q(sdram_dqs_out),
	.C0(dqs_clk),//dqs
	.C1(dqs_clk_n),
	.CE(1'b1),
	.D0(2'b11),// & ~{2{q1}} & ~{2{out_1}}),//&& {2{~direction_r}} 
	.D1(2'b00),
	.R(1'b0),
	.S(1'b0)
);

endmodule
