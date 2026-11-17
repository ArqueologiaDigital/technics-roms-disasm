/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines.c (2026-11-16-33-p6-r2)
   sha256 014e13a2c00b6b3a0aaa9c6d6f4631f2f4a7e51b9d6d2853c7e55012ad0a38b7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
