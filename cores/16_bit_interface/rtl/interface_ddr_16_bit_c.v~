module interface_ddr_16_bit_b(

	input 	sys_clk,
	input	sys_rst,

	input [31:0] wb_adr_i,
	input [2:0] wb_cti_i,	// no usada
	input [31:0] wb_dat_i,
	output [31:0] wb_dat_o,
	input [3:0] wb_sel_i,	
	input wb_cyc_i,
	input wb_stb_i,
	input wb_we_i,
	output reg wb_ack_o,
//FML ddr side


	output	reg	fml_stb_ddr,
	output	[3:0]	fml_sel_ddr,
	output		fml_we_ddr,

	input		fml_ack_ddr,
	input	[31:0]	fml_di_ddr,

	output	reg [`SDRAM_DEPTH-1:0]	fml_adr_ddr,
	output	reg [31:0]	fml_do_ddr
);

reg [31:0] data_in;
//assign fml_adr_ddr = fml_adr_bus;
assign fml_sel_ddr = wb_sel_i;
assign fml_we_ddr = wb_we_i;
//assign fml_stb_ddr = fml_stb_bus;
assign wb_dat_o = data_in;

parameter [1:0] idle = 0, upper_data = 1, lower_data = 2, send =3;
reg 	[1:0] state;
reg 	[1:0] next_state;


always @(posedge sys_clk) begin
	if(sys_rst)	begin
		state <= idle;
	end
	else	begin
		state <= next_state;
	end
end

always @(posedge sys_clk) begin
	if(sys_rst)	begin
		wb_ack_o <= 1'b0;
	end
	else if(state == send)	begin
		wb_ack_o <= 1'b1;
	end
	else
		wb_ack_o <= 1'b0;
end

always @(posedge sys_clk) begin
	if(sys_rst)	begin
		data_in <= 32'b0;
	end
	else if ((state == upper_data) & fml_ack_ddr)	begin
		data_in[31:16] <= fml_di_ddr[15:0];
		data_in[15:0] <= data_in[15:0];
	end
	else if ((state == lower_data) & fml_ack_ddr)	begin
		data_in[15:0] <= fml_di_ddr[15:0];
		data_in[31:16] <= data_in[31:16];
	end
	else if(state == send)
		data_in <= data_in;
	else 
		data_in <= 32'b0;

end


// decide next state
always @(*) begin
	next_state = state;
	case(state)
		idle: begin
			if (wb_stb_i & wb_cyc_i) begin
				next_state = upper_data;
			end else
				next_state = state;
		end
		upper_data: begin
			if (fml_ack_ddr) begin
				next_state = lower_data;
			end else
				next_state = state;
		end
		lower_data: begin
			if (fml_ack_ddr) begin
				next_state = send;
			end else
				next_state = state;
		end
		send: begin
			if (~wb_stb_i) begin
				next_state = idle;
			end else
				next_state = state;
		end
	endcase
end



always @(*) begin
	case(state)
		idle: begin
			fml_adr_ddr = 32'b0;
			fml_do_ddr  = 32'b0;
			fml_stb_ddr = wb_stb_i;

		end
		upper_data: begin
			fml_adr_ddr = {wb_adr_i[`SDRAM_DEPTH-2:0],1'b0};
			fml_do_ddr  = {{16{1'b0}}, wb_dat_i[31:16]};
			fml_stb_ddr = wb_stb_i;
		end
		lower_data: begin
			fml_adr_ddr = {wb_adr_i[`SDRAM_DEPTH-2:1],1'b1,1'b0};
			fml_do_ddr  = {{16{1'b0}}, wb_dat_i[15:0]};
			fml_stb_ddr = wb_stb_i;
		end
		send: begin
			fml_adr_ddr = {wb_adr_i[`SDRAM_DEPTH-2:1],1'b1,1'b0};
			fml_do_ddr  = {{16{1'b0}}, wb_dat_i[15:0]};
			fml_stb_ddr = 1'b0;
		end
	endcase
end
endmodule
