MMDIR=../..
include $(MMDIR)/software/include.mak

APP=app_a.bin app_b.bin
#OBJ=app_a.o app_b.o $OBJ)
OBJECTS=crt0.o  isr.o main.o unlzma.o boot.o boot-helper.o
SEGMENTS=-j .text -j .data -j .rodata
FILE1=app.c

all: bios.bin 

%.bin: %.elf
	$(MAKE) -C $(MMDIR)/tools
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@
	chmod -x $@
	$(MMDIR)/tools/mkmmimg $@ write

# make sure the linker*.ld at the first of depends
bios.elf: linker.ld $(OBJECTS)
bios-rescue.elf: linker-rescue.ld $(OBJECTS)

%.elf:
	$(LD) $(LDFLAGS) -T $< -N -o $@ $(OBJECTS) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libhal -L$(MMDIR)/software/libnet --start-group -lhpdmc -lbase-light -lhal -lnet --end-group
	lm32-rtems4.11-objdump -S $@  > $@.dis
	chmod -x $@

#$(OBJ):
#	make -C ../app
#	cp ../app/app_a.bin .
#	cp ../app/app_b.bin .
#	$(LD) -r -b binary -o app_a.o app_a.bin 
#	$(LD) -r -b binary -o app_b.o app_b.bin



.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o bios.elf bios.bin bios-rescue.elf bios-rescue.bin .*~ *~ Makefile.bak *.bin 

# DO NOT DELETE

boot.o: ../../software/include/base/stdio.h
boot.o: ../../software/include/base/stdlib.h
boot.o: ../../software/include/base/console.h
boot.o: ../../software/include/base/uart.h
boot.o: ../../software/include/base/system.h
boot.o: ../../software/include/base/board.h ../../software/include/base/crc.h
boot.o: ../../tools/sfl.h ../../software/include/base/blockdev.h
boot.o: ../../software/include/base/fatfs.h
boot.o: ../../software/include/base/string.h
boot.o: ../../software/include/base/irq.h
boot.o: ../../software/include/net/microudp.h
boot.o: ../../software/include/net/tftp.h ../../software/include/hal/vga.h
boot.o: ../../software/include/hal/usb.h ../../software/include/hw/hpdmc.h
boot.o: ../../software/include/hw/common.h ../../software/include/hw/flash.h
boot.o: boot.h
isr.o: ../../software/include/hw/interrupts.h
isr.o: ../../software/include/base/irq.h ../../software/include/base/uart.h
isr.o: ../../software/include/hal/usb.h ../../software/include/hal/tmu.h
isr.o: ../../software/include/hw/tmu.h ../../software/include/hw/common.h
main.o: ../../software/include/base/stdio.h
main.o: ../../software/include/base/stdlib.h
main.o: ../../software/include/base/console.h
main.o: ../../software/include/base/string.h
main.o: ../../software/include/base/uart.h
main.o: ../../software/include/base/blockdev.h
main.o: ../../software/include/base/fatfs.h ../../software/include/base/crc.h
main.o: ../../software/include/base/system.h
main.o: ../../software/include/base/board.h ../../software/include/base/irq.h
main.o: ../../software/include/base/version.h
main.o: ../../software/include/net/mdio.h ../../software/include/hw/fmlbrg.h
main.o: ../../software/include/hw/sysctl.h ../../software/include/hw/common.h
main.o: ../../software/include/hw/gpio.h ../../software/include/hw/flash.h
main.o: ../../software/include/hal/vga.h ../../software/include/hal/tmu.h
main.o: ../../software/include/hw/tmu.h ../../software/include/hal/brd.h
main.o: ../../software/include/hal/usb.h ../../software/include/hal/ukb.h
main.o: boot.h splash.h
splash.o: ../../software/include/base/stdio.h
splash.o: ../../software/include/base/stdlib.h
splash.o: ../../software/include/hal/vga.h ../../software/include/hw/flash.h
splash.o: splash.h


# main.o unlzma.o boot.o boot-helper.o
# OBJECTS=crt0.o isr.o main.o unlzma.o boot.o boot-helper.o splash.o
