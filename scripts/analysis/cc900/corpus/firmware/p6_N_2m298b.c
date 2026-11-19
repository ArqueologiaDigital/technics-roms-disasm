/* lane_p6 helper N, round 2, form b: module 298 (audio/note_voice_mapping.s).
   SndParam_UpdateChannelTuning, form b against a: the record fields as byte arrays at their own addresses (the
   ROM's bases 0xc66a / 0xc66c / 0xc66f / 0xc670) indexed by slot * 8, the 2-byte table indexed by slot * 2, and
   an if chain in place of the switch.
   cc900-options: -Xr
*/

extern unsigned char CharMap_ValueData_A[];
extern unsigned char __near ram_cd42;
extern unsigned char __near ram_cd44;
extern unsigned char __near ram_e82e[];
extern unsigned char __near ram_c66a[];
extern unsigned char __near ram_c66c[];
extern unsigned char __near ram_c66f[];
extern unsigned char __near ram_c670[];

unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e)
{
	unsigned char r;

	if (m != 0xff) {
		ram_cd44 = CharMap_ValueData_A[m];
		ram_cd42 = ram_e82e[ram_cd44 * 2];
	}
	if (ram_cd42 == ram_cd44)
		return 0xff;
	if (ram_c66a[ram_cd42 * 8] != c)
		return 0xff;
	if (e == 2)
		r = ram_c670[ram_cd42 * 8];
	else if (e == 1)
		r = ram_c66f[ram_cd42 * 8];
	else if (e == 0)
		r = ram_c66c[ram_cd42 * 8];
	else
		r = 0xff;
	ram_cd42 = ram_e82e[ram_cd42 * 2];
	return r;
}
