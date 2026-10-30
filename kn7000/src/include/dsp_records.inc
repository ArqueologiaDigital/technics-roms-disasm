# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# dsp_records.inc -- the effects-DSP (IC306, ADSP-21065L "SHARC") download records the program
# flash holds (tools/gen_data_s.py dsp_pool; format: tools/gen_dsp_records.py, dsp/README.md).
# The main CPU streams a record's blocks through the DSP's host port; a block is a 12-byte
# big-endian header {u16 0x2004, u8 mode (0x80 program memory, 0x00 data memory), u8 flag (0xFF
# on a record's last block), u16 0, u16 target word address, u16 0, u16 payload bytes} and its
# payload: 48-bit instruction words (PM, three big-endian u16, most significant first) or
# 40-bit data words (DM, five bytes, most significant first).  A record ends with zero bytes.
.equ DSP_DM, 0x00
.equ DSP_PM, 0x80
.macro DSP_BLOCK mode, last, target, len
	.be16	0x2004
	.byte	\mode, \last
	.be16	0, \target, 0, \len
.endm
# one 48-bit SHARC instruction word
.macro pm48 w
	.be16	(\w >> 32) & 0xFFFF, (\w >> 16) & 0xFFFF, \w & 0xFFFF
.endm
# one 40-bit SHARC data word
.macro dm40 w
	.byte	(\w >> 32) & 0xFF, (\w >> 24) & 0xFF, (\w >> 16) & 0xFF, (\w >> 8) & 0xFF, \w & 0xFF
.endm
