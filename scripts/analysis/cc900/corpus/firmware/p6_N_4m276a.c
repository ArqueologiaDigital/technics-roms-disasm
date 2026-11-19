/* lane_p6 helper N, round 4, form a: module 276 (ui/ui_mode_handlers.s), retry of p6_N_2m276a (p6-r43 O3Xr: +29).
   Test_DRAM_IC10_and_IC9: the listing is the ROM's code with the variables in other homes -- V4.23 put the saved
   long in XIZ, the record in XHL, the pointer in XDE and the count in the frame (+6); the ROM has the count in
   XIZ, the record in XDE, the pointer in XHL and the saved long in the frame.  Form a: `register` on the count,
   the record and the pointer (record before pointer), the saved long plain.
   cc900-options: -O3 -Xr
*/

struct w2 { unsigned int lo, hi; };
struct dramreg { unsigned long *start; unsigned long len; unsigned char bitlo, bithi; };
extern struct dramreg DramTest_IC10IC9_Regions[];

unsigned char Test_DRAM_IC10_and_IC9(unsigned char err)
{
	unsigned char i;
	unsigned long save;
	struct w2 t;
	register struct dramreg *r;
	register unsigned long *p;
	register unsigned long n;

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
