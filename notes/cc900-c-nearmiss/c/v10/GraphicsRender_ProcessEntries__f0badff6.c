/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m273a.c (2026-11-19-22-p6-r45)
   sha256 f0badff697cb6bd599db6920afdc8722c20859090cabe0063d100964421a090f (tar-sha256); compiled at -Xr */
struct gtab36 { void (*f[36])(unsigned char *); };
extern struct gtab36 GraphicsRender_ProcessEntries_PtrTable;
extern void GraphicsRender_RetStub(unsigned char *p);
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
