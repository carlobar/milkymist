SOURCES=tb_lut.v lut.v
EXEC = tb_lut

all: ${EXEC} sim

sim: ${EXEC}
	./${EXEC}

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f ${EXEC} verilog.log

${EXEC}: $(SOURCES)
	rm -f make.log
	iverilog -o ${EXEC} $(SOURCES) >> make.log 2>&1


.PHONY: clean sim cversim
