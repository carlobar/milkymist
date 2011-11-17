module vga_controller(
	input clk, 
	input rst,
	output	reg hsync,
	output 	reg vsync,
	output	[10:0] 	x,
	output	[9:0]	y
);

reg [10:0] hcount, hcount_;
reg [9:0]  vcount, vcount_;

initial begin
		hcount <= 11'b0;
		vcount <= 10'b0;

end


parameter  [1:0] reset = 0, s0 = 1, s1 = 2;
reg 	[1:0] state;
reg 	[1:0] next_state;


always @(posedge clk) begin
	if(rst)	begin
		state <= reset;
		hcount <= 11'b0;
		vcount <= 10'b0;
	end
	else	begin
		state <= next_state;
		hcount <= hcount_;
		vcount <= vcount_;
	end
end


// decide next state
always @(*) begin
	next_state = state;
	case(state)
		reset: begin
			hcount_ = 11'b0;
			vcount_ = 10'b0;
			next_state = s0;
		end
		s0:begin
			vcount_ = vcount;
			if(hcount == 11'd1600) begin
				hcount_ = 11'b0;
				next_state = s1;
			end
			else begin
				hcount_ = hcount+11'd1;
				next_state = s0;
			end
		end
		s1: begin
			hcount_ = hcount;
			next_state = s0;
			if (vcount == 10'd525) begin
				vcount_ = 10'b0;			
			end
			else
				vcount_ = vcount +10'd1;
		end
		default: begin
			hcount_ = 11'b0;
			vcount_ = 10'b0;
			next_state = s0;
		end

	endcase
end


always @(hcount or vcount) begin	
	if((hcount >= 11'd1320) & (hcount <= 11'd1512))
		hsync = 1'b0;
	else
		hsync = 1'b1;
	if((vcount >= 10'd494) & (vcount <= 10'd495))
		vsync = 1'b0;
	else
		vsync = 1'b1;
end

assign x = hcount;
assign y = vcount;

endmodule



