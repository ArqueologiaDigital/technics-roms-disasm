/* Phase 6, lane_p6 helper L, round 1, form a: module 285 (midi/midi_dispatch_handlers.s).
   - SndParam_RelocateAndApply: a block of 6-byte records {address, a, b} (23 base records, then 16 mask records
     at +138); each non-null address is relocated (- 0xf980 + base) and patched.  The ROM reads each record
     through a copy of the loop pointer (q = e); neither loop tests its bound at entry (constant extents). */
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
	unsigned char *p;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	for (e = b->mask; e < b->mask + 16; e++) {
		q = e;
		if (q->addr != 0) {
			p = q->addr - 0xf980 + base;
			*p = (~q->a & *p) | q->b;
		}
	}
	for (e = b->base; e < b->mask; e++) {
		q = e;
		if (q->addr != 0) {
			p = q->addr - 0xf980 + base;
			p[0] = (p[0] & 0xf8) | q->a;
			p[1] = q->b;
		}
	}
}
