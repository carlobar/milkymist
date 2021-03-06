module memory#(
	// memoria
	parameter width = 11,
	parameter mem_size = 32, //bits
	parameter mem_depth = (1 << width)
)(
	input clk,
	input [mem_size-1:0] mem_dat_i,
	output reg [mem_size-1:0] mem_dat_o,
	input mem_we,
	input [width-1:0] mem_adr
	
);

reg [mem_size-1:0] mem_a [0:mem_depth-1];
/*reg [mem_size-1:0] mem_b [0:mem_depth-1];
reg [mem_size-1:0] mem_c [0:mem_depth-1];
reg [mem_size-1:0] mem_d [0:mem_depth-1];
*/

/*
always @(posedge clk) begin
	if (mem_we) begin
		mem_a[mem_adr] <= mem_dat_i[7:0];
		mem_b[mem_adr] <= mem_dat_i[15:8];
		mem_c[mem_adr] <= mem_dat_i[23:16];
		mem_d[mem_adr] <= mem_dat_i[31:24];
	end
	else begin
		mem_dat_o[7:0]   <= mem_a[mem_adr];
		mem_dat_o[15:8]  <= mem_b[mem_adr];
		mem_dat_o[23:16] <= mem_c[mem_adr];
		mem_dat_o[31:24] <= mem_d[mem_adr];
	end
end
*/

always @(posedge clk) begin
	if (mem_we) begin
		mem_a[mem_adr] <= mem_dat_i;
		
	end
	else begin
		mem_dat_o   <= mem_a[mem_adr];
		
	end
end


endmodule
