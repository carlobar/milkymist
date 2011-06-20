`timescale 1ns / 1ps

module tb_16_bit_interface();



 initial begin
     $dumpfile("tb_16_bit_interface.vcd");
     $dumpvars(0,tb_16_bit_interface);

     # 17000000 $finish;
  end

reg	clkin;
reg     resetin;

initial clkin = 1'b0;
always #10 clkin = ~clkin;

initial begin
	resetin = 1'b1;
	#400 resetin = 1'b0;  
end


soc soc(
	.clkin(clkin),
	.resetin(resetin)
);

endmodule






		
		
