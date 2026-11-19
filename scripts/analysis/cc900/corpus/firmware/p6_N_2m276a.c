/* lane_p6 helper N, round 2, form a: module 276 (ui/ui_mode_handlers.s).
   Test_DRAM_IC10_and_IC9: for each region of DramTest_IC10IC9_Regions (10-byte records: start, length, the error
   bits of the low and the high half-word), writes 0x5a5a5a5a and then 0xa5a5a5a5 over every long, reads it back
   as two words (a 4-byte struct copy: the ROM's two ldiw), ORs the failing half's bit into the error byte and
   restores the long.  Returns the error byte (the parameter it started from).
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
	struct dramreg *r;
	unsigned long *p;
	unsigned long n;

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
