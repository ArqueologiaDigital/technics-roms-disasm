/* lane_p6 helper N, round 4, form a: module 298 (audio/note_voice_mapping.s), retry of p6_N_2m298a / b
   (p6-r43 Xr: +4).  SndParam_UpdateChannelTuning: round 2's form a has the ROM's shape except
   - the tables are indexed with an unsigned 32-bit index (sll, extz xwa, add) where the ROM uses the signed 16-bit
     `(xbc+wa)` form after sla: the tables are SIZED here (the handoff's `tab8[cell]` idiom);
   - the two early exits share the ROM's final `ld l,0xff; ret`: one if with && around the body, else 0xff.
   cc900-options: -Xr
*/

struct ct2 { unsigned char next; unsigned char pad; };
struct ct8 { unsigned char id; unsigned char x1; unsigned char v0; unsigned char x3, x4; unsigned char v1, v2;
             unsigned char x7; };
extern unsigned char CharMap_ValueData_A[];
extern unsigned char __near ram_cd42;
extern unsigned char __near ram_cd44;
extern struct ct2 __near ram_e82e[128];
extern struct ct8 __near ram_c66a[128];

unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e)
{
	unsigned char r;

	if (m != 0xff) {
		ram_cd44 = CharMap_ValueData_A[m];
		ram_cd42 = ram_e82e[ram_cd44].next;
	}
	if (ram_cd42 != ram_cd44 && ram_c66a[ram_cd42].id == c) {
		switch (e) {
		case 0:
			r = ram_c66a[ram_cd42].v0;
			break;
		case 1:
			r = ram_c66a[ram_cd42].v1;
			break;
		case 2:
			r = ram_c66a[ram_cd42].v2;
			break;
		default:
			r = 0xff;
			break;
		}
		ram_cd42 = ram_e82e[ram_cd42].next;
	} else
		r = 0xff;
	return r;
}
