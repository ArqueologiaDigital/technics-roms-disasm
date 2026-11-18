/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_window_procs_m273.c (2026-11-18-28-p6-r36)
   sha256 aef1211117a3ec94925755b0307806a542d2fb02afda4d6ae73d44578cd99b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void DrawDottedLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawDottedLineMode_ParamBlock(unsigned char *q);
void DrawDottedLineWithMode(struct pt *a, struct pt *b, int m)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawDottedLineWithMode_Impl(a, b, m);
	} else {
		q = DrawQueue_Alloc(16);
		*(void **)q = (void *)DrawDottedLineMode_ParamBlock;
		*(struct pt *)(q + 4) = *a;
		*(struct pt *)(q + 8) = *b;
		*(int *)(q + 12) = m;
		q[14] = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}
