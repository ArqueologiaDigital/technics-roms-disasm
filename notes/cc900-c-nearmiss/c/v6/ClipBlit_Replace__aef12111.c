/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m273.c (2026-11-18-28-p6-r36)
   sha256 aef1211117a3ec94925755b0307806a542d2fb02afda4d6ae73d44578cd99b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void ClipBlit_Replace_Impl(struct pt *, int);
extern void ClipBlit_Replace_ParamBlock(unsigned char *q);
void ClipBlit_Replace(struct pt *p, int n)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		ClipBlit_Replace_Impl(p, n);
	else {
		q = DrawQueue_Alloc(10);
		*(void **)q = (void *)ClipBlit_Replace_ParamBlock;
		*(struct pt *)(q + 4) = *p;
		*(int *)(q + 8) = n;
		DrawRing_Post(q);
	}
}
