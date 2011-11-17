`timescale 1ns/1ps


module vga_tb();


 initial begin
     $dumpfile("vga_tb.vcd");
     $dumpvars(0,vga_tb);
     #700000 $finish;
//     #15000000 $finish;

  end


reg sys_clk;
reg resetin, dcm_rst;


initial sys_clk = 1'b0;
always #10 sys_clk = ~sys_clk;

initial begin
	resetin = 1'b1;
	#600 resetin = 1'b0;  
end

initial begin
	dcm_rst = 1'b1;
	#60 dcm_rst = 1'b0;  
end


wire [10:0] x;
wire [9:0] y;
//g [7-1:0] state;
wire [2:0] rgb_final;



reg fml_stb_ddr, we, sdram_dq_t, fml_brg_ack, fml_brg_we, fml_brg_stb;
reg [1:0] sdram_dqs_mon;
reg [15:0] sdram_dq_mon;
reg [31:0] fml_dr_ddr, fml_dw_ddr, fml_brg_dr, fml_brg_dw;
wire vga_hsync, vga_vsync;
reg [1:0] rot;
initial begin
fml_stb_ddr = 1'b0;
rot = 2'b11;
# 40
fml_brg_stb = 1'b1;
fml_brg_we = 1'b1;
fml_stb_ddr = 1'b1;
sdram_dq_t = 1'b1;
fml_brg_ack = 1'b1;
sdram_dqs_mon = 2'b11;
sdram_dq_mon = 16'habad;
fml_dw_ddr = 32'habadface;
fml_brg_dw = 32'habadface;
fml_dr_ddr = 32'hcafebabe;
fml_brg_dr = 32'hcafebabe;
# 6000
fml_stb_ddr = 1'b0;
fml_brg_stb = 1'b0;
rot = 2'b01;
# 60
rot = 2'b00;
# 60
rot = 2'b10;
# 60
rot = 2'b11;
# 200

rot = 2'b10;
# 60
rot = 2'b00;
# 60
rot = 2'b01;
# 60
rot = 2'b11;

# 200

rot = 2'b10;
# 60
rot = 2'b00;
# 60
rot = 2'b01;
# 60
rot = 2'b11;

# 200

rot = 2'b10;
# 60
rot = 2'b00;
# 60
rot = 2'b01;
# 60
rot = 2'b11;

# 200

rot = 2'b10;
# 60
rot = 2'b00;
# 60
rot = 2'b01;
# 60
rot = 2'b11;

end 




reg clk_;
always @(sys_clk) begin
	if (resetin)
		clk_ <= 1'b0;
	else
		clk_ <= sys_clk;
end



wire clk_50Mhz;
assign clk_50Mhz = sys_clk;

wire sys_rst;
assign sys_rst = resetin;


reg start_stop;

always @(sys_clk) begin
	if (sys_rst)
		start_stop <= 1'b0;
	else
		start_stop <= fml_brg_stb & (fml_brg_dw == 32'habadface) & fml_brg_we;
end
//########################################################
/////////////////////////////////////////////////////
//////////////////////////////////////////////////////
wire [31:0] phase_counter, counter_a, counter_b, pulses_counter;



//wire [10:0] x;
//wire [9:0] y;
wire [19:0] state;

sampling  #(
	.data_size(119),	//20
	.state_size(20),
	.mem_width(5)
)sampling(
	//.clk_fb_main(clk_50Mhz),
	//.clk_50Mhz(clk_50Mhz),//clkin

//	.sys_rst(sys_rst),
	.dcm_rst(dcm_rst),

	.in_dcm(sys_clk),//clkin//

	.rot(rot),

	.start_stop(start_stop),

	// sampling signals
	.clk(clk_),//clk_//sys_clk
		
	.stb(fml_stb_ddr),
//	.we(fml_we_ddr),
	.we(sdram_dq_t),
	.dqs(sdram_dqs_mon),
	.dq(sdram_dq_mon),
	.do(fml_dr_ddr),
	.di(fml_dw_ddr),
	.dr_fml(fml_brg_dr),
	.ack(fml_brg_ack),
	.state(state),	


	.x(x),
	.y(y),

	.phase_counter(phase_counter)
//	.pulses_counter(pulses_counter),
//	.counter_a(counter_a),
//	.counter_b(counter_b)

);







vga_controller vga_cnt(
	.clk(clk_50Mhz), 
	.rst(sys_rst),
	.hsync(vga_hsync),
	.vsync(vga_vsync),
	.x(x),
	.y(y)
);

graph #(
	.samples(20),
	.data_width(119),
	.height(10)
) graph (
	.clk(clk_50Mhz),//sample_clk
	.rst(sys_rst),
	.x(x),
	.y(y),
	.state(state),/////////////////mem_dat_r
	.buf_data(buf_graph),
	.rgb_out(rgb_final)
);





endmodule
