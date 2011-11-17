module coder_vector_32 #(
	parameter size = 32,
	parameter data_a = 32'habadface

)(
	input [31:0] data,
	output reg [1:0] out
);




always @(*) begin

	if (data == data_a)
		out = 2'b00;
	else if ((data[15:0] == 16'habad) | (data[31:16] == 16'habad))
		out = 2'b01;
	else if (data[15:0] == 16'hface | (data[31:16] == 16'hface))
		out = 2'b10;
	else
		out = 2'b11;
/*
	case(data)
		32'b0:
			out = 2'b00;
		data_a:
			out = 2'b01;
		default:
			out = 2'b11;
	endcase
*/

end






endmodule
