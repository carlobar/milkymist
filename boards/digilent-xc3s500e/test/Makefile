TOPDIR?=$(shell pwd)
BOARD_DIR=$(TOPDIR)/../rtl
CORES_DIR=$(TOPDIR)/../../../cores

DIR=$(TOPDIR)

BIN=../../../software/bios/bios.bin
#BIN=/media/dat_2/lattice/lm32linux-20080206/u-boot/build/u-boot.bin

include ../sources.mak

SRC =					\
	$(BOARD_DIR)/system.v

VINCDIR= 				\
	-I$(DIR)/unisims		\
	-I$(BOARD_DIR)			\
	-I$(BOARD_DIR)/../test/unisims	\
	-I$(CORES_DIR)/conbus/rtl	\
	-I$(CORES_DIR)/fmlbrg/rtl	\
	-I$(CORES_DIR)/fmlarb/rtl	\
	-I$(CORES_DIR)/hpdmc_ddr16/rtl	\
	-I$(CORES_DIR)/hpdmc_ddr16/rtl/spartan3	\
	-I$(CORES_DIR)/16_bit_interface/rtl	\
	-I$(CORES_DIR)/csrbrg/rtl	\
	-I$(CORES_DIR)/lcd_2x16/rtl	\
	-I$(CORES_DIR)/lm32/rtl		\
	-I$(CORES_DIR)/norflash16/rtl	\
	-I$(CORES_DIR)/sysctl/rtl	\
	-I$(CORES_DIR)/uart/rtl		\
	-I$(CORES_DIR)/wb_uart/rtl		\
	-I$(CORES_DIR)/wb_ddr/rtl		\
	-I$(CORES_DIR)/bram/rtl		
#	-I$(CORES_DIR)/uart_core/rtl		

LIBDIR = 				\
	-y$(CORES_DIR)/lm32/rtl		\
	-y$(CORES_DIR)/wb_ddr/rtl

SIM_SRC=						\
	$(wildcard $(TOPDIR)/unisims/*.v)		\
	$(BOARD_DIR)/../../gen_capabilities.v		\
	$(BOARD_DIR)/ddram.v		\
	$(BOARD_DIR)/system_monitor.v		\
	$(wildcard $(CORES_DIR)/16_bit_interface/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/conbus/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/csrbrg/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/lcd_2x16/rtl/*.v)	\
	$(wildcard $(CORES_DIR)/monitor/rtl/*.v)	\
	$(wildcard $(CORES_DIR)/norflash16/rtl/*.v)	\
	$(wildcard $(CORES_DIR)/uart/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/wb_uart/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/wb_ddr/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/bram/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/fmlarb/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/fmlbrg/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/hpdmc_ddr16/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/hpdmc_ddr16/rtl/spartan3/*.v)	\
	$(CORES_DIR)/sysctl/rtl/sysctl.v		\
	$(CORES_DIR)/lm32/rtl/lm32_top.v		\
	$(CORES_DIR)/lm32/rtl/lm32_cpu.v		\
	$(CORES_DIR)/lm32/rtl/lm32_instruction_unit.v	\
	$(CORES_DIR)/lm32/rtl/lm32_decoder.v		\
	$(CORES_DIR)/lm32/rtl/lm32_load_store_unit.v	\
	$(CORES_DIR)/lm32/rtl/lm32_adder.v		\
	$(CORES_DIR)/lm32/rtl/lm32_addsub.v		\
	$(CORES_DIR)/lm32/rtl/lm32_logic_op.v		\
	$(CORES_DIR)/lm32/rtl/lm32_shifter.v		\
	$(CORES_DIR)/lm32/rtl/lm32_multiplier.v		\
	$(CORES_DIR)/lm32/rtl/lm32_mc_arithmetic.v	\
	$(CORES_DIR)/lm32/rtl/lm32_interrupt.v		\
	$(CORES_DIR)/lm32/rtl/lm32_icache.v		\
	$(CORES_DIR)/lm32/rtl/lm32_dcache.v		\
	$(CORES_DIR)/lm32/rtl/lm32_trace.v		\
	$(CORES_DIR)/lm32/rtl/lm32_ram.v	
##	$(CORES_DIR)/lm32/rtl/lm32_simtrace.v		\

EXEC = system_tb


all: isim bios.rom

cversim: $(SRC) bios.rom
	cver +define+SIMULATION +incdir+$(BOARD_DIR) +incdir+$(CORES_DIR)/lm32/rtl $(SRC)

isim: system_tb bios.rom
	rm -f sim.log
	./$(EXEC)
######>> sim.log

#$(EXEC).v	
${EXEC}: $(SRC) $(SIM_SRC) system_tb.v
	rm -f $@.list
	@for i in `echo $^`; do \
	    echo $$i >> $@.list; \
	done
	rm -rf make.log
	iverilog -Tmax -v -D SIMULATION_DDR $(VINCDIR) $(LIBDIR) -c $@.list -o ${EXEC} -s $@ >> make.log 2>&1



bios.rom:
	../../../tools/bin2hex $(BIN) bios.rom 35288

clean:
	rm -f verilog.log bios.rom system ${EXEC} ${EXEC}.vcd *~ make.log search.log *.list

.PHONY: clean cversim isim


####-D SIMULATION 
