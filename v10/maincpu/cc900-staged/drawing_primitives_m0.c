/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit2 DrawBitmap_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
extern void DrawBitmap_QueuedExec(struct bmcmd *q);

void DrawBitmap_QueuedExec(struct bmcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmap_Impl(p, bmp);
}
