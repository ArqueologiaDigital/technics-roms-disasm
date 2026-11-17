/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1a.c (2026-11-16-31-p6-r1b)
   sha256 9750c74bf124b2aa99540b8b4b6fdaab7ef7968b5c9e4dc00f22f063b001454d (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_68d;
extern unsigned char __near ram_68e;
extern unsigned char __near ram_68f;
void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out)
{
	unsigned char v;

	if (m == 1) {
		if (ram_68e < 1 || ram_68e > 4) ram_68e = 1;
		v = ram_68e;
	} else if (m == 0) {
		if (ram_68d < 1 || ram_68d > 4) ram_68d = 1;
		v = ram_68d;
	} else if (m == 2) {
		if (ram_68f < 1 || ram_68f > 4) ram_68f = 1;
		v = ram_68f;
	} else {
		v = 1;
	}
	*out = v;
}
