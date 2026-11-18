/* Phase 6, lane_p6 helper K, round 5, module 264 (ui/drawbar_panel_ui.s; the module's matched C is -Xr), form a:
   PsMixer_DrawFrameBoxWithDividers(r, c).  Gets frame 52's size (GetFrameSPSize), lowers a copy of r by the frame
   height - 2, draws it with DrawDesignBox(.., 193, c), then 7 pairs of vertical divider lines (colours 248 / 255,
   one pixel apart) from x = 45 every 37 pixels, from the box's top + 2 to its bottom - 2.  The address-taken locals
   are declared in the reverse of their frame order (rr highest ... h lowest); the divider counter i reuses IZ. */

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
	for (i = 0; i < 7; i++) {
		DrawLine(&p1, &p2, 248);
		p1.x++;
		p2.x++;
		DrawLine(&p1, &p2, 255);
		p1.x += 37;
		p2.x += 37;
	}
}
