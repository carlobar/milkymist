`timescale 1ns/1ps





module system_tb();


 initial begin
     $dumpfile("system_tb.vcd");
     $dumpvars(0,system_tb);
     #17000000 $finish;

  end


reg sys_clk;
reg resetin;

wire [23:0] flash_adr;
reg [31:0] flash_d;
reg [15:0] flash_d16_o;
wire [15:0] flash_d16_i;
wire [15:0] flash_d16;
reg [31:0] flash[0:35288];

wire clk_p, clk_n;
wire flash_we_n;


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





initial sys_clk = 1'b0;
always #10 sys_clk = ~sys_clk;

initial begin
	resetin = 1'b1;
	#60 resetin = 1'b0;  
end

initial $readmemh("bios.rom", flash);
always @(flash_adr) begin
	#10;
	flash_d = flash[flash_adr[23:2]];
	case(flash_adr[1])
		2'b0: flash_d16_o = flash_d[31:16];
		2'b1: flash_d16_o = flash_d[15:0];
	endcase
end


assign flash_d16 = flash_we_n ? flash_d16_o : 16'bz;
assign flash_d16_i =  flash_d16;

reg sw;

initial begin
	sw = 4'd1;
	#370700 
	sw = 4'd0;
end


system system(
	.clk_in(sys_clk),
	.resetin(resetin),

	.flash_adr(flash_adr),
	.flash_d(flash_d16),
	.flash_we_n(flash_we_n),

	.sdram_clk_p(clk_p),
	.sdram_clk_n(clk_n),
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

	.sw(sw),

	.uart_rx(),
	.uart_tx()
);



ddr sdram0(
	.Addr(sdram_adr),
	.Ba(sdram_ba),
	.Clk(clk_p),
	.Clk_n(clk_n),
	.Cke(sdram_cke),
	.Cs_n(sdram_cs_n),
	.Ras_n(sdram_ras_n),
	.Cas_n(sdram_cas_n),
	.We_n(sdram_we_n),
	
	.Dm(sdram_dqm),
	.Dqs(sdram_dqs),
	.Dq(sdram_dq)
);


endmodule
