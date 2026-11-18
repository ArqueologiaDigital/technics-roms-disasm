/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/note_voice_mapping_m303.c (2026-11-18-33-p6-r37)
   sha256 b00b819b1f1e3ab10e62306079eeb061d7ffed6ce8230b905389cf45668a16d4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		return;
	if (*q == 0x78)
		return;
	if (*p <= 0x7f) {
		*q &= 7;
		return;
	}
	if (*q == 7) {
		*p &= 0x7f;
		c = 0x70;
	} else if (*p <= 0xef) {
		if (*q == 0) {
			*p &= 0x7f;
			c = 0x10;
		} else if (*q == 5) {
			*p &= 0x7f;
			c = 0x15;
		} else
			goto def;
	} else if (*q <= 1) {
		*p &= 0x0f;
		*q = (*q & 1) | 0x40;
		return;
	} else if (*q == 6) {
		*p = 0;
		c = 0x50;
	} else if (*q == 5) {
		*p &= 3;
		c = 0x55;
	} else {
def:
		*p = 0;
		c = 0;
	}
	*q = c;
}
