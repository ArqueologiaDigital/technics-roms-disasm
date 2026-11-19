/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m273a.c (2026-11-19-22-p6-r45)
   sha256 f0badff697cb6bd599db6920afdc8722c20859090cabe0063d100964421a090f (tar-sha256); compiled at -Xr */
struct gtab12 { void (*f[12])(unsigned char *); };
extern struct gtab12 GraphicsRender_Start_PtrTable;
extern void GraphicsRender_RetStub(unsigned char *p);
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
