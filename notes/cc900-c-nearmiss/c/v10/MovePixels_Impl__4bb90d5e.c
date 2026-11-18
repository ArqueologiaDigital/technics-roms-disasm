/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_5m273a.c (2026-11-18-33-p6-r37)
   sha256 4bb90d5e78b7d7d4f409c4a5eada651b2b155ce6dbf285569409f237d0e9519d (tar-sha256); compiled at -O3 -XS -Xr */
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
