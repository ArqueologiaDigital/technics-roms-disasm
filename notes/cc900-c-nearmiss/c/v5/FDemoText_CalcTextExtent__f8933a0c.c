/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/fdemotext_routines_m265.c (2026-11-18-33-p6-r37)
   sha256 f8933a0c23bace04b6aa910b6a95ed3941f5ebb30005d59819d28d7148e56dd2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
extern char ram_251da[];
extern void FDemoText_ScaleDownCoords(struct pt *, struct pt *);
extern void FDemoText_ScaleUpCoords(struct pt *, struct pt *);
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
