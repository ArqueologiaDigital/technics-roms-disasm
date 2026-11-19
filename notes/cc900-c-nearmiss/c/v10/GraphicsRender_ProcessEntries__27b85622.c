/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m273b.c (2026-11-19-15-p6-r42)
   sha256 27b8562296593c324b178b766789eb79047182dd28bd128e5880a1af4620f70d (tar-sha256); compiled at -O3 -Xr */
struct gtab36 { void (*f[36])(unsigned char *); };
extern struct gtab36 GraphicsRender_ProcessEntries_PtrTable;
extern void GraphicsRender_RetStub(unsigned char *p);
void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab36 t;
	unsigned char c;

	t = *(struct gtab36 *)(unsigned long)&GraphicsRender_ProcessEntries_PtrTable;
	if (p < end) {
		do {
			c = p[0];
			len = p[1];
			if (c > 35) {
				GraphicsRender_RetStub(p);
				return;
			}
			t.f[c](p);
			p += len;
		} while (p < end);
	}
}
