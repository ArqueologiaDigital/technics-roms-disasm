/* Phase 6, lane_p6 helper L, round 3, form b: module 264, PsMixer_CalcRowBandRect with the switch base 136 in an
   initialised int local (lane_sub's constant-through-a-local idiom), added to the column. */
/* (no module-local callee) */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct mixrow { int f0; int f2; int yoff; int f6; int f8; int f10; };
extern struct mixrow *ram_3ea30;
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void PsMixer_CalcRowBandRect(struct rect *r, int i);

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
