/* lane_p6 helper N, round 8, form a: module 303 (audio/note_voice_mapping.s), retry of p6_N_7m303a
   (p6-r51 Xr: +0).  ApplyProgramChangeAs_LoadDRAM2: V4.23 called the long multiply (C9H_mullu) and so needed a
   frame; the ROM multiplies the zero-extended byte by DE with the 16 x 16 -> 32 `mul xbc,de`, as a leaf.  Form a:
   both multiply operands cast to unsigned long from 16-bit values.
   cc900-options: -O3 -Xr
*/

struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;

void ApplyProgramChangeAs_LoadDRAM2(unsigned char *p, long off, unsigned int m)
{
	unsigned char *t;
	unsigned int *w;

	t = *(unsigned char **)((unsigned char *)SOUND_TABLE_BASE + off);
	w = (unsigned int *)(t + 0x80 + (unsigned long)(unsigned int)t[p[4]] * (unsigned long)m
	                     + ((unsigned int)p[3] << 2));
	p[0] = w[0];
	p[1] = w[1];
}
