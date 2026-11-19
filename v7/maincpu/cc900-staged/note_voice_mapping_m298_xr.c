/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ct2 { unsigned char next; unsigned char pad; };
struct ct8 { unsigned char id; unsigned char x1; unsigned char v0; unsigned char x3, x4; unsigned char v1, v2;
             unsigned char x7; };
extern unsigned char CharMap_ValueData_A[];
extern unsigned char __near ram_cca6;
extern unsigned char __near ram_cca8;
extern struct ct2 __near ram_e768[128];
extern struct ct8 __near ram_c5ce[128];
extern unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e);

unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e)
{
	unsigned char r;

	if (m != 0xff) {
		ram_cca8 = CharMap_ValueData_A[m];
		ram_cca6 = ram_e768[ram_cca8].next;
	}
	if (ram_cca6 != ram_cca8 && ram_c5ce[ram_cca6].id == c) {
		switch (e) {
		case 0:
			r = ram_c5ce[ram_cca6].v0;
			break;
		case 1:
			r = ram_c5ce[ram_cca6].v1;
			break;
		case 2:
			r = ram_c5ce[ram_cca6].v2;
			break;
		default:
			r = 0xff;
			break;
		}
		ram_cca6 = ram_e768[ram_cca6].next;
	} else
		r = 0xff;
	return r;
}
