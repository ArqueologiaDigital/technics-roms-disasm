/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_ScaleDownCoords FDemoText_ScaleUpCoords */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern char ram_251da[];
extern void FDemoText_ScaleDownCoords(struct pt *, struct pt *);
extern void FDemoText_ScaleUpCoords(struct pt *, struct pt *);
extern int FDemoText_CalcTextExtent(struct pt *p);

int FDemoText_CalcTextExtent(struct pt *p)
{
	struct pt a;
	struct pt b;
	int i;
	int w;

	FDemoText_ScaleDownCoords(p, &a);
	FDemoText_ScaleUpCoords(&a, &b);
	i = a.x + 1;
	w = b.x + 8 - p->x;
	for (; i < 40; i++) {
		if (ram_251da[a.y * 40 + i] != 'T')
			break;
		w += 8;
	}
	return w;
}
