/* Phase 6, lane_p6 helper J, round 5, module 273, form b: MovePixels_Impl with the ROM's frame temporaries spelled
   out -- w computed in place (w = x1; w -= x0), a pointer local to r->y0 (the ROM keeps &r->y0 at xsp+10), and the
   pixel copy through explicit destination / source pointers. */
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
	int *py;
	int x;
	unsigned char *pd;

	w = r->x1;
	if ((w -= r->x0) < 0)
		return;
	py = &r->y0;
	h = r->y1;
	if ((h -= *py) < 0)
		return;
	for (y = 0; y <= h; y++)
		for (x = 0; x <= w; x++) {
			s.x = r->x0 + x;
			s.y = *py + y;
			d.x = dst->x + x;
			d.y = dst->y + y;
			pd = &OFFSCREEN_BUFFER_1[d.y][d.x];
			*pd = OFFSCREEN_BUFFER_1[s.y][s.x];
		}
	SetChangeRect(r);
}
