/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_5m271a.c (2026-11-16-92-p6-r18)
   sha256 26ed91b231e2af8d3d0dfea837cda0ca7364fa20b4ba9832a35202b2f3865ce5 (tar-sha256); compiled at -O3 -XS -Xr */
#define EVT_DRAW              0x1c0000dL
struct rect { int x1, y1, x2, y2; };
struct frinst { unsigned char pad[14]; struct rect r; int i22, i24, i26; };
extern void DrawDesignFrame(struct rect *, int, int, int);
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
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
