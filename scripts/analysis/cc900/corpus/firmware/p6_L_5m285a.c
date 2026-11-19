/* Phase 6, lane_p6 helper L, round 5, form a: module 285.  Retry of SndParam_RelocateAndApply (r45: O3Xr was right
   but for a second induction pointer compared with a spilled end, frame 8 instead of 4).  The ROM's record
   pointer XIZ is a copy of the loop pointer, its end in XIY: the shape of V4.23's strength reduction of an
   indexed loop, so the loops are written over an index with q = &b->mask[i] / &b->base[i]. */
/* cc900-module: SndParam_GetBlockPointer */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ent { unsigned char *addr; unsigned char a; unsigned char b; };
struct sblk { struct ent base[23]; struct ent mask[16]; };
extern struct sblk *SndParam_GetBlockPointer(int k);
extern void SndParam_RelocateAndApply(long base, unsigned char k);

void SndParam_RelocateAndApply(long base, unsigned char k)
{
	struct sblk *b;
	struct ent *q;
	unsigned char *p;
	int i;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	for (i = 0; i < 16; i++) {
		q = &b->mask[i];
		p = q->addr;
		if (p != 0) {
			p -= 0xf980;
			p += base;
			*p = (~q->a & *p) | q->b;
		}
	}
	for (i = 0; i < 23; i++) {
		q = &b->base[i];
		p = q->addr;
		if (p != 0) {
			p -= 0xf980;
			p += base;
			*p = (*p & 0xf8) | q->a;
			p++;
			*p = q->b;
		}
	}
}
