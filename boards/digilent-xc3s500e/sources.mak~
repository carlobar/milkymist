
#========= especificaciones tarjeta
BOARD_SRC=$(wildcard $(BOARD_DIR)/*.v) $(BOARD_DIR)/../../gen_capabilities.v

#========= Comunicación serial
UART_SRC=$(wildcard $(CORES_DIR)/uart/rtl/*.v)

ASFIFO_SRC=$(wildcard $(CORES_DIR)/asfifo/rtl/*.v)


#========= Arbitro y decodificador de direcciones del bus WISHBONE
CONBUS_SRC=$(wildcard $(CORES_DIR)/conbus/rtl/*.v)

#========= Procesador LatticeMico32
LM32_SRC=						\
	$(CORES_DIR)/lm32/rtl/lm32_top.v	\
	$(CORES_DIR)/lm32/rtl/lm32_cpu.v	\
	$(CORES_DIR)/lm32/rtl/lm32_instruction_unit.v	\
	$(CORES_DIR)/lm32/rtl/lm32_decoder.v	\
	$(CORES_DIR)/lm32/rtl/lm32_load_store_unit.v	\
	$(CORES_DIR)/lm32/rtl/lm32_adder.v	\
	$(CORES_DIR)/lm32/rtl/lm32_addsub.v	\
	$(CORES_DIR)/lm32/rtl/lm32_logic_op.v	\
	$(CORES_DIR)/lm32/rtl/lm32_shifter.v	\
	$(CORES_DIR)/lm32/rtl/lm32_multiplier.v	\
	$(CORES_DIR)/lm32/rtl/lm32_mc_arithmetic.v	\
	$(CORES_DIR)/lm32/rtl/lm32_interrupt.v	\
	$(CORES_DIR)/lm32/rtl/lm32_icache.v	\
	$(CORES_DIR)/lm32/rtl/lm32_dcache.v	\
	$(CORES_DIR)/lm32/rtl/lm32_ram.v	\
	$(CORES_DIR)/lm32/rtl/lm32_trace.v	




#========= ??????
CSRBRG_SRC=$(wildcard $(CORES_DIR)/csrbrg/rtl/*.v)

#========= Controlador de la memoria NOR Flash
NORFLASH_SRC=$(wildcard $(CORES_DIR)/norflash16/rtl/*.v)

#========= WISHBONE block RAM 32-bits
BRAM_SRC=$(wildcard $(CORES_DIR)/bram/rtl/*.v)

#========= WISHBONE block RAM 32-bits
DDR_SRC=$(wildcard $(CORES_DIR)/wb_ddr/rtl/*.v)


#========= WISHBONE LCD
LCD_SRC=$(wildcard $(CORES_DIR)/lcd_2x16/rtl/*.v)

#========= Controlador DDR SDRAM 32-bits
HPDMC_SRC=$(wildcard $(CORES_DIR)/hpdmc_ddr16/rtl/*.v) $(wildcard $(CORES_DIR)/hpdmc_ddr16/rtl/spartan3/*.v)

#========= Controlador del sistema
SYSCTL_SRC=$(wildcard $(CORES_DIR)/sysctl/rtl/*.v)

#========= VGA framebuffer
VGAFB_SRC=$(wildcard $(CORES_DIR)/vgafb/rtl/*.v)

#========= ethernet
ETHERNET_SRC=$(wildcard $(CORES_DIR)/minimac/rtl/*.v)

#========= FML arbiter
FMLARB_SRC=$(wildcard $(CORES_DIR)/fmlarb/rtl/*.v)

#========= FML bridge
FMLBRG_SRC=$(wildcard $(CORES_DIR)/fmlbrg/rtl/*.v)

#========= interface 16 bit ddr
INTERFACE16_SRC=$(wildcard $(CORES_DIR)/16_bit_interface/rtl/*.v)

#========= system monitor
MONITOR_SRC=$(wildcard $(CORES_DIR)/monitor/rtl/*.v)

#========= vga controller
VGA_CNT_SRC=$(wildcard $(CORES_DIR)/vga_controller/rtl/*.v)


#========= Todos los cores que se definen
CORES_SRC=$(CONBUS_SRC) $(LM32_SRC) $(CSRBRG_SRC) $(NORFLASH_SRC) $(BRAM_SRC) $(UART_SRC) $(ASFIFO_SRC) $(SYSCTL_SRC) $(HPDMC_SRC) $(VGA_CNT_SRC) $(VGAFB_SRC) $(LCD_SRC) $(DDR_SRC) $(ETHERNET_SRC) $(FMLARB_SRC) $(FMLBRG_SRC) $(INTERFACE16_SRC) $(MONITOR_SRC)
