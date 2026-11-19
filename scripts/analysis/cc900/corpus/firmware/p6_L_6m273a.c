/* Phase 6, lane_p6 helper L, round 6, form a: module 273 (display/graphics_text_vga.s), new; neighbours of the
   matched GraphicsRender_* (same record format: op byte, length byte, then data).
   - SeGfx_StaticOp05_FillBoxMode1: a box from the record's four words, ColorBlit in mode 1 with the foreground
     colour, the previous blit mode restored (the ROM keeps it in QIZ's low byte, saving only QIZ, as V4.23 did
     for FDC_CmdRecalibrate).
   - ColorBlit_WithPaletteSave: a box picked from a table of 4-word boxes (pointer at +7) by a masked, shifted byte
     read through a 16-bit address (+2), mask +4, shift +5; then the same mode-1 ColorBlit.  The shift written
     `v >>= s` (V4.23 adds the `and 15; jr z` itself), the index `(unsigned char)(v << 2)` words. */
/* cc900-module: ColorBlit */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct gop5 { unsigned char op; unsigned char len; int x0, y0, x1, y1; };
extern unsigned char COLORBLIT_MODE;
extern int GFX_FG_COLOR;
extern void ColorBlit(struct rect *r, int c);
extern void SeGfx_StaticOp05_FillBoxMode1(struct gop5 *p);
extern void ColorBlit_WithPaletteSave(unsigned char *p);

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

void ColorBlit_WithPaletteSave(unsigned char *p)
{
	struct rect r;
	unsigned char m;
	unsigned char v;
	unsigned char s;
	int *e;

	v = *(unsigned char *)(unsigned long)*(unsigned int *)(p + 2) & p[4];
	s = p[5];
	v >>= s;
	e = *(int **)(p + 7) + (unsigned char)(v << 2);
	r.x0 = e[0];
	r.y0 = e[1];
	r.x1 = e[2];
	r.y1 = e[3];
	m = COLORBLIT_MODE;
	COLORBLIT_MODE = 1;
	ColorBlit(&r, GFX_FG_COLOR);
	COLORBLIT_MODE = m;
}
