`include "setup.v"
`include "system_conf.v"


module soc(
	input clkin,
	input resetin
);


//------------------------------------------------------------------
// Clock and Reset Generation
//------------------------------------------------------------------
wire flash_reset_n;
wire sys_clk;
wire sys_clk_50Mhz;
wire clk_50Mhz;
wire sys_clk_100Mhz;
wire clk_100Mhz;
wire sys_clk_n;
wire hard_reset;
wire reset_button = resetin;
wire ddr_reset;

// instanciar el modulo DCM_SP

DCM_SP #(
	.CLKDV_DIVIDE(`CLKDV_DIVIDE), // 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5

	.CLKFX_DIVIDE(`CLKFX_DIVIDE), // 1 to 32
	.CLKFX_MULTIPLY(`CLKFX_MULTIPLY), // 2 to 32

	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(20),
	.CLKOUT_PHASE_SHIFT("NONE"),
	.CLK_FEEDBACK("NONE"),
	.DESKEW_ADJUST("SOURCE_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
//	.FACTORY_JF(16'hF0F0),
	.PHASE_SHIFT(0),
	.STARTUP_WAIT("TRUE")
) clkgen_sys (
	.CLK0(),//sys_clk_50Mhz
	.CLK90(),
	.CLK180(),
	.CLK270(),

	.CLK2X(),//ram_clk//sys_clk_100Mhz
	.CLK2X180(),//ram_clk_n

	.CLKDV(),
	.CLKFX(sys_clk_dcm),
	.CLKFX180(sys_clk_n_dcm),
	.LOCKED(),
	.CLKFB(),//sys_clk_fb//clk_50Mhz
	.CLKIN(clkin),
	.RST(resetin)//1'b0
);

BUFG b_sys_clk(
	.I(sys_clk_dcm),
	.O(sys_clk)
);

BUFG b_sys_clk_n(
	.I(sys_clk_n_dcm),
	.O(sys_clk_n)
);


assign clk_50Mhz = clkin;
/* Synchronize the reset input */

reg rst1;

always @(posedge sys_clk) rst1 <= reset_button | hard_reset;

reg [19:0] rst_debounce;
reg sys_rst;
reg dcm_rst;
initial rst_debounce <= 20'h01ff0;
initial sys_rst <= 1'b1;
always @(posedge sys_clk) begin
	if(rst1 | hard_reset)
		rst_debounce <= 20'h01ff0;
	else if(rst_debounce != 20'd0)
		rst_debounce <= rst_debounce - 20'd1;
	sys_rst <= rst_debounce != 20'd0;
	dcm_rst <= rst_debounce > 20'h01fea;
end


// se libera flash_reset_n despes de 128 ciclos del reloj
reg [7:0] flash_rstcounter;
initial flash_rstcounter <= 8'd0;
always @(posedge sys_clk) begin
	if(rst1)
		flash_rstcounter <= 8'd0;
	else if(~flash_rstcounter[7])
		flash_rstcounter <= flash_rstcounter + 8'd1;
end


assign flash_reset_n = flash_rstcounter[7];
assign ddr_reset = ~flash_reset_n;




//`define SDRAM_DEPTH 25

/*
reg [`SDRAM_DEPTH-1:0] fml_adr_bus;
reg fml_stb_bus;
reg fml_we_bus;
wire fml_ack_bus;
reg [3:0] fml_sel_bus;
reg [31:0] fml_di_bus;
wire [31:0] fml_do_bus;

wire [`SDRAM_DEPTH-1:0] fml_adr_ddr;
wire fml_stb_ddr;
wire fml_we_ddr;
reg fml_ack_ddr;
wire [3:0] fml_sel_ddr;
reg [31:0] fml_di_ddr;
wire [31:0] fml_do_ddr;
*/

/*
initial begin
	fml_adr_bus <= {`SDRAM_DEPTH-1{1'b0}};
	fml_stb_bus <= 1'b0;
	fml_we_bus <= 1'b0;
	fml_sel_bus <= 4'hf;
	fml_di_bus <= 32'habcd1234;
	#25 fml_stb_bus = 1'b1;
	fml_we_bus = 1'b0;
	#80 fml_we_bus = 1'b0;
	fml_stb_bus = 1'b0;
end

initial begin
	fml_di_ddr = 32'habadface;
	fml_ack_ddr = 1'b0;
	#50 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
	#10 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
	#10 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
	#50 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
	#10 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
	#10 fml_ack_ddr = 1'b1;
	#10 fml_ack_ddr = 1'b0;
end
*/








// señales wishbone
reg [31:0] 	brg_adr,
		brg_dat_w;
wire [31:0] 	brg_dat_r;
reg [3:0]	brg_sel;
reg [2:0] 	brg_cti;
reg		brg_cyc,
		brg_stb,
		brg_we;
wire		brg_ack;


// señaes fml
wire [`SDRAM_DEPTH-1:0] fml_brg_adr;
wire fml_brg_stb;
wire fml_brg_we;
wire fml_brg_ack;
wire [3:0] fml_brg_sel;
wire [31:0] fml_brg_dr;
wire [31:0] fml_brg_dw;





// señaes fml
wire [`SDRAM_DEPTH-1:0] fml_adr_bus;
wire fml_stb_bus;
wire fml_we_bus;
wire fml_ack_bus;
wire [3:0] fml_sel_bus;
wire [31:0] fml_dr_bus;
wire [31:0] fml_dw_bus;

// señales ddr
wire [`SDRAM_DEPTH-1:0] fml_adr_ddr;
wire fml_stb_ddr;
wire fml_we_ddr;
wire fml_ack_ddr;
wire [3:0] fml_sel_ddr;
wire [31:0] fml_dr_ddr;
wire [31:0] fml_dw_ddr;

// señales output port
wire 	sdram_cke;
wire	sdram_cs_n;
wire	sdram_we_n;
wire	sdram_cas_n;
wire	sdram_ras_n;
//wire	sdram_dqm
wire [12:0]	sdram_adr;
wire [1:0]	sdram_ba;
wire [15:0]	sdram_dq;
wire [1:0]	sdram_dqs;
wire [1:0] sdram_dqm;

// csr interfaz
wire [13:0]	csr_a;
wire 		csr_we;
wire [31:0]	csr_do;
wire  [31:0]	csr_di;

// csr bridge
reg [31:0] csrbrg_adr;
reg [31:0] csrbrg_dat_w;
wire [31:0] csrbrg_dat_r;
reg  csrbrg_cyc;
reg  csrbrg_stb;
reg  csrbrg_we;
wire  csrbrg_ack;


task waitclock;
begin
	@(posedge sys_clk);
//	#1;
end
endtask

task delay;
input [31:0] n;
begin
	while(1<n) begin
		@(posedge sys_clk);
		n=n-1'b1;
	end
end
endtask

task csr_write;
input [31:0] address;
input [31:0] data;
begin
	csrbrg_adr = address;
	csrbrg_dat_w = data;
	csrbrg_cyc = 1'b1;
	csrbrg_stb = 1'b1;
	csrbrg_we = 1'b1;
	while (~csrbrg_ack) begin
		waitclock;
	end

	csrbrg_adr = 32'b0;
	csrbrg_dat_w = 32'b0;

	csrbrg_cyc = 1'b0;
	csrbrg_stb = 1'b0;
	csrbrg_we = 1'b0;
	waitclock;
	
end
endtask


task ddr_write;
input [31:0] address;
input [31:0] data;
begin


	brg_adr 	= address;
	brg_dat_w 	= data;
	brg_sel		= 4'hf;
	brg_cyc 	= 1'b1;
	brg_stb 	= 1'b1;
	brg_we 		= 1'b1;

	while (~brg_ack) begin
		waitclock;
	end
	$display("%t: data %x wrote at %x ", $time, data, address);
	brg_adr 	= 32'b0;
	brg_dat_w 	= 32'b0;
	brg_sel		= 4'hf;
	brg_cyc 	= 1'b0;
	brg_stb 	= 1'b0;
	brg_we 		= 1'b0;
	waitclock;
	
end
endtask

task ddr_read;
input [31:0] address;
//input [31:0] data;
begin


	brg_adr 	= address;
	brg_dat_w 	= 32'b0;
	brg_sel		= 4'hf;
	brg_cyc 	= 1'b1;
	brg_stb 	= 1'b1;
	brg_we 		= 1'b0;

	while (~brg_ack) begin
		waitclock;
	end
	$display("%t: data %x read at %x ", $time, brg_dat_r, address);
	brg_adr 	= 32'b0;
	brg_dat_w 	= 32'b0;
	brg_sel		= 4'hf;
	brg_cyc 	= 1'b0;
	brg_stb 	= 1'b0;
	brg_we 		= 1'b0;
	waitclock;
	
end
endtask

//---------------------------------------------------------------------------
// WISHBONE to CSR bridge
//---------------------------------------------------------------------------
csrbrg csrbrg(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	
	.wb_adr_i(csrbrg_adr),
	.wb_dat_i(csrbrg_dat_w),
	.wb_dat_o(csrbrg_dat_r),
	.wb_cyc_i(csrbrg_cyc),
	.wb_stb_i(csrbrg_stb),
	.wb_we_i(csrbrg_we),
	.wb_ack_o(csrbrg_ack),
	
	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_do(csr_di),
	.csr_di(csr_do)
);


fmlbrg_b #(
	.fml_depth(`SDRAM_DEPTH)
) fmlbrg (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	
	.wb_adr_i(brg_adr),
	.wb_cti_i(brg_cti),
	.wb_dat_o(brg_dat_r),
	.wb_dat_i(brg_dat_w),
	.wb_sel_i(brg_sel),
	.wb_stb_i(brg_stb),
	.wb_cyc_i(brg_cyc),
	.wb_ack_o(brg_ack),
	.wb_we_i(brg_we),
	
	.fml_adr(fml_brg_adr),
	.fml_stb(fml_brg_stb),
	.fml_we(fml_brg_we),
	.fml_ack(fml_brg_ack),
	.fml_sel(fml_brg_sel),
	.fml_di(fml_brg_dr),
	.fml_do(fml_brg_dw)
);


interface_ddr_16_bit interface(

	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

// FMLARB side
	.fml_adr_bus(fml_brg_adr),
	.fml_stb_bus(fml_brg_stb),
	.fml_we_bus(fml_brg_we),
	.fml_ack_bus(fml_brg_ack),
	.fml_sel_bus(fml_brg_sel),
	.fml_di_bus(fml_brg_dw),
	.fml_do_bus(fml_brg_dr),

//FML ddr side


	.fml_stb_ddr(fml_stb_ddr),
	.fml_sel_ddr(fml_sel_ddr),
	.fml_we_ddr(fml_we_ddr),

	.fml_ack_ddr(fml_ack_ddr),
	.fml_di_ddr(fml_dr_ddr),

	.fml_adr_ddr(fml_adr_ddr),
	.fml_do_ddr(fml_dw_ddr)
);





wire sys_clk_fb;
wire sdram_clk_p, sdram_clk_n;
wire sdram_dq_t;
wire [15:0] sdram_dq_mon;
wire [1:0] sdram_dqs_mon;
//---------------------------------------------------------------------------
// DDR SDRAM
//---------------------------------------------------------------------------
ddram #(
	.csr_addr(4'h2)
) ddram (
	.clk_in(sys_clk),//clk_100Mhz//
	.clk_fb(sys_clk_fb),
	.sys_clk_n(sys_clk_n),
	.sys_clk(sys_clk),
	.dcm_rst(resetin),

	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),

	.fml_adr(fml_adr_ddr),
	.fml_stb(fml_stb_ddr),
	.fml_we(fml_we_ddr),
	.fml_ack(fml_ack_ddr),
	.fml_sel(fml_sel_ddr),//fml_sel_ddr//4'b1111
	.fml_di(fml_dw_ddr),
	.fml_do(fml_dr_ddr),
	
	.sdram_clk_p(sdram_clk_p),
	.sdram_clk_n(sdram_clk_n),

	.sdram_cke(sdram_cke),
	.sdram_cs_n(sdram_cs_n),
	.sdram_we_n(sdram_we_n),
	.sdram_cas_n(sdram_cas_n),
	.sdram_ras_n(sdram_ras_n),
	.sdram_dqm(sdram_dqm),
	.sdram_adr(sdram_adr),
	.sdram_ba(sdram_ba),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),

	.sdram_dq_t(sdram_dq_t),
	.sdram_dq_mon(sdram_dq_mon),
	.sdram_dqs_mon(sdram_dqs_mon)

);



/*
hpdmc #(
	.csr_addr(4'd2),
	.sdram_depth(`SDRAM_DEPTH),
	.sdram_columndepth(10)
) hpdmc (
	.sys_clk(clk),
	.sys_clk_n(~clk),
	.dqs_clk(clk),
	.dqs_clk_n(~clk),
	.sys_rst(rst),

	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	
	.fml_adr(fml_adr_ddr),
	.fml_stb(fml_stb_ddr),
	.fml_we(fml_we_ddr),
	.fml_ack(fml_ack_ddr),
	.fml_sel(fml_sel_ddr),
	.fml_di(fml_dw_ddr),
	.fml_do(fml_dr_ddr),
	
	.sdram_cke(sdram_cke),
	.sdram_cs_n(sdram_cs_n),
	.sdram_we_n(sdram_we_n),
	.sdram_cas_n(sdram_cas_n),
	.sdram_ras_n(sdram_ras_n),
	.sdram_dqm(sdram_dqm),
	.sdram_adr(sdram_adr),
	.sdram_ba(sdram_ba),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),
	
//	.dqs_psen(1'b1),
	//.dqs_psincdec(psincdec),
	.dqs_psdone(1'b1),

	.pll_stat({1'b1, 1'b1})
);
*/


wire clk_;
DDR_reg clock_ (
	.Q(clk_),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(1'b1),
	.D1(1'b0),
	.R(1'b0),
	.S(1'b0)
);


//wire sys_clk, resetin;
//assign sys_clk = clk;
//assign resetin = rst;
wire [31:0] phase_counter, counter_a, counter_b, pulses_counter;


wire [13:0] gpio_outputs;
wire [31:0] data_out, data_out_b, data_out_c, data_out_d;

reg [1:0] rot;
initial rot = 2'd0; 

reg [3:0] sw;
initial sw = 4'd1; 

/*
reg start_stop;

always @(sys_clk) begin
	if (sys_rst)
		start_stop <= 1'b0;
	else if (fml_brg_stb & (fml_brg_dw == 32'habadface) & fml_brg_we)
		start_stop <= 1'b1;
	else 
		start_stop <= 1'b0;
end
*/


wire start_stop;

reg [2:0] delay_reg;

always @(posedge sys_clk) begin
	if (sys_rst)
		delay_reg <= 3'b0;
	else if (fml_brg_stb == 1'b1)
		delay_reg <= 3'b0;
	else if ((fml_brg_stb == 1'b0) & (delay_reg[2] == 0))
		delay_reg <= delay_reg+3'b001;
	else
		delay_reg <= delay_reg;
		
end

assign start_stop = (fml_brg_stb | ~delay_reg[2]) & ((fml_brg_dw == 32'habadface)  ^ ~sw[0] ) & (fml_brg_we ^ ~sw[0]) & (sw[0] ^ (data_out_b == 32'hefecadab));


//assign led[7:6] = rot;
//assign led[7] = start_stop;


//########################################################
/////////////////////////////////////////////////////
//////////////////////////////////////////////////////




wire [10:0] x;
wire [9:0] y;
wire [19:0] state, buf_graph;
wire [2:0] rgb;

sampling  #(
	.data_size(119),	//20
	.state_size(20),
	.mem_width(5)
)sampling(
	//.clk_fb_main(clk_50Mhz),
	//.clk_50Mhz(clk_50Mhz),//clkin

	//.sys_rst(sys_rst),
	.dcm_rst(resetin),

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
	.ack(fml_ack_ddr),
	.state(state),
	.buf_graph(buf_graph),

	.x_in(x),
//	.y(y),

	.phase_counter(phase_counter)
	//.pulses_counter(pulses_counter),
	//.counter_a(counter_a),
	//.counter_b(counter_b)

);


vga_controller vga_cnt(
	.clk(clk_50Mhz), 
	.rst(resetin),
	.hsync(vga_hsync),
	.vsync(vga_vsync),
	.x(x),
	.y(y)
);

graph #(
	.samples(25),
	.data_width(20),
	.height(10)
) graph (
	.clk(clk_50Mhz),//sample_clk
	.rst(resetin),
	.x(x),
	.y(y),
	.state(state),/////////////////mem_dat_r
	.buf_data(buf_graph),
	.rgb_out(rgb)
);






ddr sdram0(
	.Addr(sdram_adr),
	.Ba(sdram_ba),
	.Clk(sdram_clk_p),
	.Clk_n(sdram_clk_n),
	.Cke(sdram_cke),
	.Cs_n(sdram_cs_n),
	.Ras_n(sdram_ras_n),
	.Cas_n(sdram_cas_n),
	.We_n(sdram_we_n),
	
	.Dm(sdram_dqm),
	.Dqs(sdram_dqs),
	.Dq(sdram_dq)
);



// inicializacion del controlador hpdmc
reg	[31:0]	csr_address;

initial begin
	#103000
	//delay(32'd10000);


	csr_write(32'h40002000, 32'h00000001);	/* enable bypass ------*/
	delay(32'd1);

	csr_write(32'h4000200c, 32'h00000001);	/* reset {i|dqs}delay ------*/
	delay(32'd1);

	csr_write(32'h40002000, 32'h00000007);	/* enable bypass, reset and cke ------*/
	delay(32'd1);



	csr_write(32'h40002004, 32'h0000400b);	/* Precharge All ------ No 7*/
	delay(32'd1);

	csr_write(32'h40002004, 32'h00000008);	/* NOP cmd	-------- No 8*/
	delay(32'd1);

	csr_write(32'h40002004, 32'h0002000f); //Load Extended Mode Register No 9
	delay(32'd1);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);

	csr_write(32'h40002004,  32'h0000123f);// Load Mode Register ------- No 11
	delay(32'd100);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);


	csr_write(32'h40002004, 32'h0000400b);// Precharge All ---- No 13
	delay(32'd1);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);

	csr_write(32'h40002004,  32'h0000000d);/* Auto Refresh ---- 15*/
	delay(32'd4);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);

	csr_write(32'h40002004, 32'h0000000d);/* Auto Refresh  ---- 17*/
	delay(32'd4);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);


	csr_write(32'h40002004, 32'h0000021f);/* Load Mode Register, Enable DLL --- 19*/
	delay(32'd100);

	csr_write(32'h40002004,  32'h00000008);// nop
	delay(32'd1);

/// ajustar timers

	csr_write(32'h40002000, 32'd4);
	delay(32'd1);
/*
	csr_write(32'h40002004, );
	delay(32'd1);
*/




	delay(32'd1);
	ddr_write(32'h40000000, 32'habadface);
	delay(32'd4);

	ddr_read(32'h40000000);
	delay(32'd4);

	ddr_write (32'h40002000, 32'hfade2bad);
	delay(32'd4);

	ddr_read(32'h40002000);
	delay(32'd4);


	ddr_read(32'h40000000);
	ddr_write (32'h40000000, 32'hfade2bad);
	ddr_write (32'h40000004, 32'hcade3bad);
	ddr_write (32'h40000008, 32'hbade4bad);
	ddr_write (32'h40002000, 32'h12345678);
	ddr_read(32'h40000000);
	ddr_read(32'h40002000);
	ddr_read(32'h40000000);
// señales wishbone

end

endmodule
