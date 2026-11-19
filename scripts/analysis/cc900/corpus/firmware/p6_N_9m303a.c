/* lane_p6 helper N, round 9, form a: module 303 (audio/note_voice_mapping.s), retry of p6_N_8m303b
   (p6-r52 Xr: +4, now a leaf with the ROM's `mul xbc,de`).  ApplyProgramChangeAs_LoadDRAM2: the ROM adds the
   offset to the table base in XHL (base on the left) and keeps the table in XIX, then indexes it with a 32-bit
   add (extz bc, extz xbc), where V4.23 added base into the offset and used the 16-bit (xhl+bc) index.  Form a:
   the table index widened to unsigned long, the record base written t + 0x80 first.
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
	e = t + 0x80;
	e += t[(unsigned long)p[4]] * m;
	w = (unsigned int *)(e + ((unsigned int)p[3] << 2));
	p[0] = w[0];
	p[1] = w[1];
}
