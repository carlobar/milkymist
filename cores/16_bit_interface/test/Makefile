SOURCES=						\
	tb_16_bit_interface.v 				\
	soc.v		 				\
	$(wildcard ../rtl/*.v) 				\
	$(wildcard ../../hpdmc_ddr16/rtl/*.v) 		\
	$(wildcard ../../hpdmc_ddr16/rtl/spartan3/*.v)	\
	$(wildcard unisims/*.v)  			\
	$(wildcard ../../fmlbrg/rtl/*.v)  		\
	$(wildcard ../../csrbrg/rtl/*.v)		\
	$(wildcard ../../vga_controller/rtl/*.v)		\
	$(wildcard ../../../boards/digilent-xc3s500e/rtl/*.v)

VINCDIR= 					\
	-Iunisims				\
	-I../rtl				\
	-I../../hpdmc_ddr16/rtl			\
	-I../../hpdmc_ddr16/rtl/spartan3	\
	-I../../fmlbrg/rtl			\
	-I../../csrbrg/rtl			\
	-I../../vga_controller/rtl		\
	-I../../../boards/digilent-xc3s500e/rtl

EXEC = tb_16_bit_interface

all: ${EXEC} sim

sim: ${EXEC}
	./${EXEC}

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f ${EXEC} verilog.log ${EXEC}.vcd make.log *~

${EXEC}: $(SOURCES)
	rm -f $@.list
	@for i in `echo $^`; do \
	    echo $$i >> $@.list; \
	done
	rm -rf make.log
	iverilog -D SIMULATION_DDR $(VINCDIR) -c $@.list -o $(EXEC) -s $@ >> make.log 2>&1


.PHONY: clean sim cversim
