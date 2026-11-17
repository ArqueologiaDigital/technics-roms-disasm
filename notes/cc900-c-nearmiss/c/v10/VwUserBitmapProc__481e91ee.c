/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_3b.c (2026-11-16-87-p6-r15)
   sha256 481e91eead3ceefdb058e23cebef22e5ee666e58418da1c436f01791ef9b88e3 (tar-sha256); compiled at -O3 -XS -Xr */
#define EVT_DRAW              0x1c0000dL
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawBitmap(struct pt *, unsigned char *);
extern void DrawBitmapSPFast(struct pt *, unsigned char *, int, int);
extern long ApFuncCall(long, long, long);
long VwUserBitmapProc(long obj, long evt, long p)
{
	int w;
	unsigned char *data;
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		DrawBitmapSPFast(&(&pt)[0], data, w, (int)ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0));
	} else
		DrawBitmap(&pt, 0);
	return 0;
}
