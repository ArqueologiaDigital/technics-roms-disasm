/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m264a.c (2026-11-19-15-p6-r42)
   sha256 1c7140f4f6706caa67022be1c58ca9bc887a0035360f063bd13feb3c8917d981 (tar-sha256); compiled at -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct mixrow { int f0; int f2; int yoff; int f6; int f8; int f10; };
extern struct mixrow *ram_3ea30;
extern void GetEditSwPoint(unsigned int, struct pt *);
void PsMixer_CalcRowBandRect(struct rect *r, int i)
{
	int yo;
	int col;
	struct pt pt;

	col = i % 5;
	yo = ram_3ea30[i].yoff;
	GetEditSwPoint(136 + col, &pt);
	r->y0 = pt.y - 9 - col;
	r->x0 = 8;
	r->x1 = 311;
	r->y1 = pt.y + 31 - col;
	r->y0 += yo;
	r->y1 += yo;
}
