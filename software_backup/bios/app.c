#include <stdio.h>
#include <console.h>
#include <string.h>
#include <uart.h>
#include <cffat.h>
#include <crc.h>
#include <system.h>
#include <board.h>
#include <version.h>
#include <net/mdio.h>
#include <hw/vga.h>
#include <hw/fmlbrg.h>
#include <hw/sysctl.h>
#include <hw/capabilities.h>
#include <hw/gpio.h>
#include <hw/uart.h>
#include <hw/hpdmc.h>
/*
#include "boot.h"
#include "splash.h"
*/

int main_app (void)
{
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
