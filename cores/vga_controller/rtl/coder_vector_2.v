module coder_vector_2 #(
	parameter data_a = 2'b11,
	parameter data_b = 2'b00
)(
	input [1:0] data,
	output reg [1:0] out
);




always @(*) begin
	case(data)
		data_a:
			out = 2'b01;
		data_b:	
			out = 2'b00;
		default:
			out = 2'b10;
	endcase
end






endmodule
