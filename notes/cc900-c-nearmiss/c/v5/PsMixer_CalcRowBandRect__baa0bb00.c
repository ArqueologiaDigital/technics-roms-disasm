/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawbar_panel_ui_m264.c (2026-11-19-29-p6-r46)
   sha256 baa0bb0005e06040ed8e81354ec5d8ecdeee4ed6589b97492360eb8082f63f92 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct mixrow { int f0; int f2; int yoff; int f6; int f8; int f10; };
extern struct mixrow *ram_3ea2c;
extern void GetEditSwPoint(unsigned int, struct pt *);
void PsMixer_CalcRowBandRect(struct rect *r, int i)
{
	int yo;
	int col;
	struct pt pt;

	col = i % 5;
	yo = ram_3ea2c[i].yoff;
	GetEditSwPoint((0, 136) + col, &pt);
	r->y0 = pt.y - 9 - col;
	r->x0 = 8;
	r->x1 = 311;
	r->y1 = pt.y + 31 - col;
	r->y0 += yo;
	r->y1 += yo;
}
