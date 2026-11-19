/* lane_p6 helper N, round 2, form a: module 298 (audio/note_voice_mapping.s).
   SndParam_UpdateChannelTuning: for character code m (0xff: keep the current one) looks up the tone slot
   (CharMap_ValueData_A -> 0xcd44 -> the 2-byte table at 0xe82e -> 0xcd42); unless the chain ends, and when the slot's
   8-byte record at 0xc66a has id c, returns its byte 2 / 5 / 6 for e = 0 / 1 / 2 (else 0xff) and steps 0xcd42 to
   the next slot.  The ROM reloads 0xcd42 every time and moves table bytes memory-to-memory into the __near cells:
   -Xr (the built file of this module, note_voice_mapping_m298_xr.c, is -Xr).  Form a: struct arrays.
   cc900-options: -Xr
*/

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
		ram_cd42 = ram_e82e[ram_cd44].next;
	}
	if (ram_cd42 == ram_cd44)
		return 0xff;
	if (ram_c66a[ram_cd42].id != c)
		return 0xff;
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
	return r;
}
