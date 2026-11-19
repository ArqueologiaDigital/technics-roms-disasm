/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct gop5 { unsigned char op; unsigned char len; int x0, y0, x1, y1; };
extern unsigned char COLORBLIT_MODE;
extern int GFX_FG_COLOR;
extern void ColorBlit(struct rect *r, int c);
extern void SeGfx_StaticOp05_FillBoxMode1(struct gop5 *p);

void SeGfx_StaticOp05_FillBoxMode1(struct gop5 *p)
{
	struct rect r;
	unsigned char m;

	r.x0 = p->x0;
	r.y0 = p->y0;
	r.x1 = p->x1;
	r.y1 = p->y1;
	m = COLORBLIT_MODE;
	COLORBLIT_MODE = 1;
	ColorBlit(&r, GFX_FG_COLOR);
	COLORBLIT_MODE = m;
}
