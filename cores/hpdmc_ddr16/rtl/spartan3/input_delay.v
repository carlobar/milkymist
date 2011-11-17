module input_delay#(
	parameter length = 16,
	parameter LUTs = 2
)(
	input clk,
	input rst,
	input idelay_rst,
	input idelay_ce,
	input idelay_inc,
	output idelay_done,
	input [length-1:0] data_in,
	output [length-1:0] data_out

);

//wire [length-1:0] data_output;
//wire [length-1:0] data_input;

wire [LUTs-1:0] sel;

gen_sel_signal #(
	.LUTs(LUTs)
)
gen_sel (
	.clk(clk),
	.rst(rst),
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc),
	.sel_signal(sel),
	.done(idelay_done)

);



genvar i;
generate
	for (i=0; i < length; i=i+1) begin: delay_gen
		delay_unit #(.LUTs(LUTs)) delay_i (data_in[i], sel, data_out[i]);
	end
endgenerate



endmodule