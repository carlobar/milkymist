MMDIR=../..
include $(MMDIR)/software/include.mak
OBJECTS_B=crt0_b.o app.o 
OBJECTS=crt0.o main.o boot.o splash.o
SEGMENTS=-j .text -j .data -j .rodata
FILE1=app.c

all: bios_splash.bin app.bin bios.bin

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@
	chmod -x $@
	$(MMDIR)/tools/crc32 $@ write

bios.elf: linker.ld $(OBJECTS) $(MMDIR)/software/libhpdmc/libhpdmc.S $(MMDIR)/software/libbase/libbase-light.a $(MMDIR)/software/libnet/libnet.a
	make -C $(MMDIR)/software/libhpdmc clean
	make -C $(MMDIR)/software/libhpdmc
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libnet -lhpdmc -lbase-light -lnet
	chmod -x $@

app.elf: linker.ld $(OBJECTS_B)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS_B) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libnet -lhpdmc -lbase-light -lnet
	lm32-rtems4.11-objdump -S app.elf  > app.dis
	chmod -x $@

app.o: ${FILE1} Makefile
	$(CC) $(CFLAGS) -c ${FILE1} -lm


$(MMDIR)/software/libbase/libbase-light.a:
	make -C $(MMDIR)/software/libbase

$(MMDIR)/software/libnet/libnet.a:	
	make -C $(MMDIR)/software/libnet

splash.raw: splash.png
	$(MMDIR)/tools/makeraw splash.png

bios_padded.bin: bios.bin
	dd if=bios.bin of=bios_padded.bin bs=65536 conv=sync

bios_splash.bin: bios_padded.bin splash.raw
	cat bios_padded.bin splash.raw > bios_splash.bin

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o bios.elf bios.bin bios_padded.bin splash.raw bios_splash.bin .*~ *~ Makefile.bak bios.dis

# DO NOT DELETE

boot.o: ../../software/include/base/stdio.h
boot.o: ../../software/include/base/stdlib.h
boot.o: ../../software/include/base/console.h
boot.o: ../../software/include/base/uart.h
boot.o: ../../software/include/base/system.h
boot.o: ../../software/include/base/board.h
boot.o: ../../software/include/base/cffat.h ../../software/include/base/crc.h
boot.o: ../../tools/sfl.h ../../software/include/net/microudp.h
boot.o: ../../software/include/net/tftp.h ../../software/include/hw/hpdmc.h
boot.o: ../../software/include/hw/common.h boot.h
main.o: ../../software/include/base/stdio.h
main.o: ../../software/include/base/stdlib.h
main.o: ../../software/include/base/console.h
main.o: ../../software/include/base/string.h
main.o: ../../software/include/base/uart.h
main.o: ../../software/include/base/cffat.h ../../software/include/base/crc.h
main.o: ../../software/include/base/system.h
main.o: ../../software/include/base/board.h
main.o: ../../software/include/base/version.h
main.o: ../../software/include/net/mdio.h ../../software/include/hw/vga.h
main.o: ../../software/include/hw/common.h ../../software/include/hw/fmlbrg.h
main.o: ../../software/include/hw/sysctl.h
main.o: ../../software/include/hw/capabilities.h
main.o: ../../software/include/hw/gpio.h ../../software/include/hw/uart.h
main.o: ../../software/include/hw/hpdmc.h boot.h splash.h
splash.o: ../../software/include/base/stdio.h
splash.o: ../../software/include/base/stdlib.h
splash.o: ../../software/include/hw/vga.h ../../software/include/hw/common.h
splash.o: splash.h
