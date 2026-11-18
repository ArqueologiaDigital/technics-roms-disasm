/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_3b.c (2026-11-18-28-p6-r36)
   sha256 6647f84ea1fcb074d27cc130fdb107c4dcc9b6cdea5a23cfc714716c586b5049 (tar-sha256); compiled at -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		goto out;
	if (*q == 0x78)
		goto out;
	if (*p <= 0x7f) {
		*q &= 7;
		goto out;
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
		goto out;
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
out:
	;
}
