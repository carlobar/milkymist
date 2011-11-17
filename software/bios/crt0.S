/*
 * LatticeMico32 C startup code.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* Exception handlers - Must be 32 bytes long. */
.section    .text, "ax", @progbits
.global     _start
.global 	print_lcd 
.global		copy_app_a
.global		copy_app_b
_start:
_reset_handler:
	xor	r0, r0, r0
	wcsr	IE, r0
	mvhi	r1, hi(_reset_handler)
	ori	r1, r1, lo(_reset_handler)
	wcsr	EBA, r1
	calli	_sdram_init
	xor	r2, r2, r2
	bi	_crt0

_breakpoint_handler:
	nop; nop; nop; nop
	nop; nop; nop; nop

_instruction_bus_error_handler:
	nop; nop; nop; nop
	nop; nop; nop; nop

_watchpoint_hander:
	nop; nop; nop; nop
	nop; nop; nop; nop

_data_bus_error_handler:
	nop; nop; nop; nop
	nop; nop; nop; nop

_divide_by_zero_handler:
	nop; nop; nop; nop
	nop; nop; nop; nop

_interrupt_handler:
	sw      (sp+0), ra
	calli   .save_all
	calli   isr
	bi      .restore_all_and_eret
	nop
	nop
	nop
	nop

macaddress:
	.byte 0x10
	.byte 0xe2
	.byte 0xd5
	.byte 0x00
	.byte 0x00
	.byte 0x00

	/* padding to align to a 32-bit boundary */
	.byte 0x00
	.byte 0x00

_crt0:

	mvhi r4, hi(0xbbbbbbbb)
	ori  r4, r4, lo(0xbbbbbbbb)
	mvhi r19, hi(0xe0004004)
	ori  r19, r19, lo(0xe0004004)
	sw   (r19+0), r4	


	/* Setup stack and global pointer */
	mvhi    sp, hi(_fstack)
	ori     sp, sp, lo(_fstack)
	mvhi    gp, hi(_gp)
	ori     gp, gp, lo(_gp)

	/* Clear BSS */

	mvhi    r1, hi(_fbss)
	ori     r1, r1, lo(_fbss)
	mvhi    r3, hi(_ebss)
	ori     r3, r3, lo(_ebss)

/*
	mvhi    r1, hi(0x40000000)
	ori     r1, r1, lo(0x40000000)
	mvhi    r3, hi(0x40000010)
	ori     r3, r3, lo(0x40000010)
*/
.clearBSS:
	be      r1, r3, .callMain
	sw      (r1+0), r0
	addi    r1, r1, 4
	bi      .clearBSS




.callMain:

	mvhi r4, hi(0xcccccccc)
	ori  r4, r4, lo(0xcccccccc)
	mvhi r19, hi(0xe0005004)
	ori  r19, r19, lo(0xe0005004)
	sw   (r19+0), r4	
/*
	mvhi r4, hi(0xabadface)
	ori  r4, r4, lo(0xabadface)

	mvhi r5, hi(0xcafebabe)
	ori  r5, r5, lo(0xcafebabe)

	mvhi r19, hi(0x44000000)
	ori  r19, r19, lo(0x44000000)
	sw   (r19+0), r4
	sw   (r19+4), r5
*/
	mv      r1, r2
	mvi     r2, 0
	mvi     r3, 0
	bi      main

	calli	print_lcd
	bi	loop

loop:
	nop
	nop
	nop
	nop
	nop
	bi	loop

.save_all:
	addi    sp, sp, -56
	sw      (sp+4), r1
	sw      (sp+8), r2
	sw      (sp+12), r3
	sw      (sp+16), r4
	sw      (sp+20), r5
	sw      (sp+24), r6
	sw      (sp+28), r7
	sw      (sp+32), r8
	sw      (sp+36), r9
	sw      (sp+40), r10
	sw      (sp+48), ea
	sw      (sp+52), ba
	/* ra needs to be moved from initial stack location */
	lw      r1, (sp+56)
	sw      (sp+44), r1
	ret

.restore_all_and_eret:
	lw      r1, (sp+4)
	lw      r2, (sp+8)
	lw      r3, (sp+12)
	lw      r4, (sp+16)
	lw      r5, (sp+20)
	lw      r6, (sp+24)
	lw      r7, (sp+28)
	lw      r8, (sp+32)
	lw      r9, (sp+36)
	lw      r10, (sp+40)
	lw      ra, (sp+44)
	lw      ea, (sp+48)
	lw      ba, (sp+52)
	addi    sp, sp, 56
	eret

print_lcd:

// primera lectura

	mvhi r19, hi(0x40000000)
	ori  r19, r19, lo(0x40000000)
	lw   r4, (r19+0)		// leer dato	
	lw   r5, (r19+4)		// leer dato	


	mvhi r19, hi(0xe0004004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0004004)
	sw   (r19+0), r4

	mvhi r19, hi(0xe0001004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0001004)
	sw   (r19+0), r5
	ret

///////////////////////////////////////////////////////////
/*
copy_app_b:


	mvhi    r1, hi(_start_app_b)
	ori     r1, r1, lo(_start_app_b)
	mvhi    r3, hi(_end_app_b)
	ori     r3, r3, lo(_end_app_b)
	mvhi    r5, hi(0x40000000)
	ori     r5, r5, lo(0x40000000)


	mvhi r19, hi(0xe0004004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0004004)
	sw   (r19+0), r1

	mvhi r19, hi(0xe0001004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0001004)
	sw   (r19+0), r3


copy_data_b:
	be      r1, r3, end_load_app_b
	lw	r6, (r1+0)
	sw      (r5+0), r6
	addi    r1, r1, 4
	addi    r5, r5, 4
	bi      copy_data_b
end_load_app_b:
	ret



///////////////////////////////////////////////////////////
copy_app_a:



	mvhi    r1, hi(_start_app_a)
	ori     r1, r1, lo(_start_app_a)
	mvhi    r3, hi(_end_app_a)
	ori     r3, r3, lo(_end_app_a)
	mvhi    r5, hi(0x40000000)
	ori     r5, r5, lo(0x40000000)

	mvhi r19, hi(0xe0004004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0004004)
	sw   (r19+0), r1

	mvhi r19, hi(0xe0001004)	// visualizar lectura en lcd
	ori  r19, r19, lo(0xe0001004)
	sw   (r19+0), r3


copy_data_a:
	be      r1, r3, end_load_app_a
	lw	r6, (r1+0)
	sw      (r5+0), r6
	addi    r1, r1, 4
	addi    r5, r5, 4
	bi      copy_data_a
end_load_app_a:
	ret
*/
