module sampling
#(
	parameter data_size = 18,	// total data bits 
	parameter state_size = 20,	// number of signals
	parameter mem_width = 5,	// depth
	parameter samples = 15		// scale in vga monitor
)
(
//	input   clk_fb_main,
	//input	clk_50Mhz,
	input	in_dcm,
	//input sys_rst,
	input sys_rst,
	input rst_in,

	input [1:0] rot,

	input start_stop,

	// sampling signals
	input clk,
	input stb,
	input we,
	input [1:0] dqs,
	input [15:0] dq,
	input [31:0] do,
	input [31:0] di,
	input [31:0] dr_fml,
	input	ack,
	output [state_size-1:0] state,
	output reg [state_size-1:0] buf_graph,

	output [31:0] phase_counter,
	//output [31:0] pulses_counter,
	//output reg [31:0] counter_a,
	//output reg [31:0] counter_b,

	input [10:0] x_in
	//input [9:0] y

);

////////////////////////////////////////////////////////////////////
///////////////////////  DCM  /////////////////////////////

wire sample_clk_dcm, sample_clk_dcm_n, sample_clk, sample_clk_n;
//wire clk_fb, clk_fb_dcm;
wire psen, psincdec,psdone, locked, psclk;

reg [10:0] x;
reg dcm_rst;


DCM_SP #(
	.CLKDV_DIVIDE(2.0), // 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
	.CLKFX_DIVIDE(2), // 1 to 32
	.CLKFX_MULTIPLY(4), // 2 to 32

	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(25.0),
	.CLKOUT_PHASE_SHIFT("VARIABLE"),
	.CLK_FEEDBACK("1X"),
	.DESKEW_ADJUST("SOURCE_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
	.PHASE_SHIFT(0),//128
	.STARTUP_WAIT("TRUE")
) clkgen_sample (
	.CLK0(sample_clk_dcm),//clk_fb_dcm
	.CLK90(),
	.CLK180(sample_clk_dcm_n),
	.CLK270(),

	.CLK2X(),//ram_clk
	.CLK2X180(),//ram_clk_n

	.CLKDV(),
	.CLKFX(),
	.CLKFX180(),//sample_clk_dcm_n
	.LOCKED(locked),
	.CLKFB(sample_clk),//sys_clk_fb//clk_fb//clk_fb_dcm//
	.CLKIN(in_dcm),
	.RST(dcm_rst),

	.PSEN(psen),
	.PSINCDEC(psincdec),
	.PSDONE(psdone),
	.PSCLK(psclk)//in_dcm

);

BUFG b_sample(
	.I(sample_clk_dcm),
	.O(sample_clk)
//,	.T(1'b0)
);

BUFG b_sample_n(
	.I(sample_clk_dcm_n),
	.O(sample_clk_n)
);


/*
BUFT b_fb(
	.I(clk_fb_dcm),
	.O(clk_fb),
	.T(1'b0)
);
*/

/*BUFT b_sample_n(
	.I(sample_clk_dcm_n),
	.O(sample_clk_n),
	.T(1'b0)

);
*/


//-------------------------------------------------
//		reset


reg [19:0] rst_cnt;

initial rst_cnt <= 20'h0000a;
//initial sys_rst <= 1'b1;
always @(posedge in_dcm) begin
	if(rst_in)
		rst_cnt <= 20'h0000a;
	else if(rst_cnt != 20'd0)
		rst_cnt <= rst_cnt - 20'd1;
	dcm_rst <= (rst_cnt < 20'd4) & (rst_cnt != 20'd0);
end





phase_ctl phase_ctl(
	.clk(sample_clk),//in_dcm
	.rst(sys_rst),
	.rot(rot),
	.locked(locked),
	.psen(psen),
	.psincdec(psincdec),
	.psdone(psdone),
	.psclk(psclk),
	.counter(phase_counter)
	//.pulses_counter(pulses_counter)
);



//---------------------------------------------------
// 		Sample sample_clk
wire sample_delay;

DDR_reg clock_sample (
	.Q(sample_delay),
	.C0(sample_clk),
	.C1(sample_clk_n),
	.CE(1'b1),
	.D0(1'b1),
	.D1(1'b0),
	.R(sys_rst),
	.S(1'b0)
);



//-----------------------------------------------------
// 		Input Buffer

wire [data_size-1:0] mem_dat_r_p, mem_dat_r_n, data_input, mem_dat_r;

wire [data_size-1:0] mem_dat_w_a, mem_dat_w_b;





assign data_input = {ack, dr_fml, sample_delay, clk, stb , we, dqs, dq, do, di};

DDR_in_buf #(
	.size(data_size)
)
DDr_buffer
(
	.D(data_input),
	.Q0(mem_dat_w_a),
	.C0(sample_clk),
	.C1(sample_clk_n),
	.CE(1'b1),
	.R(sys_rst),
	.S(1'b0),
	.Q1(mem_dat_w_b)
);





always @(posedge sample_clk) begin
	if(sys_rst)
		x <= 11'b0;
	else
		x <= x_in;
end






//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//################ test clks ##########################

//reg [31:0] counter_a, counter_b;
/*
always @(posedge in_dcm) begin
	if (sys_rst) 
		counter_a <= 32'd0;
	else if(counter_a < 100)
		counter_a <= counter_a + 1;
	else
		counter_a <= counter_a;
end

always @(posedge sample_clk) begin
	if (sys_rst) 
		counter_b <= 32'd0;
	else if(counter_a < 100)
		counter_b <= counter_b + 1;
	else
		counter_b <= counter_b;
end
*/


wire clk_mem, stb_mem, we_mem,  ack_mem;

wire [1:0] dqs_mem;
wire [15:0] dq_mem;
wire [31:0] do_mem, di_mem, dr_fml_mem;


wire enable_sampling;


//condicion de inicio y parada dada por stb
/*
always @(posedge sample_clk) begin
	if(start_stop)
		enable_sampling <= 1'b1;
	else
		enable_sampling <= 1'b0;
end
*/
assign enable_sampling = start_stop;




//----------------------------------------------------
//		Coders

wire [1:0] clk_, stb_, we_, dqs_, dq_, di_, do_, dr_fml_, ack_;
wire [1:0] sample_clk_;


coder coder_clk(
	.data(clk_mem),
	.out(clk_)
);

coder coder_clk_sample(
	.data(sample_delay_mem),//clk_50Mhz
	.out(sample_clk_)
);

coder coder_stb(
	.data(stb_mem),
	.out(stb_)
);

coder coder_we(
	.data(we_mem),
	.out(we_)
);

coder coder_ack(
	.data(ack_mem),
	.out(ack_)
);

coder_vector_2 coder_dqs(
	.data(dqs_mem),
	.out(dqs_)
);


coder_vector coder_dq(
	.data(dq_mem),
	.out(dq_)
);

coder_vector_32 coder_di(
	.data(di_mem),
	.out(di_)
);

coder_vector_32 coder_do(
	.data(do_mem),
	.out(do_)
);

coder_vector_32 coder_dr_fml(
	.data(dr_fml_mem),
	.out(dr_fml_)
);

assign state = {ack_, dr_fml_, sample_clk_, clk_, stb_, we_, dqs_, dq_, do_, di_};


always @(posedge sample_clk) begin
	if(sys_rst)
		buf_graph <= {state_size{1'b0}};
	else 
		buf_graph <= state;
end






`ifndef SIMULATION_DDR

	assign ack_mem 		= mem_dat_r[118] ;
	assign dr_fml_mem 	= mem_dat_r[117:86] ;
	assign sample_delay_mem = mem_dat_r[85] ;
	assign clk_mem 		= mem_dat_r[84] ;
	assign stb_mem 		= mem_dat_r[83] ;
	assign we_mem 		= mem_dat_r[82] ;
	assign dqs_mem 		= mem_dat_r[81:80] ;
	assign dq_mem 		= mem_dat_r[79:64] ;
	assign do_mem 		= mem_dat_r[63:32] ;
	assign di_mem 		= mem_dat_r[31:0] ;

`else

	assign ack_mem 		= mem_dat_w_a[118] ;
	assign dr_fml_mem 	= mem_dat_w_a[117:86] ;
	assign sample_delay_mem = mem_dat_w_a[85] ;
	assign clk_mem 		= mem_dat_w_a[84] ;
	assign stb_mem 		= mem_dat_w_a[83] ;
	assign we_mem 		= mem_dat_w_a[82] ;
	assign dqs_mem 		= mem_dat_w_a[81:80] ;
	assign dq_mem 		= mem_dat_w_a[79:64] ;
	assign do_mem 		= mem_dat_w_a[63:32] ;
	assign di_mem 		= mem_dat_w_a[31:0] ;
`endif


`ifdef SIMULATION_DDR

wire clk_mem_w, stb_mem_w, we_mem_w,  ack_mem_w, sample_clk_mem_w;
wire [1:0] dqs_mem_w;
wire [15:0] dq_mem_w;
wire [31:0] do_mem_w, di_mem_w, dr_fml_mem_w;


	assign ack_mem_w 		= mem_dat_w_a[118] ;
	assign dr_fml_mem_w 		= mem_dat_w_a[117:86] ;
	assign sample_delay_mem_w 	= mem_dat_w_a[85] ;
	assign clk_mem_w 		= mem_dat_w_a[84] ;
	assign stb_mem_w 		= mem_dat_w_a[83] ;
	assign we_mem_w 		= mem_dat_w_a[82] ;
	assign dqs_mem_w 		= mem_dat_w_a[81:80] ;
	assign dq_mem_w 		= mem_dat_w_a[79:64] ;
	assign do_mem_w 		= mem_dat_w_a[63:32] ;
	assign di_mem_w 		= mem_dat_w_a[31:0] ;

`endif




// ------------------------------------------------------------------
//		 Write/read address

reg [10:0] counter;
reg inc_addr_r;

wire half_period;

reg h_p_delay_1, h_p_delay_2;


reg mem_we;
reg [mem_width-1:0] mem_adr_w, mem_adr_r;

wire [mem_width-1:0] mem_adr;



reg valid_address_r, last_address_r, rst_address;
reg valid_address_w, last_address_w;

always @(posedge sample_clk) begin
	if(sys_rst | rst_address)
		mem_adr_r <= {mem_width-1{1'b0}};
	else if(inc_addr_r & valid_address_r)
		mem_adr_r <= mem_adr_r + 1'b1;
	else if(inc_addr_r & last_address_r)
		mem_adr_r <= mem_adr_r ;
end

always @(posedge sample_clk) begin
	if(sys_rst) begin
		valid_address_w <= 0;
		last_address_w 	<= 0;
		valid_address_r <= 0;
		last_address_r 	<= 0;
		rst_address 	<= 0;		
	end else begin
		valid_address_r	<= (mem_adr_r < {mem_width-1{1'b1}});
		last_address_r 	<= (mem_adr_r == {mem_width-1{1'b1}});
		rst_address 	<=  (x == 11'd0) | (x > 11'd1280);
		valid_address_w <= (mem_adr_w < {mem_width-1{1'b1}});
		last_address_w 	<= (mem_adr_w == {mem_width-1{1'b1}});

	end
end

always @(posedge sample_clk) begin
	if(sys_rst | rst_address) begin
		mem_we <= 1'b0;
		mem_adr_w <= {mem_width-1{1'b0}};
	end else if(enable_sampling) begin
		if (valid_address_w) begin
			mem_we <= 1'b1;
			mem_adr_w <= mem_adr_w + 1;
		end
		else if (last_address_w) begin
			mem_we <= 1'b0;
			mem_adr_w <= mem_adr_w;
		end
		else begin
			mem_we <= 1'b0;
			mem_adr_w <= {mem_width-1{1'b0}}; 
		end
	end else begin
		mem_we <= 1'b0;
		mem_adr_w <= {mem_width-1{1'b0}}; 
	end
end

// counter that increment address on reads
always @(posedge sample_clk) begin
	if (sys_rst | rst_address) begin
		counter <= {11{1'b0}};
		inc_addr_r <= 1'b0;
	end else if(counter > 1280/samples) begin
		counter <= {11{1'b0}};
		inc_addr_r <= 1'b1;		
	end else begin
		counter <= counter+11'd1;
		inc_addr_r <= 1'b0;	end
end

assign half_period = counter <= 1280/samples/2;

always @(posedge sample_clk) begin
	if(sys_rst) begin// | (x == 0)
		h_p_delay_1 <=1'b0;
		h_p_delay_2 <=1'b0;
	end
	else begin
		h_p_delay_1 <= half_period;
		h_p_delay_2 <= h_p_delay_1;
	end
end

assign mem_adr = mem_we ? mem_adr_w: mem_adr_r;
//assign mem_adr = ( & {mem_width-1{mem_we}}) | (mem_adr_r & {mem_width-1{~mem_we}});
/*always @(posedge sample_clk) begin
	if (sys_rst)
		mem_adr <= {mem_width{1'b0}};
	else begin
		if (mem_we)
			mem_adr <= mem_adr_w;
		else
			mem_adr <= mem_adr_r;
	end
end
*/



//-------------------------------------------------------------------
//   Memory

memory#(
	.width(mem_width),
	.mem_size(119)
) buffer_posedge(
	.clk(sample_clk),
	.mem_dat_i(mem_dat_w_a),
	.mem_dat_o(mem_dat_r_p),
	.mem_we(mem_we),
	.mem_adr(mem_adr)
);

memory#(
	.width(mem_width),
	.mem_size(119)
) buffer_negedge(
	.clk(sample_clk_n),
	.mem_dat_i(mem_dat_w_b),
	.mem_dat_o(mem_dat_r_n),
	.mem_we(mem_we),
	.mem_adr(mem_adr)
);

reg [data_size-1:0] mem_dat_r_n_delay;




always @(posedge sample_clk) begin
	mem_dat_r_n_delay <= mem_dat_r_n;
end




assign mem_dat_r = h_p_delay_2 ? mem_dat_r_p : mem_dat_r_n_delay;

/*
DDR_buf #(
	.size(data_size)
)
DDr_buffer
(
	.D0(mem_dat_r_p),
	.D1(mem_dat_r_n),
	.C0(h_p_delay_2 ),
	.C1(~h_p_delay_2 ),
	.CE(1'b1),
	.R(sys_rst),
	.S(1'b0),
	.Q(mem_dat_r)
);
*/





endmodule


