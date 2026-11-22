/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m273.c (2026-11-22-6-p6-r73)
   sha256 d4d3022fdce2ce1ffc15f6e990b69e81e8c4dd8b5bd9fbe55d92dc94440e636d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void ChangeWallPalette_Impl(unsigned int);
void ChangeWallPalette_QueueCallback(struct icmd *q);
extern void ChangeWallPalette_QueueCallback(struct icmd *q);
void ChangeWallPalette(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangeWallPalette_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangeWallPalette_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}
