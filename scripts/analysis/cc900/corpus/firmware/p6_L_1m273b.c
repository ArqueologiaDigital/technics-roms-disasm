/* Phase 6, lane_p6 helper L, round 1, form b: module 273, second spellings of form a's
   - DrawWall_DoCopy: the change rect as four statements in the ROM's store order (y0, x0, x1, y1).
   - GraphicsRender_ProcessEntries / GraphicsRender_Start: the handler table read through a converted pointer
     (the ROM loads its address with `ld xiy, imm`, not lda), the loop spelled as if + do-while, return in place of
     break. */
/* cc900-module: GraphicsRender_RetStub SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SetChangeRect(struct rect *r);
extern void DrawWall_DoCopy(void);

void DrawWall_DoCopy(void)
{
	struct rect r;
	unsigned char *dst;
	unsigned char *src;

	src = WALLPAPER_BITMAP;
	dst = OFFSCREEN_BUFFER_1;
	Mem_Copy(dst, src, 0x9600);
	dst += 0x9600;
	src += 0x9600;
	Mem_Copy(dst, src, 0x9600);
	r.y0 = 0;
	r.x0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
}

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

void GraphicsRender_Start(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab12 t;
	unsigned char c;

	t = *(struct gtab12 *)(unsigned long)&GraphicsRender_Start_PtrTable;
	if (p < end) {
		do {
			c = p[0];
			len = p[1];
			if (c > 11) {
				GraphicsRender_RetStub(p);
				return;
			}
			t.f[c](p);
			p += len;
		} while (p < end);
	}
}
