/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit2 DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void GraphicsRender_RetStub(unsigned char *p);
struct rect { int x0, y0, x1, y1; };
struct csrc { int code; unsigned int pos; unsigned int w; int h; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_ComputeRectAndBlit(struct csrc *s);
struct gtab36 { void (*f[36])(unsigned char *); };
extern struct gtab36 GraphicsRender_ProcessEntries_PtrTable;
extern void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end);
struct gtab12 { void (*f[12])(unsigned char *); };
extern struct gtab12 GraphicsRender_Start_PtrTable;
extern void GraphicsRender_Start(unsigned char *p, unsigned char *end);

void GraphicsRender_RetStub(unsigned char *p)
{
}

void ColorBlit_ComputeRectAndBlit(struct csrc *s)
{
	struct rect r;

	r.y0 = s->pos / 40;
	r.x0 = (s->pos % 40) * 8;
	r.y1 = s->h + r.y0;
	r.x1 = r.x0 + s->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab36 t;
	unsigned char c;

	t = GraphicsRender_ProcessEntries_PtrTable;
	while (end > p) {
		c = p[0];
		len = p[1];
		if (c > 35) {
			GraphicsRender_RetStub(p);
			break;
		}
		t.f[c](p);
		p += len;
	}
}

void GraphicsRender_Start(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab12 t;
	unsigned char c;

	t = GraphicsRender_Start_PtrTable;
	while (end > p) {
		c = p[0];
		len = p[1];
		if (c > 11) {
			GraphicsRender_RetStub(p);
			break;
		}
		t.f[c](p);
		p += len;
	}
}
