/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m276b.c (2026-11-19-29-p6-r46)
   sha256 81d28e10228b2da42045c8e3b694a80498679f85ced6d8e707c7604f61dc63cc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct w2 { unsigned int lo, hi; };
struct dramreg { unsigned long *start; unsigned long len; unsigned char bitlo, bithi; };
extern struct dramreg DramTest_IC10IC9_Regions[];
unsigned char Test_DRAM_IC10_and_IC9(unsigned char err)
{
	unsigned char i;
	unsigned long n;
	struct dramreg *r;
	unsigned long *p;
	unsigned long save;
	struct w2 t;

	for (i = 0; i != 1; i++) {
		r = &DramTest_IC10IC9_Regions[i];
		p = r->start;
		n = r->len >> 3;
		if (n != 0) {
			do {
				save = *p;
				*p = 0x5a5a5a5aL;
				t = *(struct w2 *)p;
				if (t.lo != 0x5a5a)
					err |= r->bitlo;
				if (t.hi != 0x5a5a)
					err |= r->bithi;
				*p++ = save;
				save = *p;
				*p = 0xa5a5a5a5L;
				t = *(struct w2 *)p;
				if (t.lo != 0xa5a5)
					err |= r->bitlo;
				if (t.hi != 0xa5a5)
					err |= r->bithi;
				*p++ = save;
			} while (--n != 0);
		}
	}
	return err;
}
