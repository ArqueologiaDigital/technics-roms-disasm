/* Phase 6, lane_p6 helper L, round 1, form b: module 285, SndParam_RelocateAndApply with the record read through the
   loop pointer itself, the mask patch spelled q->b | (*p & ~q->a), and the base patch through *p++. */
/* cc900-module: SndParam_GetBlockPointer */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ent { unsigned char *addr; unsigned char a; unsigned char b; };
struct sblk { struct ent base[23]; struct ent mask[16]; };
extern struct sblk *SndParam_GetBlockPointer(int k);
extern void SndParam_RelocateAndApply(long base, unsigned char k);

void SndParam_RelocateAndApply(long base, unsigned char k)
{
	struct sblk *b;
	struct ent *e;
	struct ent *end;
	unsigned char *p;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	end = b->mask + 16;
	for (e = b->mask; e < end; e++)
		if (e->addr != 0) {
			p = e->addr - 0xf980 + base;
			*p = e->b | (*p & ~e->a);
		}
	end = b->mask;
	for (e = b->base; e < end; e++)
		if (e->addr != 0) {
			p = e->addr - 0xf980 + base;
			*p = (*p & 0xf8) | e->a;
			p++;
			*p = e->b;
		}
}
