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

module fmlbrg_b #(
	parameter fml_depth = 25,
	parameter cache_depth = 14, /* 16kb cache */
	parameter invalidate_bit = 25
) (
	input sys_clk,
	input sys_rst,
	
	input [31:0] wb_adr_i,
	input [2:0] wb_cti_i,
	input [31:0] wb_dat_i,
	output [31:0] wb_dat_o,
	input [3:0] wb_sel_i,
	input wb_cyc_i,
	input wb_stb_i,
	input wb_we_i,
	output wb_ack_o,
	
	output [fml_depth-1:0] fml_adr,
	output fml_stb,
	output fml_we,
	input fml_ack,
	output [3:0] fml_sel,
	output [31:0] fml_do,
	input [31:0] fml_di
);

assign fml_adr = wb_adr_i[fml_depth-1:0];
assign fml_do = wb_dat_i;
assign fml_stb = wb_cyc_i & wb_stb_i;
assign fml_we = wb_we_i;
assign fml_sel = wb_sel_i;  

assign wb_ack_o = fml_ack;
assign wb_dat_o = fml_di;


endmodule
