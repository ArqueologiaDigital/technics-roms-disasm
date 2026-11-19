/* Phase 6, lane_p6 helper L, round 3, form a: module 285.  Retry of SndParam_RelocateAndApply (round 1: +16 at
   O3XSXr, the entry test).  The ROM tests neither loop's bound at entry (do-while), keeps the mask end in a register,
   loads the record's address once through the loop pointer into the patch pointer (then - 0xf980, + base in
   place) and reads the record's bytes through a copy of the loop pointer; the base patch ends with *p++ / *p. */
/* cc900-module: SndParam_GetBlockPointer */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ent { unsigned char *addr; unsigned char a; unsigned char b; };
struct sblk { struct ent base[23]; struct ent mask[16]; };
extern struct sblk *SndParam_GetBlockPointer(int k);
extern void SndParam_RelocateAndApply(long base, unsigned char k);

void SndParam_RelocateAndApply(long base, unsigned char k)
{
	struct sblk *b;
	struct ent *e;
	struct ent *q;
	struct ent *end;
	unsigned char *p;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	e = b->mask;
	end = e + 16;
	do {
		q = e;
		p = e->addr;
		if (p != 0) {
			p -= 0xf980;
			p += base;
			*p = (~q->a & *p) | q->b;
		}
	} while (++e < end);
	e = b->base;
	do {
		q = e;
		p = e->addr;
		if (p != 0) {
			p -= 0xf980;
			p += base;
			*p = (*p & 0xf8) | q->a;
			p++;
			*p = q->b;
		}
	} while (++e < b->mask);
}
