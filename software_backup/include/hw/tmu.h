/*
 * Milkymist VJ SoC (Software)
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __HW_TMU_H
#define __HW_TMU_H

#include <hw/common.h>

#define CSR_TMU_CTL		MMPTR(0xe0006000)
#define TMU_CTL_START		0x01
#define TMU_CTL_BUSY		0x01
#define TMU_CTL_CHROMAKEY	0x02

#define CSR_TMU_HMESHLAST	MMPTR(0xe0006004)
#define CSR_TMU_VMESHLAST	MMPTR(0xe0006008)
#define CSR_TMU_BRIGHTNESS	MMPTR(0xe000600C)
#define CSR_TMU_CHROMAKEY	MMPTR(0xe0006010)

#define TMU_BRIGHTNESS_MAX	(63)

#define CSR_TMU_VERTICESADR	MMPTR(0xe0006014)
#define CSR_TMU_TEXFBUF		MMPTR(0xe0006018)
#define CSR_TMU_TEXHRES		MMPTR(0xe000601C)
#define CSR_TMU_TEXVRES		MMPTR(0xe0006020)
#define CSR_TMU_TEXHMASK	MMPTR(0xe0006024)
#define CSR_TMU_TEXVMASK	MMPTR(0xe0006028)

#define TMU_MASK_FULL		(0x3ffff)
#define TMU_FIXEDPOINT_SHIFT	(6)

#define CSR_TMU_DSTFBUF		MMPTR(0xe000602C)
#define CSR_TMU_DSTHRES		MMPTR(0xe0006030)
#define CSR_TMU_DSTVRES		MMPTR(0xe0006034)
#define CSR_TMU_DSTHOFFSET	MMPTR(0xe0006038)
#define CSR_TMU_DSTVOFFSET	MMPTR(0xe000603C)
#define CSR_TMU_DSTSQUAREW	MMPTR(0xe0006040)
#define CSR_TMU_DSTSQUAREH	MMPTR(0xe0006044)

#define CSR_TMU_ALPHA		MMPTR(0xe0006048)

#define TMU_ALPHA_MAX		(63)

struct tmu_vertex {
	int x;
	int y;
} __attribute__((packed));

#define TMU_MESH_MAXSIZE	128

/* Performance monitoring */

#define CSR_TMU_REQ_A		MMPTR(0xe0006050)
#define CSR_TMU_HIT_A		MMPTR(0xe0006054)
#define CSR_TMU_REQ_B		MMPTR(0xe0006058)
#define CSR_TMU_HIT_B		MMPTR(0xe000605C)
#define CSR_TMU_REQ_C		MMPTR(0xe0006060)
#define CSR_TMU_HIT_C		MMPTR(0xe0006064)
#define CSR_TMU_REQ_D		MMPTR(0xe0006068)
#define CSR_TMU_HIT_D		MMPTR(0xe000606C)

#endif /* __HW_TMU_H */

