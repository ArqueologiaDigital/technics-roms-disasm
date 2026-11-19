/* Phase 6, lane_p6 helper L, round 3, form b: module 285, SndParam_RelocateAndApply as form a but the loops as `for`
   with the bound on a local (V4.23 may drop the entry test itself for constant extents), the address relocated
   in one expression, and the second loop bounded by a saved mask pointer. */
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
	struct ent *m;
	unsigned char *p;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	m = b->mask;
	for (e = m; e < m + 16; e++) {
		q = e;
		if ((p = e->addr) != 0) {
			p = p - 0xf980 + base;
			*p = (~q->a & *p) | q->b;
		}
	}
	for (e = b->base; e < m; e++) {
		q = e;
		if ((p = e->addr) != 0) {
			p = p - 0xf980 + base;
			*p = (*p & 0xf8) | q->a;
			*++p = q->b;
		}
	}
}
