/* Phase 6, lane_p6 helper J, round 5, module 273 (ui/drawing_primitives.s, -O3 -Xr), form a: MovePixels_Impl.
   Copy the off-screen pixels of rectangle r (inclusive) to the same-size area at *dst, pixel by pixel in row
   order, then mark r dirty.  The ROM keeps r in XWA throughout, x in HL, w / h / y in the frame, the source and
   destination points as two struct locals (source the higher slot: declared first). */
/* cc900-module: SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern void SetChangeRect(struct rect *r);

void MovePixels_Impl(struct rect *r, struct pt *dst)
{
	struct pt s;
	struct pt d;
	int w;
	int h;
	int y;
	int x;

	w = r->x1 - r->x0;
	if (w < 0)
		return;
	h = r->y1 - r->y0;
	if (h < 0)
		return;
	for (y = 0; y <= h; y++)
		for (x = 0; x <= w; x++) {
			s.x = r->x0 + x;
			s.y = r->y0 + y;
			d.x = dst->x + x;
			d.y = dst->y + y;
			OFFSCREEN_BUFFER_1[d.y][d.x] = OFFSCREEN_BUFFER_1[s.y][s.x];
		}
	SetChangeRect(r);
}
