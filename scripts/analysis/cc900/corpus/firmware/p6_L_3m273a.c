/* Phase 6, lane_p6 helper L, round 3, form a: module 273, graphics_text_vga.s only.  Retry of round 1's form a
   (O3Xr: right size, first diff at +24 / +30 = the loop compare): the ROM compares the end with the pointer
   (`cp (end), p` with ule / ugt), so the loop is written `end > p`. */
/* cc900-module: GraphicsRender_RetStub */   /* scripts/analysis/cc900/module_calls.py v10 */

struct gtab36 { void (*f[36])(unsigned char *); };
struct gtab12 { void (*f[12])(unsigned char *); };
extern struct gtab36 GraphicsRender_ProcessEntries_PtrTable;
extern struct gtab12 GraphicsRender_Start_PtrTable;
extern void GraphicsRender_RetStub(unsigned char *p);
extern void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end);
extern void GraphicsRender_Start(unsigned char *p, unsigned char *end);

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
