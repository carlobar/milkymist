SOURCES=tb_16_bit_interface.v $(wildcard ../rtl/*.v) $(wildcard ../../hpdmc_ddr16/rtl/*.v) $(wildcard ../../hpdmc_ddr16/rtl/spartan3/*.v)	$(wildcard unisims/*.v) $(wildcard ../../fmlbrg/*.v)
$(wildcard ../../fmlbrg/*.v)  $(wildcard ../../csrbrg/*.v)
EXEC = tb_16_bit_interface

all: ${EXEC} sim

sim: ${EXEC}
	./${EXEC}

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f ${EXEC} verilog.log ${EXEC}.vcd make.log *~

${EXEC}: $(SOURCES)
	rm -f make.log
	iverilog -Iunisims -o ${EXEC} $(SOURCES) >> make.log 2>&1


.PHONY: clean sim cversim
