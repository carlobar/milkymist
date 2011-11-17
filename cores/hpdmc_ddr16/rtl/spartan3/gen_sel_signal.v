module gen_sel_signal #(
	parameter LUTs = 2
) (
	input clk,
	input rst,
	input idelay_rst,
	input idelay_ce,
	input idelay_inc,
	output reg done,
	output reg [LUTs-1:0] sel_signal
);

initial
	sel_signal <= {LUTs{1'b0}};


always @(posedge clk) begin
	if(rst | idelay_rst) begin
		sel_signal <= {LUTs{1'b0}};
		done <= 1'b0;
	end else if(idelay_ce & idelay_inc) begin
		sel_signal <= {1'b1,sel_signal[LUTs-1:2],1'b0};
		done <= 1'b1;
	end else if(idelay_ce & (~idelay_inc)) begin
		sel_signal <= {sel_signal[LUTs-1-1:0],1'b0};
		done <= 1'b1;
	end else  begin
		sel_signal <= sel_signal;
		done <= 1'b0;
	end
end

endmodule
