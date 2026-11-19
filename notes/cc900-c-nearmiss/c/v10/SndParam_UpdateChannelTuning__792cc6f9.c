/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m298b.c (2026-11-19-29-p6-r46)
   sha256 792cc6f9d4c47369ae76056ccb840629aaccafe3ae43adcf4d82bd4229f9bbbc (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct ct2 { unsigned char next; unsigned char pad; };
struct ct8 { unsigned char id; unsigned char x1; unsigned char v0; unsigned char x3, x4; unsigned char v1, v2;
             unsigned char x7; };
extern unsigned char CharMap_ValueData_A[];
extern unsigned char __near ram_cd42;
extern unsigned char __near ram_cd44;
extern struct ct2 __near ram_e82e[];
extern struct ct8 __near ram_c66a[];
unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e)
{
	unsigned char r;

	if (m != 0xff) {
		ram_cd44 = CharMap_ValueData_A[m];
		ram_cd42 = ram_e82e[(int)ram_cd44].next;
	}
	if (ram_cd42 != ram_cd44 && ram_c66a[(int)ram_cd42].id == c) {
		switch (e) {
		case 0:
			r = ram_c66a[(int)ram_cd42].v0;
			break;
		case 1:
			r = ram_c66a[(int)ram_cd42].v1;
			break;
		case 2:
			r = ram_c66a[(int)ram_cd42].v2;
			break;
		default:
			r = 0xff;
			break;
		}
		ram_cd42 = ram_e82e[(int)ram_cd42].next;
	} else
		r = 0xff;
	return r;
}
