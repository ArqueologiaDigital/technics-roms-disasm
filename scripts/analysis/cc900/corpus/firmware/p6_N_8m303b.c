/* lane_p6 helper N, round 8, form b: module 303 (audio/note_voice_mapping.s), retry of p6_N_7m303a.
   ApplyProgramChangeAs_LoadDRAM2, form b against a: the record size an unsigned int product (`mul` gives 32 bits
   in XBC, of which a 16-bit product needs only BC), the entry address built in steps.
   cc900-options: -O3 -Xr
*/

struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;

void ApplyProgramChangeAs_LoadDRAM2(unsigned char *p, long off, unsigned int m)
{
	unsigned char *t;
	unsigned char *e;
	unsigned int *w;

	t = *(unsigned char **)((unsigned char *)SOUND_TABLE_BASE + off);
	e = t + 0x80 + t[p[4]] * m;
	w = (unsigned int *)(e + ((unsigned int)p[3] << 2));
	p[0] = w[0];
	p[1] = w[1];
}
