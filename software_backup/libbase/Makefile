MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS_ALL=divsi3.o libc.o crc16.o crc32.o console.o cfcard.o cffat.o system.o board.o irq.o
OBJECTS=$(OBJECTS_ALL) softfloat.o softfloat-glue.o vsnprintf.o atof.o malloc.o uart-async.o
OBJECTS_LIGHT=$(OBJECTS_ALL) vsnprintf-nofloat.o uart.o

all: libbase-light.a libbase.a

libbase-light.a: $(OBJECTS_LIGHT)
	$(AR) clr libbase-light.a $(OBJECTS_LIGHT)
	$(RANLIB) libbase-light.a

libbase.a: $(OBJECTS)
	$(AR) clr libbase.a $(OBJECTS)
	$(RANLIB) libbase.a

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o libbase.a libbase-light.a .*~ *~ Makefile.bak

# DO NOT DELETE

atof.o: ../../software/include/base/stdlib.h
atof.o: ../../software/include/base/ctype.h
board.o: ../../software/include/hw/sysctl.h
board.o: ../../software/include/hw/common.h
board.o: ../../software/include/base/stdlib.h
board.o: ../../software/include/base/board.h
cfcard.o: ../../software/include/hw/systemace.h
cfcard.o: ../../software/include/hw/common.h
cfcard.o: ../../software/include/base/cfcard.h
cfcard.o: ../../software/include/base/console.h
cffat.o: ../../software/include/base/stdlib.h
cffat.o: ../../software/include/base/stdio.h
cffat.o: ../../software/include/base/string.h
cffat.o: ../../software/include/base/ctype.h
cffat.o: ../../software/include/base/endian.h
cffat.o: ../../software/include/base/cfcard.h
cffat.o: ../../software/include/base/console.h
cffat.o: ../../software/include/base/cffat.h
console.o: ../../software/include/base/uart.h
console.o: ../../software/include/base/console.h
console.o: ../../software/include/base/stdio.h
console.o: ../../software/include/base/stdlib.h
console.o: ../../software/include/base/stdarg.h
crc16.o: ../../software/include/base/crc.h
crc32.o: ../../software/include/base/crc.h
libc.o: ../../software/include/base/ctype.h
libc.o: ../../software/include/base/stdio.h
libc.o: ../../software/include/base/stdlib.h
libc.o: ../../software/include/base/stdarg.h
libc.o: ../../software/include/base/string.h
libc.o: ../../software/include/base/limits.h
malloc.o: ../../software/include/base/stdio.h
malloc.o: ../../software/include/base/stdlib.h
malloc.o: ../../software/include/base/string.h
malloc.o: ../../software/include/base/console.h
malloc.o: ../../software/include/base/malloc.h
softfloat.o: milieu.h softfloat.h softfloat-macros.h softfloat-specialize.h
softfloat-glue.o: softfloat.h
system.o: ../../software/include/base/irq.h
system.o: ../../software/include/base/uart.h
system.o: ../../software/include/hw/fmlbrg.h
system.o: ../../software/include/hw/sysctl.h
system.o: ../../software/include/hw/common.h
system.o: ../../software/include/base/system.h
uart-async.o: ../../software/include/base/uart.h
uart-async.o: ../../software/include/base/irq.h
uart-async.o: ../../software/include/hw/uart.h
uart-async.o: ../../software/include/hw/common.h
uart-async.o: ../../software/include/hw/interrupts.h
uart.o: ../../software/include/base/uart.h ../../software/include/base/irq.h
uart.o: ../../software/include/hw/uart.h ../../software/include/hw/common.h
uart.o: ../../software/include/hw/interrupts.h
vsnprintf.o: ../../software/include/base/stdlib.h
vsnprintf.o: ../../software/include/base/stdio.h
vsnprintf.o: ../../software/include/base/stdarg.h
vsnprintf.o: ../../software/include/base/string.h
vsnprintf.o: ../../software/include/base/ctype.h
vsnprintf-nofloat.o: ../../software/include/base/stdlib.h
vsnprintf-nofloat.o: ../../software/include/base/stdio.h
vsnprintf-nofloat.o: ../../software/include/base/stdarg.h
vsnprintf-nofloat.o: ../../software/include/base/string.h
vsnprintf-nofloat.o: ../../software/include/base/ctype.h
