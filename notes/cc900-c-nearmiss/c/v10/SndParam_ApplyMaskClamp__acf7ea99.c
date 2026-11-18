/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1b.c (2026-11-18-12-p6-r35)
   sha256 acf7ea99ecd966e25dc71d003ea5f8afc1bd9c339f1ae78db7134cd0a5ee83e2 (tar-sha256); compiled at -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		return;
	if (*q == 0x78)
		return;
	if (*p < 0x80) {
		*q &= 7;
		return;
	}
	if (*q == 7) {
		*p &= 0x7f;
		c = 0x70;
	} else {
		if (*p < 0xf0) {
			if (*q == 0) {
				*p &= 0x7f;
				c = 0x10;
				goto store;
			}
			if (*q == 5) {
				*p &= 0x7f;
				c = 0x15;
				goto store;
			}
		} else {
			if (*q <= 1) {
				*p &= 0x0f;
				*q = (*q & 1) | 0x40;
				return;
			}
			if (*q == 6) {
				*p = 0;
				c = 0x50;
				goto store;
			}
			if (*q == 5) {
				*p &= 3;
				c = 0x55;
				goto store;
			}
		}
		*p = 0;
		c = 0;
	}
store:
	*q = c;
}
