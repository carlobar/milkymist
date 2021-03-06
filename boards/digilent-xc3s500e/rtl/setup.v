/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
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

/*
 * System clock frequency in Hz.
 */
`define CLKDV_DIVIDE 	2.0

`define CLKFX_MULTIPLY 	2.0//8.0
`define CLKFX_DIVIDE 	2.0//5.0

`define CLOCK_FREQUENCY 50000000//80000000// 83333333//

/*
 * System clock period in ns (must be in sync with CLOCK_FREQUENCY).
 */
`define CLOCK_PERIOD 20//12.5//25//12.5//12//
`define CLOCK_PERIOD_ 20//12//25//12.5//12//

/*
 * Default baudrate for the debug UART.
 */
`define BAUD_RATE 115200

/*
 * SDRAM depth, in bytes (the number of bits you need to address the whole
 * array with byte granularity)
 */
`define SDRAM_DEPTH 25

/*
 * SDRAM column depth (the number of column address bits)
 */
`define SDRAM_COLUMNDEPTH 10

`define ENABLE_ETHERNET
//`define ENABLE_SDRAM
