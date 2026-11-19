/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
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
