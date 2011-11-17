module graph#(
	parameter samples = 15,
	parameter height = 10'd10,
	parameter data_width = 14
) (
	input clk,
	input  rst,
	input [10:0] x,
	input [9:0] y,
	input [data_width-1:0] state,
	input [data_width-1:0] buf_data,
	output [2:0] rgb_out
);


//reg print;
wire [2:0] rgb_a, rgb_b, rgb_c, rgb_d, rgb_e, rgb_f, rgb_g, rgb_h, rgb_i, rgb_j;


wire change_a, change_b, change_c, change_d, change_e, change_f, change_g, change_h, change_i, change_j;

assign change_j = |(state[19:18] ^ buf_data[19:18]) ;

assign change_i = |(state[17:16] ^ buf_data[17:16]) ;

assign change_a = |(state[15:14] ^ buf_data[15:14]) ;
assign change_b = |(state[13:12] ^ buf_data[13:12]) ;
assign change_c = |(state[11:10] ^ buf_data[11:10]) ;
assign change_d = |(state[9:8] ^ buf_data[9:8]) ;
assign change_e = |(state[7:6] ^ buf_data[7:6]) ;
assign change_f = |(state[5:4] ^ buf_data[5:4]) ;
assign change_g = |(state[3:2] ^ buf_data[3:2]) ;
assign change_h = |(state[1:0] ^ buf_data[1:0]) ;
//genvar i;
//generate


// sample clk
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(10)
	) pixel_a(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[15:14]),
	.change(change_a),
	.rgb(rgb_a)
	);

// clk
//	for(i = 0; i<samples+1; i=i+1) begin: pixel_gen
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(40)
	) pixel_b(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[13:12]),
	.change(change_b),
	.rgb(rgb_b)
	);
//	end

///endgenerate


// stb
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(70)
	) pixel_c(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[11:10]),
	.change(change_c),
	.rgb(rgb_c)
	);

// we
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(100)
	) pixel_d(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[9:8]),
	.change(change_d),
	.rgb(rgb_d)
	);


// dqs
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(130)
	) pixel_e(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[7:6]),
	.change(change_e),
	.rgb(rgb_e)
	);

// dq
	pixel_vector #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(160)
	) pixel_f(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[5:4]),
	.change(change_f),
	.rgb(rgb_f)
	);


// do
	pixel_vector #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(190)
	) pixel_g(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[3:2]),
	.change(change_g),
	.rgb(rgb_g)
	);


// di
	pixel_vector #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(220)
	) pixel_h(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[1:0]),
	.change(change_h),
	.rgb(rgb_h)
	);


// dr_fmlr
	pixel_vector #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(250)
	) pixel_i(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[17:16]),
	.change(change_i),
	.rgb(rgb_i)
	);

// sample clk
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(280)
	) pixel_j(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[19:18]),
	.change(change_j),
	.rgb(rgb_j)
	);


assign rgb_out = rgb_a | rgb_b | rgb_c | rgb_d | rgb_e | rgb_f | rgb_g | rgb_h | rgb_i | rgb_j;

endmodule
