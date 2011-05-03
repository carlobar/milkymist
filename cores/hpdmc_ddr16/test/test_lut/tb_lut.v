`timescale 1ns / 1ps

module tb_lut();

initial begin
     $dumpfile("tb_lut.vcd");
     $dumpvars(0,tb_lut);

     # 300 $finish;
  end

reg	clk,rst;


initial clk = 1'b0;
always #10 clk = ~clk;

initial begin
	rst = 1'b1;
	@(posedge clk);
	#1 rst = 1'b0;
end

reg a,b,sel;
wire out;


LUT lut_test(	.a(a),
		.b(b),
		.sel(sel),
		.out(out)
);

initial begin
a = 1;
b = 0;
sel = 0;
#(15)
sel = 1;
#(15)
a = 0;
b = 1;
#(15)

sel = 0;
#(15)
a = 1;
end



endmodule
