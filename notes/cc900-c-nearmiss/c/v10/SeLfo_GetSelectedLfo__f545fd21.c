/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_68d;
extern unsigned char __near ram_68e;
extern unsigned char __near ram_68f;
void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out)
{
	if (m == 1) {
		if (ram_68e == 0 || ram_68e > 4) ram_68e = 1;
		*out = ram_68e;
	} else if (m == 0) {
		if (ram_68d == 0 || ram_68d > 4) ram_68d = 1;
		*out = ram_68d;
	} else if (m == 2) {
		if (ram_68f == 0 || ram_68f > 4) ram_68f = 1;
		*out = ram_68f;
	} else {
		*out = 1;
	}
}
