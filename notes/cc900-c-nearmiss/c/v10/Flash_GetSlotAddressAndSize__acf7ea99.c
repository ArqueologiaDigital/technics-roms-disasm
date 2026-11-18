/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1b.c (2026-11-18-12-p6-r35)
   sha256 acf7ea99ecd966e25dc71d003ea5f8afc1bd9c339f1ae78db7134cd0a5ee83e2 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_300000[];
extern unsigned char ram_1e0000[];
int Flash_GetSlotAddressAndSize(unsigned char flags, unsigned int slot, unsigned char **dest, unsigned int *size)
{
	char r;
	unsigned long n;
	unsigned long off;
	unsigned char *base;
	unsigned char *p;

	r = 0;
	n = slot;
	off = n * 470 + 16;
	if (flags & 1) {
		base = ram_300000;
		base += 0xb0400L;
		p = base;
		if (flags & 2) {
			if (slot < 4) {
				*dest = n * 0x2927 + 0x4980 + base;
				*size = 10535;
			} else
				r = 0xff;
		} else {
			if (slot < 40) {
				*dest = off + p;
				*size = 470;
			} else
				r = 0xff;
		}
	} else {
		base = ram_1e0000;
		if (flags & 2) {
			if (slot < 1) {
				*dest = base + 18816;
				*size = 10535;
			} else
				r = 0xff;
		} else {
			if (slot < 40) {
				*dest = base + off;
				*size = 470;
			} else
				r = 0xff;
		}
	}
	return r;
}
