MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS_B=app.o 
SEGMENTS=-j .text -j .data -j .rodata
FILE1=app.c

all:  app.bin

%.bin: %.elf
	$(MAKE) -C $(MMDIR)/tools
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@
	chmod -x $@
	$(MMDIR)/tools/mkmmimg $@ write

%.elf:
	$(LD) $(LDFLAGS) -T $< -N -o $@ $(OBJECTS) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libhal -L$(MMDIR)/software/libnet --start-group -lhpdmc -lbase-light -lhal -lnet --end-group
	lm32-rtems4.11-objdump -S $@  > $@.dis
	chmod -x $@


app.elf: linker_b.ld $(OBJECTS_B)
	$(LD) $(LDFLAGS) -T linker_b.ld -N -o $@ $(OBJECTS_B) -L$(MMDIR)/software/libhpdmc -L$(MMDIR)/software/libbase -lhpdmc -lbase-light 
	lm32-rtems4.11-objdump -S app.elf  > app.dis
	chmod -x $@

app.o: ${FILE1} Makefile
	$(CC) $(CFLAGS) -c ${FILE1} -lm




.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o *.elf *.bin .*~ *~ Makefile.bak *.dis


