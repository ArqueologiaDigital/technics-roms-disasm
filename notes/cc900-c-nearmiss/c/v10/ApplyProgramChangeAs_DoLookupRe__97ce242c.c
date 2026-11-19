/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m303a.c (2026-11-19-56-p6-r51)
   sha256 97ce242c2695356d5234b8df831b1bd75d700adbd6df040db8516224771a97f3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;
extern int SndParam_LookupReadOnly(long);
extern unsigned char GetCurrentPartSelect(void);
unsigned char ApplyProgramChangeAs_DoLookupRe(void)
{
	unsigned char r;

	if (SndParam_LookupReadOnly(0xc0L) == 1) {
		if (GetCurrentPartSelect() != 15)
			r = 0x80;
		else
			r = 0x89;
	} else
		r = SOUND_TABLE_BASE->a4;
	return r;
}
