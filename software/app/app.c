#include <stdio.h>
#include <console.h>
#include <string.h>
#include <uart.h>
#include <blockdev.h>


#include <system.h>

#include <irq.h>
#include <version.h>


#include <hw/sysctl.h>




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
