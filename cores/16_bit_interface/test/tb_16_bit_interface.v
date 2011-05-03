`timescale 1ns / 1ps

module tb_16_bit_interface();



 initial begin
     $dumpfile("tb_16_bit_interface.vcd");
     $dumpvars(0,tb_16_bit_interface);

     # 300000 $finish;
  end

reg	clk,rst;


initial clk = 1'b0;
always #10 clk = ~clk;

initial begin
	rst = 1'b1;
	@(posedge clk);
	#1 rst = 1'b0;
end
`define SDRAM_DEPTH 25

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
	@(posedge clk);
//	#1;
end
endtask

task delay;
input [31:0] n;
begin
	while(1<n) begin
		@(posedge clk);
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
	.sys_clk(clk),
	.sys_rst(rst),
	
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
	.sys_clk(clk),
	.sys_rst(rst),
	
	.wb_adr_i(brg_adr),
	.wb_cti_i(3'b0),
	.wb_dat_o(brg_dat_r),
	.wb_dat_i(brg_dat_w),
	.wb_sel_i(brg_sel),
	.wb_stb_i(brg_stb),
	.wb_cyc_i(brg_cyc),
	.wb_ack_o(brg_ack),
	.wb_we_i(brg_we),
	
	.fml_adr(fml_adr_bus),
	.fml_stb(fml_stb_bus),
	.fml_we(fml_we_bus),
	.fml_ack(fml_ack_bus),
	.fml_sel(fml_sel_bus),
	.fml_di(fml_dr_bus),
	.fml_do(fml_dw_bus)
);




interface_ddr_16_bit interface(

	.sys_clk(clk),
	.sys_rst(rst),

// FMLARB side
	.fml_adr_bus(fml_adr_bus),
	.fml_stb_bus(fml_stb_bus),
	.fml_we_bus(fml_we_bus),
	.fml_ack_bus(fml_ack_bus),
	.fml_sel_bus(fml_sel_bus),
	.fml_di_bus(fml_dw_bus),
	.fml_do_bus(fml_dr_bus),

//FML ddr side


	.fml_stb_ddr(fml_stb_ddr),
	.fml_sel_ddr(fml_sel_ddr),
	.fml_we_ddr(fml_we_ddr),

	.fml_ack_ddr(fml_ack_ddr),
	.fml_di_ddr(fml_dr_ddr),

	.fml_adr_ddr(fml_adr_ddr),
	.fml_do_ddr(fml_dw_ddr)
);





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



ddr sdram0(
	.Addr(sdram_adr),
	.Ba(sdram_ba),
	.Clk(clk),
	.Clk_n(~clk),
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
	delay(32'd10000);

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






		
		
