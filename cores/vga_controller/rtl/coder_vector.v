module coder_vector #(
	parameter size = 16,
	parameter data_a = 16'habad,
	parameter data_b = 16'hface
)(
	input [15:0] data,
	output reg [1:0] out
);




always @(*) begin
	case(data)
		16'b0:
			out = 2'b00;
		data_a:
			out = 2'b01;
		data_b:	
			out = 2'b10;
		default:
			out = 2'b11;
	endcase
end






endmodule
