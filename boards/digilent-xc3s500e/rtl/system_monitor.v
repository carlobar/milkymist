`include "setup_monitor.v"


module system_monitor(
	input clk,
	input rst,
	
	/*measure signals*/
	input	sys_clk,
	input	[15:0] 	sdram_dq,
	input	[1:0] 	sdram_dqs,
	input		sdram_cs_n,
	input		sdram_ras_n,
	input		sdram_cas_n,
	input		sdram_we_n,


	// control signals
	input		enable_capture,
	input		end_capture,

	//uart_signals
	output		uart_tx_mon,
	input		uart_rx_mon
);





/* wishbone bus*/

wire [31:0]	monitor_dat_w,
		monitor_dat_r;
wire [31:0]	monitor_adr;
wire [3:0]	monitor_sel;
wire		monitor_we,
		monitor_cyc,
		monitor_stb,
		monitor_ack;


wire [31:0]	bram_dat_w,
		bram_dat_r;
wire [31:0]	bram_adr;
wire [3:0]	bram_sel;
wire		bram_we,
		bram_cyc,
		bram_stb,
		bram_ack;

wire [31:0]	csrbrg_dat_w,
		csrbrg_dat_r;
wire [31:0]	csrbrg_adr;
wire [3:0]	csrbrg_sel;
wire		csrbrg_we,
		csrbrg_cyc,
		csrbrg_stb,
		csrbrg_ack;


wire [13:0]	csr_a;
wire		csr_we;
wire [31:0]	csr_dw;
wire [31:0]	csr_dr_uart;

wire uartrx_irq, uarttx_irq;

conbus #(
	.s_addr_w(4),
	.s0_addr(4'b0000),	// bram		0x00000000
	.s1_addr(4'b0010),	// free		0x20000000
	.s2_addr(4'b0100),	// free		0x40000000
	.s3_addr(4'b1000),	// CSR bridge	0x80000000
	.s4_addr(4'b0110)	// free		0xe0000000
) sys_monitor_conbus (
	.sys_clk(clk),
	.sys_rst(rst),
//	.slave_selected(slave_sel),
	// Master 0
	.m0_dat_i(monitor_dat_r),
	.m0_dat_o(monitor_dat_w),
	.m0_adr_i(monitor_adr),
	.m0_cti_i(),
	.m0_we_i(monitor_we),
	.m0_sel_i(monitor_sel),
	.m0_cyc_i(monitor_cyc),
	.m0_stb_i(monitor_stb),
	.m0_ack_o(monitor_ack),
	// Master 1
	.m1_dat_i(32'bx),
	.m1_dat_o(),
	.m1_adr_i(32'bx),
	.m1_cti_i(),
	.m1_we_i(1'b0),
	.m1_sel_i(),
	.m1_cyc_i(1'b0),
	.m1_stb_i(1'b0),
	.m1_ack_o(),
	// Master 2
	.m2_dat_i(32'bx),
	.m2_dat_o(),
	.m2_adr_i(32'bx),
	.m2_cti_i(),
	.m2_we_i(1'b0),
	.m2_sel_i(),
	.m2_cyc_i(1'b0),
	.m2_stb_i(1'b0),
	.m2_ack_o(),
	// Master 3
	.m3_dat_i(32'bx),
	.m3_dat_o(),
	.m3_adr_i(32'bx),
	.m3_cti_i(),
	.m3_we_i(1'b0),
	.m3_sel_i(4'b1),
	.m3_cyc_i(1'b0),
	.m3_stb_i(1'b0),
	.m3_ack_o(),
	// Master 4
	.m4_dat_i(32'bx),
	.m4_dat_o(),
	.m4_adr_i(32'bx),
	.m4_cti_i(3'bx),
	.m4_we_i(1'bx),
	.m4_sel_i(4'bx),
	.m4_cyc_i(1'b0),
	.m4_stb_i(1'b0),
	.m4_ack_o(),

	// Slave 0
	.s1_dat_i(32'bx),
	.s1_dat_o(),
	.s1_adr_o(),
	.s1_sel_o(),
	.s1_cyc_o(),
	.s1_stb_o(),
	.s1_ack_i(1'b0),
	// Slave 1
	.s0_dat_i(bram_dat_r),
	.s0_dat_o(bram_dat_w),
	.s0_adr_o(bram_adr),
	.s0_cti_o(),
	.s0_sel_o(bram_sel),
	.s0_we_o(bram_we),
	.s0_cyc_o(bram_cyc),
	.s0_stb_o(bram_stb),
	.s0_ack_i(bram_ack),
	// Slave 2
	.s2_dat_i(32'bx),
	.s2_dat_o(),
	.s2_adr_o(),
	.s2_cti_o(),
	.s2_sel_o(),
	.s2_we_o(),
	.s2_cyc_o(),
	.s2_stb_o(),
	.s2_ack_i(1'b0),
	// Slave 3
	.s3_dat_i(csrbrg_dat_r),
	.s3_dat_o(csrbrg_dat_w),
	.s3_adr_o(csrbrg_adr),
	.s3_we_o(csrbrg_we),
	.s3_cyc_o(csrbrg_cyc),
	.s3_stb_o(csrbrg_stb),
	.s3_ack_i(csrbrg_ack),
	// Slave 4
	.s4_dat_i(32'bx),
	.s4_dat_o(),
	.s4_adr_o(),
	.s4_we_o(),
	.s4_sel_o(),
	.s4_cyc_o(),
	.s4_stb_o(),
	.s4_ack_i(1'b0)
);

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
	.csr_do(csr_dw),
	/* combine all slave->master data lines with an OR */
	.csr_di(
		 csr_dr_uart
	)
);

bram #(
	.adr_width(14)
) bram (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	.wb_adr_i(bram_adr),
	.wb_dat_o(bram_dat_r),
	.wb_dat_i(bram_dat_w),
	.wb_sel_i(bram_sel),
	.wb_stb_i(bram_stb),
	.wb_cyc_i(bram_cyc),
	.wb_ack_o(bram_ack),
	.wb_we_i(bram_we)
);


//---------------------------------------------------------------------------
// UART
//---------------------------------------------------------------------------
uart #(
	.csr_addr(4'h0),
	.clk_freq(`CLOCK_FREQUENCY_MONITOR),
	.baud(`BAUD_RATE)
) uart (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_dw),
	.csr_do(csr_dr_uart),
	
	.rx_irq(uartrx_irq),
	.tx_irq(uarttx_irq),
	
	.uart_rxd(uart_rx_mon),
	.uart_txd(uart_tx_mon)
);




monitor #(
	.ram_adr(4'h0),
	.uart_adr(4'h8),
	.signals(2),
	.size(1)
) monitor(
	.clkin(clk),
	.resetin(rst),

	/*wishbone bus*/
	.monitor_dat_i(monitor_dat_w),
	.monitor_dat_o(monitor_dat_r),
	.monitor_adr(monitor_adr),
	.monitor_cyc(monitor_cyc),
	.monitor_stb(monitor_stb),
	.monitor_we(monitor_we),
	.monitor_sel(monitor_sel),
	.monitor_ack(monitor_ack),

	/*measure signals*/
	.sys_clk(sys_clk),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),
	.sdram_cs_n(sdram_cs_n),
	.sdram_ras_n(sdram_ras_n),
	.sdram_cas_n(sdram_cas_n),
	.sdram_we_n(sdram_we_n),

// señal para iniciar y detener captura.
	.enable_capture(enable_capture),
	.end_capture(end_capture),
	.uart_tx_irq(uarttx_irq),
	.uart_rx_irq(uartrx_irq)
);



endmodule
