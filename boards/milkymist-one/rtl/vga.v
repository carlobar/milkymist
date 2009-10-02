/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free and excepted software; you can use it, redistribute it
 * and/or modify it under the terms of the Exception General Public License as
 * published by the Exception License Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the Exception General Public License for more
 * details.
 *
 * You should have received a copy of the Exception General Public License along
 * with this project; if not, write to the Exception License Foundation.
 */

`include "setup.v"

module vga #(
	parameter csr_addr = 4'h0,
	parameter fml_depth = 26
) (
	input sys_clk,
	input sys_rst,
	
	/* Configuration interface */
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output [31:0] csr_do,
	
	/* Framebuffer FML 4x64 interface */
	output [fml_depth-1:0] fml_adr,
	output fml_stb,
	input fml_ack,
	input [63:0] fml_di,
	
	/* VGA pads */
	output vga_psave_n,
	output vga_hsync_n,
	output vga_vsync_n,
	output vga_sync_n,
	output vga_blank_n,
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b,
	output vga_clkout
);

wire vga_clk_dcm;
wire vga_clk_n_dcm;
wire vga_clk;
wire vga_clk_n;

DCM_SP #(
	.CLKDV_DIVIDE(1.5),		// 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5

	.CLKFX_DIVIDE(8),		// 1 to 32
	.CLKFX_MULTIPLY(2),		// 2 to 32

	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(`CLOCK_PERIOD),
	.CLKOUT_PHASE_SHIFT("VARIABLE"),
	.CLK_FEEDBACK("1X"),
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
	.PHASE_SHIFT(0),
	.STARTUP_WAIT("FALSE")
) clkgen_dqs (
	.CLK0(),
	.CLK90(),
	.CLK180(),
	.CLK270(),

	.CLK2X(),
	.CLK2X180(),

	.CLKDV(),
	.CLKFX(vga_clk_dcm),
	.CLKFX180(vga_clk_n_dcm),
	.LOCKED(),
	.CLKFB(vga_clk),
	.CLKIN(sys_clk),
	.RST(sys_rst),

	.PSEN(1'b0)
);
AUTOBUF b_p(
	.I(vga_clk_dcm),
	.O(vga_clk)
);
AUTOBUF b_n(
	.I(vga_clk_n_dcm),
	.O(vga_clk_n)
);

ODDR2 #(
	.DDR_ALIGNMENT("NONE"),
	.INIT(1'b0),
	.SRTYPE("SYNC")
) clock_forward (
	.Q(vga_clkout),
	.C0(vga_clk),
	.C1(vga_clk_n),
	.CE(1'b1),
	.D0(1'b1),
	.D1(1'b0),
	.R(1'b0),
	.S(1'b0)
);

vgafb #(
	.csr_addr(csr_addr),
	.fml_depth(fml_depth)
) vgafb (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	
	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	
	.fml_adr(fml_adr),
	.fml_stb(fml_stb),
	.fml_ack(fml_ack),
	.fml_di(fml_di),
	
	.vga_clk(vga_clk),
	.vga_psave_n(vga_psave_n),
	.vga_hsync_n(vga_hsync_n),
	.vga_vsync_n(vga_vsync_n),
	.vga_sync_n(vga_sync_n),
	.vga_blank_n(vga_blank_n),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b)
);

endmodule
