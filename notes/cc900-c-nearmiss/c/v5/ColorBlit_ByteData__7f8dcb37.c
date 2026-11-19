/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/graphics_text_vga_m273.c (2026-11-19-15-p6-r42)
   sha256 7f8dcb37eb1620bd38af2526fb8493e95b9a3af424c9481b037e06a58b8f7560 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
struct rop { int code; struct rect r; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
void ColorBlit_ByteData(struct rop *p)
{
	struct rect r;

	r.x0 = p->r.x0;
	r.y0 = p->r.y0;
	r.x1 = p->r.x1;
	r.y1 = p->r.y1;
	ColorBlit2(&r, GFX_BG_COLOR);
}
