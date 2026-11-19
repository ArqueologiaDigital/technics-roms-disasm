/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m273a.c (2026-11-19-13-p6-r41)
   sha256 f40c01f97f71fab2d231354e5451dd9ea490a9cf86d312b41e5ca413bf477718 (tar-sha256); compiled at -O3 -XS -Xr */
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
