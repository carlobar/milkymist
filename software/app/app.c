
#include <stdio.h>
#include <console.h>
#include <string.h>
#include <uart.h>
#include <blockdev.h>
#include <fatfs.h>
#include <crc.h>
#include <system.h>
#include <board.h>
#include <irq.h>
#include <version.h>
#include <net/mdio.h>
#include <hw/fmlbrg.h>
#include <hw/sysctl.h>
#include <hw/gpio.h>
#include <hw/flash.h>

#include <hal/vga.h>
#include <hal/tmu.h>
#include <hal/brd.h>
#include <hal/usb.h>
#include <hal/ukb.h>


int main_app (void)
{

irq_setmask(0);
irq_enable(1);
uart_init();

   int global2 = 200;
   int global1 = 300;
   printf("global1 = %d global2 = %d \n", global1, global2);
   global2 = global2 * global1;
   printf("global1 = %d global1+global2 = %d \n", global1, global2);

while(1 == 1)
{
}

   return 0;
}
