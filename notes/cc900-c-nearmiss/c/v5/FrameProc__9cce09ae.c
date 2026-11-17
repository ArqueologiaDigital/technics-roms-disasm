/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_window_procs_m0.c (2026-11-16-92-p6-r18)
   sha256 9cce09aefe6231e93a79cc17a188dd3b0a973f216002592f1300127c3f22158a (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void *GetViewInstance(long);
#define EVT_DRAW              0x1c0000dL
struct rect { int x1, y1, x2, y2; };
struct frinst { unsigned char pad[14]; struct rect r; int i22, i24, i26; };
extern void DrawDesignFrame(struct rect *, int, int, int);
extern long ViewableProc(long, long, long);
extern int GetVisible(long);
long FrameProc(long obj, long evt, long p)
{
	struct frinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	if (GetVisible(obj) == 0) return 1;
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	DrawDesignFrame(&h->r, h->i22, h->i24, h->i26);
	return 0;
}
