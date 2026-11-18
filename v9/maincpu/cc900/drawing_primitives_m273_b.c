/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSP_Impl DrawBox_Impl DrawFrameSP_Impl DrawFunc_Return DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString(struct rect *r, struct pt *p, char *s, long font, int a, int b);
extern void DrawStringLeftJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b);

void DrawStringLeftJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	int h;
	int d;
	struct pt at;

	h = GetCharHeight(font);
	d = GetCharDescent(font);
	at = *p;
	at.x = r->x0 + 4;
	at.y -= (h - d) / 2;
	at.y += GetCenteredDelta(font);
	DrawString(r, &at, s, font, a, b);
}
