module input_delay#(
	parameter length = 16,
	parameter LUTs = 2
)(
	input clk,
	input rst,
	input [length-1:0] data_in,
	output [length-1:0] data_out,
	input idelay_rst,
	input idelay_ce,
	input idelay_inc
);



reg [LUTs-1:0] sel;


genvar i;
generate
	for (i=0; i < length; i=i+1) begin: delay_gen
		delay_unit #(.LUTs(LUTs)) n(data_in[i], sel, data_out[i]);
	end
endgenerate


always @(posedge clk) begin
	if(rst | idelay_rst)
		sel <= {LUTs{1'b0}};
	else if(idelay_ce & idelay_inc)
		sel <= {1'b0,sel[LUTs-1-1-1:0],1'b1};
	else if(idelay_ce & (~idelay_inc))
		sel <= {1'b0,sel[LUTs-1:1]};
end




endmodule
