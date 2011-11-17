MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS=crt0_b.o isr.o app.o  
SEGMENTS=-j .text -j .data -j .rodata
FILE1=app.c

all:  app.bin 

%.bin: %.elf
	$(MAKE) -C $(MMDIR)/tools
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@
	chmod -x $@
	$(MMDIR)/tools/mkmmimg $@ write #--set-start 0x40000000 

app.elf: linker_b.ld $(OBJECTS) crt0_b.S
	$(LD) $(LDFLAGS) -T linker_b.ld -N -o $@ $(OBJECTS) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libhal -L$(MMDIR)/software/libnet --start-group -lhpdmc -lbase-light -lhal -lnet --end-group
	lm32-uclinux-objdump -S app.elf  > app.dis
	chmod -x $@

#app.o: ${FILE1} Makefile 
#	$(CC) $(CFLAGS) -c ${FILE1} -lm

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o *.elf *.bin .*~ *~ Makefile.bak *.dis

## crt0_b.o 
