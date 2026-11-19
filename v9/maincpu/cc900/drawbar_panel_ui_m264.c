/* Functions of ui/drawbar_panel_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawLine(struct pt *a, struct pt *b, int c);
extern void PsMixer_DrawFrameBoxWithDividers(struct rect *r, int c);

void PsMixer_DrawFrameBoxWithDividers(struct rect *r, int c)
{
	struct rect rr;
	struct pt p1;
	struct pt p2;
	unsigned int w;
	unsigned int h;
	int i;

	GetFrameSPSize(52, &w, &h);
	rr = *r;
	rr.y0 += h - 2;
	DrawDesignBox(&rr, 193, c);
	p1.x = 45;
	p1.y = rr.y0 + 2;
	p2.x = 45;
	p2.y = rr.y1 - 2;
	for (i = 0; i < 7; i++) {
		DrawLine(&p1, &p2, 248);
		p1.x++;
		p2.x++;
		DrawLine(&p1, &p2, 255);
		p1.x += 37;
		p2.x += 37;
	}
}

struct mixrow { int f0; int f2; int yoff; int f6; int f8; int f10; };
extern struct mixrow *ram_3ea30;
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void PsMixer_CalcRowBandRect(struct rect *r, int i);

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
