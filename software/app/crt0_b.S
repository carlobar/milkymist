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
_start:

	xor	r0, r0, r0
	xor	r2, r2, r2
	calli	_crt0


_crt0:

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

	mvhi    r4, hi(.clearBSS)
	ori     r4, r4, lo(.clearBSS)



.clearBSS:
	bge      r1, r3, .callMain
	sw      (r1+0), r0
	addi    r1, r1, 4
	addi    r6, r6, 1
//	bge	r6, r7, .inc
//	bi	.normal
/*
.inc:
	addi	r8, r8, 1

	mvhi r6, hi(0x00000000)
	ori  r6, r6, lo(0x00000000)
*/
//.normal:
//	sw     (r5+0), r1

	b      r4
/*	nop
	nop
	nop
	nop
	nop
*/

.callMain:




	mv      r1, r2
	mvi     r2, 0
	mvi     r3, 0
	calli   main_app






