/* Phase 6, lane_p6 helper L, round 5, form b: module 285, SndParam_RelocateAndApply over an index as form a, with
   unsigned char counters and the records read as b->mask[i].x directly (no q local). */
/* cc900-module: SndParam_GetBlockPointer */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ent { unsigned char *addr; unsigned char a; unsigned char b; };
struct sblk { struct ent base[23]; struct ent mask[16]; };
extern struct sblk *SndParam_GetBlockPointer(int k);
extern void SndParam_RelocateAndApply(long base, unsigned char k);

void SndParam_RelocateAndApply(long base, unsigned char k)
{
	struct sblk *b;
	unsigned char *p;
	unsigned char i;

	b = SndParam_GetBlockPointer(k);
	if (b == 0)
		return;
	for (i = 0; i < 16; i++)
		if ((p = b->mask[i].addr) != 0) {
			p -= 0xf980;
			p += base;
			*p = (~b->mask[i].a & *p) | b->mask[i].b;
		}
	for (i = 0; i < 23; i++)
		if ((p = b->base[i].addr) != 0) {
			p -= 0xf980;
			p += base;
			*p = (*p & 0xf8) | b->base[i].a;
			p++;
			*p = b->base[i].b;
		}
}
