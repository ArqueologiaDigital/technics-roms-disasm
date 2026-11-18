/* Phase 6, lane_p6 helper K, round 5, module 264, form b of p6_K_5m264a.c: the divider loop as do/while (the ROM
   has no entry test) and the height adjustment as rr.y0 = rr.y0 + h - 2. */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawLine(struct pt *a, struct pt *b, int c);

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
	i = 0;
	do {
		DrawLine(&p1, &p2, 248);
		p1.x++;
		p2.x++;
		DrawLine(&p1, &p2, 255);
		p1.x += 37;
		p2.x += 37;
	} while (++i < 7);
}
