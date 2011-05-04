/*
 * libHPDMC - SDRAM initialization runtime for Milkymist bootloaders
 * Copyright (C) 2010 Sebastien Bourdeauducq
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation;
 * version 3 of the License.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses>.
 */

#include <hw/uart.h>
#include <hw/hpdmc.h>
#include <hw/vga.h>
#include <hw/interrupts.h>
#include <hw/sysctl.h>
#include <hw/gpio.h>
#include <version.h>

#include "libhpdmc.h"
#include "libhpdmc_timing.h"


/* evaluate feature dependencies */
#if defined(FEAT_MANUAL_CALIBRATION) && defined(FEAT_NO_OUTPUT)
#  error "Can't use FEAT_MANUAL_CALIBRATION with FEAT_NO_OUTPUT"
#endif

#if defined(FEAT_PBC_MANUAL_CALIBRATION) && ! defined(FEAT_MANUAL_CALIBRATION)
#  error "FEAT_PBC_MANUAL_CALIBRATION needs FEAT_MANUAL_CALIBRATION"
#endif

/*
 * GLOBAL VARIABLES
 * r25: Input delay
 * r24: DQS phase
 * r23: return address
 */

#ifndef FEAT_NO_OUTPUT
.macro PRINT str
	mvhi	r1, hi(\str)
	ori	r1, r1, lo(\str)
	calli	print
.endm
#else
.macro PRINT str
.endm
#endif

.macro RETURN rc
	mvi	r1, \rc
	b	r23
.endm

.section .text, "ax", @progbits
.global _sdram_init 
.global print 
.global printint
_sdram_init:

	mv	r23, ra
/*	PRINT(banner)
	PRINT(version)
	PRINT(nl)
	PRINT(nl)
*/
	/*Set mode bypass*/
	mvhi	r2, hi(CSR_HPDMC_SYSTEM)
	ori	r2, r2, lo(CSR_HPDMC_SYSTEM)
	mvu	r3, (HPDMC_SYSTEM_BYPASS)
	sw 	(r2+0), r3	

	/* wait for the PLLs to lock */
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r3, (HPDMC_PLL1_LOCKED|HPDMC_PLL2_LOCKED)
wait_pll:
	lw	r2, (r1+0)
	and	r2, r2, r3
	bne	r2, r3, wait_pll
	


	/* set IDEHPDMC_DQSDELAY_RDYLAY=0, wait for DQS generator ready */

	mvhi	r2, hi(HPDMC_IDELAY_RST)
	ori	r2, r2, lo(HPDMC_IDELAY_RST)
//	mvu	r2, (HPDMC_IDELAY_RST)
	sw	(r1+0), r2
wait_dqs_start:
	lw	r2, (r1+0)
	andi	r2, r2, (HPDMC_DQSDELAY_RDY)
	be	r2, r0, wait_dqs_start
	xor	r25, r25, r25
	xor	r24, r24, r24

	/* send init sequence */
	bi send_init
send_init_return:
	//PRINT(seqcomplete)

#ifdef FEAT_PBC_MANUAL_CALIBRATION
	/* if PBC is pushed, go into debug/manual mode */
	mvhi	r1, hi(CSR_GPIO_IN)
	ori	r1, r1, lo(CSR_GPIO_IN)
	lw	r2, (r1+0)
	andi	r2, r2, (GPIO_PBC)
	bne	r2, r0, mancal
#endif

	bi	autocalibrate
autocalibrate_fail_return:
	//PRINT(autocalfail)
#ifdef FEAT_MANUAL_CALIBRATION
	bi	mancal /* does not return */
#endif
#ifdef FEAT_RETURN_STATUS
	RETURN(LIBHPDMC_CALIBRATION_FAILED)
#endif
	bi	autocalibrate_fail_return

autocalibrate_success_return:
	//PRINT(autocalok)
	
	/* small memory test */
	mv	r1, r0
	xor	r2, r2, r2
	calli	memtest
	be	r1, r0, memtest_fail
	PRINT(continueboot)
	
	RETURN(LIBHPDMC_SUCCESS)

memtest_fail:
	PRINT(testfailmsg)
#ifdef FEAT_MANUAL_CALIBRATION
	bi	config//mancal /* does not return *///
#endif
#ifdef FEAT_RETURN_STATUS
	RETURN(LIBHPDMC_MEMTEST_FAILED)
#endif
memtest_fail_loop:
	bi	memtest_fail_loop

/* clobbers: r1, r2, r3 */
send_init:
	/* Bring CKE high */
	mvhi	r2, hi(CSR_HPDMC_SYSTEM)
	ori	r2, r2, lo(CSR_HPDMC_SYSTEM)
	mvu	r3, (HPDMC_SYSTEM_BYPASS|HPDMC_SYSTEM_RESET|HPDMC_SYSTEM_CKE)
	sw 	(r2+0), r3
	
	ori	r1, r0, 1
	calli	delay
	
	mvhi	r2, hi(CSR_HPDMC_BYPASS)
	ori	r2, r2, lo(CSR_HPDMC_BYPASS)
	
	/* Precharge All ------ No 7*/
	mvu	r3, 0x400B
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay
	
	/* NOP cmd	-------- No 8*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay

	/* Load Extended Mode Register No 9*/
	mvhi	r3, 0x2
	ori	r3, r3, 0x000F
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay
	
	/* NOP cmd	-------- No 10*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay



	/* Load Mode Register ------- No 11*/
	mvu	r3, 0x121F
	sw 	(r2+0), r3
	mvu	r1, 100
	calli	delay


	/* NOP cmd	-------- No 12*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay


	
	/* Precharge All ---- No 13*/
	mvu	r3, 0x400B
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay
	

	/* NOP cmd	-------- No 14*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay

	/* Auto Refresh ---- 15*/
	mvu	r3, 0xD
	sw 	(r2+0), r3
	mvu	r1, 4
	calli	delay
	

	/* NOP cmd	-------- No 16*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay

	/* Auto Refresh  ---- 17*/
	mvu	r3, 0xD
	sw 	(r2+0), r3
	mvu	r1, 4
	calli	delay
	
	/* NOP cmd	-------- No 18*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay

	/* Load Mode Register, Enable DLL --- 19*/
	mvu	r3, 0x021F
	sw 	(r2+0), r3
	mvu	r1, 100
	calli	delay

	/* NOP cmd	-------- No 20*/
	mvu	r3, 0x8
	sw 	(r2+0), r3
	mvu	r1, 1
	calli	delay

	/*set timers*/
	mvhi	r2, hi(CSR_HPDMC_TIMING)
	ori	r2, r2, lo(CSR_HPDMC_TIMING)
	mvhi	r3, hi(HPDMC_TIMING)
	ori	r3, r3, lo(HPDMC_TIMING)
	sw	(r2+0), r3
	
//	sli	r10


	/* All done, get the controller into gear */
	mvhi	r2, hi(CSR_HPDMC_SYSTEM)
	ori	r2, r2, lo(CSR_HPDMC_SYSTEM)
	mvu	r3, (HPDMC_SYSTEM_CKE)
	sw 	(r2+0), r3

	bi	send_init_return

/*
 * TODO: proper dynamic autocalibration:
 * scan IDELAY/DQS and memtest,
 * then place in the middle of the working zone.
 */
/* clobbers: r1, r2, r3, r4 */
autocalibrate:
	mvu	r24, 000 /* DQS phase, change this number for your board */
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	xor	r2, r2, r2
	mvu	r3, (HPDMC_DQSDELAY_CE|HPDMC_DQSDELAY_INC)
	be	r2, r24, dqs_loop_end
dqs_loop:
	sw	(r1+0), r3
dqs_loop_wait:
	lw	r4, (r1+0)
	andi	r4, r4, (HPDMC_DQSDELAY_RDY)
	be	r4, r0, dqs_loop_wait
	addi	r2, r2, 1
	bne	r2, r24, dqs_loop
dqs_loop_end:
	bi	autocalibrate_success_return

#ifdef FEAT_MANUAL_CALIBRATION
/* does not return */
mancal:


	/* enable VGA out */
	mvhi	r1, hi(CSR_VGA_BASEADDRESS)
	ori	r1, r1, lo(CSR_VGA_BASEADDRESS)
	mvhi	r2, 0x4000
	sw 	(r1+0), r2
	mvhi	r1, hi(CSR_VGA_RESET)
	ori	r1, r1, lo(CSR_VGA_RESET)
	sw 	(r1+0), r0
mancal_loop:
////////////////////////
//////////////////////////////////////
////////////////////////////////////
	PRINT(manualkeys)
	mv	r1, r25
	calli	printint
	PRINT(spacer)
	mv	r1, r24
	calli	printint
	PRINT(nl)
	calli	getkey
	mvu	r2, 'u'
	be	r1, r2, inc_input_delay
	mvu	r2, 'd'
	be	r1, r2, dec_input_delay
	mvu	r2, 'U'
	be	r1, r2, inc_dqs_phase
	mvu	r2, 'D'
	be	r1, r2, dec_dqs_phase
	mvu	r2, 't'10
	be	r1, r2, small_test
	mvu	r2, 'T'
	be	r1, r2, big_test
	mvu	r2, 'p'
	be	r1, r2, disp_pattern
	mvu	r2, 'b'
	be	r1, r2, boot
	bi mancal_loop
inc_input_delay:
	mvu	r1, 1
	be	r25, r1, mancal_loop
	addi	r25, r25, 001
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_IDELAY_CE|HPDMC_IDELAY_INC)
	sw	(r1+0), r2
	bi	mancal_loop
dec_input_delay:
	be	r25, r0, mancal_loop
	addi	r25, r25, -1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_IDELAY_CE)
	sw	(r1+0), r2
	bi	mancal_loop
inc_dqs_phase:
	mvu	r1, 255
	be	r24, r1, mancal_loop
	addi	r24, r24, 1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_DQSDELAY_CE|HPDMC_DQSDELAY_INC)
	sw	(r1+0), r2
	bi	wait_dqs
dec_dqs_phase:
	be	r24, r0, mancal_loop
	addi	r24, r24, -1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_DQSDELAY_CE)
	sw	(r1+0), r2
wait_dqs:
	lw	r2, (r1+0)
	andi	r2, r2, HPDMC_DQSDELAY_RDY
	be	r2, r0, wait_dqs
	bi	mancal_loop
small_test:
	xor	r1, r1, r1
	xor	r2, r2, r2
	calli	memtest
	bi	after_test
big_test:
	mvu	r1, 1
	xor	r2, r2, r2
	calli memtest
after_test:
	be	r1, r0, print_test_fail
	PRINT(memtestpassed)
	bi	mancal_loop
print_test_fail:
	PRINT(memtestfailed)
	bi	mancal_loop
disp_pattern:
	mvu	r1, 640
	mvu	r2, 480
	mvu	r7, 12
	mvu	r8, 6
	xor	r4, r4, r4 /* current Y pos */
	mvhi	r5, 0x4000 /* current address */
yloop:
	xor	r3, r3, r3 /* current X pos */
xloop:
	add	r6, r3, r4
	modu	r9, r6, r7
	mvu	r6, 0xffff
	bge	r9, r8, staywhite
	xor	r6, r6, r6
staywhite:
	sh	(r5+0), r6
	addi	r5, r5, 2
	addi	r3, r3, 1
	bne	r3, r1, xloop
	addi	r4, r4, 1
	bne	r4, r2, yloop
	bi	mancal_loop
boot:
	mvhi	r1, hi(CSR_VGA_RESET)
	ori	r1, r1, lo(CSR_VGA_RESET)
	mvi	r2, VGA_RESET
	sw 	(r1+0), r2
	RETURN(LIBHPDMC_SUCCESS)

//////////////////////////////////////////////////////////////////////////
// recursive configuration
config:
	mvhi	r15, hi(0x00000000)		//dqs counter
	ori	r15, r15, lo(0x00000000)	

	mvhi	r16, hi(0x00000000)		//delay counter
	ori	r16, r16, lo(0x00000000)	

	mvhi	r10, hi(0x00000100)		//max dqs
	ori	r10, r10, lo(0x00000100)
	
	mvhi	r11, hi(0x0000012c)		//max delay
	ori	r11, r11, lo(0x0000012c)	

	mvhi	r12, hi(0x00000000)		// increment or decrement
	ori	r12, r12, lo(0x00000000)	

	mvhi	r13, hi(0x00000001)		
	ori	r13, r13, lo(0x00000001)


	mvhi r19, hi(0x41000000)
	ori  r19, r19, lo(0x41000000)
	mvhi r18, hi(0x53334558)
	ori  r18, r18, lo(0x53334558)

	sw   (r19+4), r18
	sw   (r19+0), r11
	lw   r18,(r19+4)
	lw   r17,(r19+0)

/*	mvhi r19, hi(0x80001004)
	ori  r19, r19, lo(0x80001004)
	sw   (r19+0), r18
	mvhi r19, hi(0x80004004)
	ori  r19, r19, lo(0x80004004)
	sw   (r19+0), r17
*/

recursive_conf:

	/// print data
	mv	r1, r25
	calli	printint
	PRINT(spacer)
	mv	r1, r24
	calli	printint
	PRINT(nl)
	//PRINT(spacer)
	//mvu	r1, 1
	xor 	r1, r1, r1
	xor	r2, r2, r2
	calli	memtest
	bne	r1, r0, print_success


/*
	mvhi r19, hi(0x80001004)
	ori  r19, r19, lo(0x80001004)
	sw   (r19+0), r4
	mvhi r19, hi(0x80004004)
	ori  r19, r19, lo(0x80004004)
	sw   (r19+0), r6
	mv	r1, r3
*/
	//calli	printint
	//PRINT(nl)


	
	addi	r15, r15, 1
	be	r15, r10, inc_delay
	bne	r12, r0, dec_dqs


inc_dqs:
	addi	r24, r24, 1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_DQSDELAY_CE|HPDMC_DQSDELAY_INC)
	sw	(r1+0), r2
	bi	wait_dqs_b
dec_dqs:
	addi	r24, r24, -1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_DQSDELAY_CE)
	sw	(r1+0), r2
wait_dqs_b:
	lw	r2, (r1+0)
	andi	r2, r2, HPDMC_DQSDELAY_RDY
	be	r2, r0, wait_dqs_b
	bi	recursive_conf

inc_delay:
	mvhi	r15, hi(0x00000000)
	ori	r15, r15, lo(0x00000000)	
	xor	r12, r13, r12
	addi	r16, r16, 1

	addi	r25, r25, 1
	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_IDELAY_CE|HPDMC_IDELAY_INC)
	sw	(r1+0), r2

	be	r16, r11, end
	bi	recursive_conf

end:
	//PRINT(memtestfailed)
	bi loop_end

print_success:
	PRINT(memtestpassed)
	//bi	boot

loop_end:
	nop
	nop
	nop
	bi loop_end


/* getkey - gets a character from the console
 *
 * inputs:	none
 * outputs:	r1 - character
 * clobbers:	r1
 */
getkey:
	rcsr	r1, IP
	andi	r1, r1, IRQ_UARTRX
	be	r1, r0, getkey
	wcsr	IP, r1
	mvhi	r1, hi(CSR_UART_RXTX)
	ori	r1, r1, lo(CSR_UART_RXTX)
	lw	r1, (r1+0)
	ret
#endif /* FEAT_MANUAL_CALIBRATION */

/* memtest - tests memory
 *
 * inputs:	r1 - big/small
 *              r2 - PRNG seed
 * outputs:	r1 - pass/fail
 * clobbers:	r1, r3, r4, r5, r6, r7
 */
memtest:

	/*write and read memory*/
	// primera escritura
	mvhi r19, hi(0x40000000)
	ori  r19, r19, lo(0x40000000)

	mvhi r4, hi(0xabadface)
	ori  r4, r4, lo(0xabadface)
	sw   (r19+0), r4		// almacenar dato en memoria

	mvhi r19, hi(0x80001004)
	ori  r19, r19, lo(0x80001004)
	sw   (r19+0), r4		// visualizar dato en lcd

	
	// segunda escritura
	mvhi r19, hi(0x40002000)
	ori  r19, r19, lo(0x40002000)

	mvhi r4, hi(0xcafebabe)
	ori  r4, r4, lo(0xcafebabe)
	sw   (r19+0), r4		// almacenar dato en memoria

	mvhi r19, hi(0x80005004)
	ori  r19, r19, lo(0x80005004)
	sw   (r19+0), r4		//visualizar dato en lcd


		// tercera escritura
	mvhi r19, hi(0x40002100)
	ori  r19, r19, lo(0x40002100)

	mvhi r4, hi(0x12345678)
	ori  r4, r4, lo(0x12345678)
	sw   (r19+0), r4		// almacenar dato en memoria


	// primera lectura
	mvhi r19, hi(0x40000000)
	ori  r19, r19, lo(0x40000000)
	lw   r4, (r19+0)		// leer dato	

	// segunda lectura
	mvhi r19, hi(0x40002000)
	ori  r19, r19, lo(0x40002000)
	lw   r5, (r19+0)		// leer dato	


	mvhi r19, hi(0x80004004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0x80004004)
	sw   (r19+0), r4


	mvhi r19, hi(0x80006004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0x80006004)
	sw   (r19+0), r5

//	bi	memtest
/*
	mvhi r13, hi(0x41000000)
	ori  r13, r13, lo(0x41000000)
	mvhi r18, hi(0x53334558)
	ori  r18, r18, lo(0x53334558)
	sw   (r13+4), r18
*/
/*
inc_delay_test:

	mvhi	r1, hi(CSR_HPDMC_IODELAY)
	ori	r1, r1, lo(CSR_HPDMC_IODELAY)
	mvu	r2, (HPDMC_IDELAY_CE|HPDMC_IDELAY_INC)
	sw	(r1+0), r2



// almacenar dato en memoria
	mvhi r19, hi(0x40001000)
	ori  r19, r19, lo(0x40001000)

	mvhi r4, hi(0xabadface)
	ori  r4, r4, lo(0xabadface)
	sw   (r19+0), r4		

	lw   r4, (r19+0)	

	bi 	inc_delay_test
*/

	/* 1. fill with pattern */
	mvhi	r5, 0x4000	/* r5 - current address */
	ori	r5, r5, lo(0x0000)
	mvhi	r3, 0x0ff	/* r3 - remaining words */
	ori	r3, r3, lo(0x0000)
	mv	r4, r3		/* r4 - number of words to test */
	mv	r6, r2		/* r6 - current value of the PRNG */
	mvhi	r7, hi(22695477)
	ori	r7, r7, lo(22695477)
	bne	r1, r0, patloop
	mvhi	r3, 0x10
	ori	r3, r3, lo(0x0000)
	mv	r4, r3
patloop:
	sw	(r5+0), r6
	mul	r6, r6, r7
	addi	r6, r6, 1
	addi	r5, r5, 4
	addi	r3, r3, -1
	bne	r3, r0, patloop
	/* 2. check pattern */
	mvhi	r5, 0x4000	/* r5 - current address */
	ori	r5, r5, lo(0x0000)
	mv	r3, r4		/* r3 - remaining words */
	mv	r6, r2		/* r6 - current value of the PRNG */
chkloop:
	lw	r4, (r5+0)
	bne	r4, r6, testfail
	mul	r6, r6, r7
	addi	r6, r6, 1
	addi	r5, r5, 4
	addi	r3, r3, -1
	bne	r3, r0, chkloop
//	PRINT(memtestpassed)
	mvu	r1, 1
	ret
testfail:

/*
	lw   r5, (r13+4)
	mvhi r19, hi(0x80005004)
	ori  r19, r19, lo(0x80005004)
	sw   (r19+0), r5
*/

// prueba de memoria
// almacenar datos iniciales.
/*
	mvhi r2, hi(0x000001ff)		// cantidad de datos
	ori  r2, r2, lo(0x000001ff)
	mvhi r4, hi(0xabadface)		// dato que se almacena
	ori  r4, r4, lo(0xabadface)
	mvhi r19, hi(0x40000000)	// direccion de inicio
	ori  r19, r19, lo(0x40000000)
	sw   (r19+0), r4
	sw   (r19+8), r4
*/

// direccion que se evalua
/*
	mvhi r18, hi(0x40000000)
	ori  r18, r18, lo(0x40000000)
loop_test:
	// escribir dato
	sw   (r18+0), r4		

	// verificar datos
	lw	r5, (r19+0)
	bne	r5, r4, fail
	lw	r5, (r19+8)
	bne	r5, r4, fail
	lw	r5, (r18+0)
	bne	r5, r4, fail
	addi	r18, r18, 4
	addi	r2, r2, -1
	bne	r2, r0, loop_test
	calli	print_success


fail:
	
*/

//	calli	end
/*
	mvhi r19, hi(0x80001004)
	ori  r19, r19, lo(0x80001004)
	sw   (r19+0), r4
	mvhi r19, hi(0x80004004)
	ori  r19, r19, lo(0x80004004)
	sw   (r19+0), r6

	mvhi r19, hi(0x80005004)
	ori  r19, r19, lo(0x80005004)
	sw   (r19+0), r3


	mvhi r19, hi(0x80006004)
	ori  r19, r19, lo(0x80006004)
	lw   r5, (r13+4)	
	sw   (r19+0), r5
*/
//	PRINT(memtestfailed)



	mvhi r19, hi(0x40001000)
	ori  r19, r19, lo(0x40001000)

	mvhi r4, hi(0xabadface)
	ori  r4, r4, lo(0xabadface)
	sw   (r19+0), r4		// almacenar dato en memoria

	xor	r1, r1, r1
	ret

#ifndef FEAT_NO_OUTPUT
/* printint - prints an integer 0-999
 *
 * inputs:	r1 - input
 * outputs:	none
 * clobbers:	r1, r2, r3, r4
 */
printint:
	mvhi	r2, hi(CSR_UART_RXTX)
	ori	r2, r2, lo(CSR_UART_RXTX)
	
	mvu	r4, 100
	divu	r3, r1, r4
	modu	r1, r1, r4
	addi	r3, r3, '0'
	sw	(r2+0), r3
writeintwait1:
	rcsr	r3, IP
	andi	r3, r3, IRQ_UARTTX
	be	r3, r0, writeintwait1
	wcsr	IP, r3
	
	mvu	r4, 10
	divu	r3, r1, r4
	modu	r1, r1, r4
	addi	r3, r3, '0'
	sw	(r2+0), r3
writeintwait2:
	rcsr	r3, IP
	andi	r3, r3, IRQ_UARTTX
	be	r3, r0, writeintwait2
	wcsr	IP, r3
	
	addi	r3, r1, '0'
	sw	(r2+0), r3
writeintwait3:
	rcsr	r3, IP
	andi	r3, r3, IRQ_UARTTX
	be	r3, r0, writeintwait3
	wcsr	IP, r3

	ret

/* print - prints a zero terminated string on the console
 *
 * inputs:	r1 - address of the string
 * outputs:	none
 * clobbers:	r1, r2, r3
 */
print:
	mvhi	r2, hi(CSR_UART_RXTX)
	ori	r2, r2, lo(CSR_UART_RXTX)
writeloop:
	lb	r3, (r1+0)
	be	r3, r0, print_endloop
	sw	(r2+0), r3
writewait:
	rcsr	r3, IP
	andi	r3, r3, IRQ_UARTTX
	be	r3, r0, writewait
	wcsr	IP, r3
	addi	r1, r1, 1
	bi	writeloop
print_endloop:
	ret
#endif /* FEAT_NO_OUTPUT */

/* delay - delay loop
 *
 * inputs:	r1 - number of iterations
 * outputs:	none
 * clobbers:	r1
 */
delay:
	addi	r1, r1, -1
	bne	r1, r0, delay
	ret

#ifndef FEAT_NO_OUTPUT
.section .rodata, "a"
banner: .string "\nlibHPDMC SDRAM initialization runtime\n(c) Copyright 2010 Sebastien Bourdeauducq, released under GNU LGPL version 3.\nVersion "
version: .string VERSION
seqcomplete: .string "Initialization sequence completed.\n"
autocalfail: .string "Autocalibration failed, entering manual mode.\n"
autocalok: .string "Autocalibration OK, testing memory...\n"
continueboot: .string "All SDRAM initialization completed, boot continuing.\n\n"
testfailmsg: .string "Memory test failed, entering manual mode.\n"
manualkeys: .string "\nu: inc. input delay // d: dec. input delay\nU: inc. DQS phase   // D: dec. DQS phase\nt: test (small)     // T: test (large)\np: display pattern\nb: boot\n"
memtestfailed: .string "Memory test failed.\n"
memtestpassed: .string "Memory test passed.\n"
spacer: .string " -- "
nl: .string "\n"
#endif /* FEAT_NO_OUTPUT */


