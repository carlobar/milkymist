module interface_ddr_16_bit(

	input 	sys_clk,
	input	sys_rst,

// FMLARB side
	input	[`SDRAM_DEPTH-1:0]	fml_adr_bus,
	input		fml_stb_bus,
	input		fml_we_bus,
	output	reg	fml_ack_bus,
	input	[3:0]	fml_sel_bus,
	input	[31:0]	fml_di_bus,
	output	[31:0]	fml_do_bus,

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
assign fml_sel_ddr = fml_sel_bus;
assign fml_we_ddr = fml_we_bus;
//assign fml_stb_ddr = fml_stb_bus;
assign fml_do_bus = data_in;

parameter [2:0] idle = 0, upper_data = 1, lower_data = 2, send =3, wait_1 = 4, wait_2 = 5;
reg 	[2:0] state;
reg 	[2:0] next_state;


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
		fml_ack_bus <= 1'b0;
	end
	else if(state == send)	begin
		fml_ack_bus <= 1'b1;
	end
	else
		fml_ack_bus <= 1'b0;
end

always @(posedge sys_clk) begin
	if(sys_rst)	begin
		data_in <= 32'b0;
	end
	else if ((state == upper_data) )	begin//& fml_ack_ddr//wait_1
//		data_in <= 32'habadacab;
		data_in <= fml_di_ddr;
//		data_in[31:16] <= fml_di_ddr[15:0];
//		data_in[15:0] <= fml_di_ddr[31:16];
	end
	else if ((state == lower_data) )	begin//& fml_ack_ddr//wait_2
		data_in[15:0] <= fml_di_ddr[15:0];
		data_in[31:16] <= data_in[31:16];
//		data_in <= 32'habadacab;
	end
	else if((state == idle))
		data_in <= 32'b0;
	else 
		data_in <= data_in;

end


// decide next state
always @(*) begin
	next_state = state;
	case(state)
		idle: begin
			if (fml_stb_bus) begin
				next_state = upper_data;
			end else
				next_state = state;
		end
		upper_data: begin
			if (fml_ack_ddr) begin
				next_state = send;//lower_data;//wait_1//
			end else
				next_state = state;
		end
		wait_1: begin
			if (~fml_ack_ddr) begin
				next_state = lower_data;
			end else
				next_state = state;
		end
		lower_data: begin
			if (fml_ack_ddr) begin
				next_state = send;//wait_2
			end else
				next_state = state;
		end
		wait_2: begin
			if (~fml_ack_ddr) begin
				next_state = send;
			end else
				next_state = state;
		end
		send: begin
//			if (~fml_stb_bus) begin
				next_state = idle;
//			end else
//				next_state = state;
		end
	endcase
end



always @(*) begin
	case(state)
		idle: begin
			fml_adr_ddr = 32'b0;
			fml_do_ddr  = 32'b0;
			fml_stb_ddr = 1'b0;

		end
		upper_data: begin
			fml_adr_ddr = {1'b0, fml_adr_bus[`SDRAM_DEPTH-1:1]};
			fml_do_ddr = fml_di_bus[31:0];
//			fml_do_ddr  = {{16{1'b1}}, fml_di_bus[31:16]} ;
			fml_stb_ddr = fml_stb_bus;
		end
		lower_data: begin
			fml_adr_ddr = {fml_adr_bus[`SDRAM_DEPTH-2-1:2],1'b1,1'b0};
			fml_do_ddr  = {{16{1'b1}}, fml_di_bus[15:0]};
			fml_stb_ddr = fml_stb_bus;//1'b0;//
		end
		send: begin
			fml_adr_ddr = {fml_adr_bus[`SDRAM_DEPTH-1:0]};
//			fml_adr_ddr = {fml_adr_bus[`SDRAM_DEPTH-1:1],1'b1};
//			fml_do_ddr  = {{16{1'b1}}, fml_di_bus[15:0]};
//			fml_do_ddr  = 32'b0;
			fml_do_ddr = fml_di_bus[31:0];
			fml_stb_ddr = 1'b0;
		end
		wait_1: begin
			fml_adr_ddr = 32'b0;
			fml_do_ddr  = 32'b0;
			fml_stb_ddr = fml_stb_bus;
		end
		wait_2: begin
			fml_adr_ddr = 32'b0;
			fml_do_ddr  = 32'b0;
			fml_stb_ddr = fml_stb_bus;
		end
	endcase
end
endmodule
