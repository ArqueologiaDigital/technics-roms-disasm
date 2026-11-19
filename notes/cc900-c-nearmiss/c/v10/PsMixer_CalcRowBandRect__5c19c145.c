/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m264b.c (2026-11-19-22-p6-r45)
   sha256 5c19c145ec22c050c34d7e4160b61f6d0a7890759a14f39d9bb446b7e15ef835 (tar-sha256); compiled at -O3 -Xr */
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
	int k = 136;

	col = i % 5;
	yo = ram_3ea30[i].yoff;
	GetEditSwPoint(k + col, &pt);
	r->y0 = pt.y - 9 - col;
	r->x0 = 8;
	r->x1 = 311;
	r->y1 = pt.y + 31 - col;
	r->y0 += yo;
	r->y1 += yo;
}
