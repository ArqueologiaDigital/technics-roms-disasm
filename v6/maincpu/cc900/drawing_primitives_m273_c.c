/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern void SetChangeRect(struct rect *r);
extern void MovePixels_Impl(struct rect *r, struct pt *dst);

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
