/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m264a.c (2026-11-19-22-p6-r45)
   sha256 64c3488900e24174195ceaad6b4e1efa6bb1f054cbe60b1721124153059271bf (tar-sha256); compiled at -Xr */
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
	GetEditSwPoint((0, 136) + col, &pt);
	r->y0 = pt.y - 9 - col;
	r->x0 = 8;
	r->x1 = 311;
	r->y1 = pt.y + 31 - col;
	r->y0 += yo;
	r->y1 += yo;
}
