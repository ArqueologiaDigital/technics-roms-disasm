/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_2b.c (2026-11-16-68-p6-r12)
   sha256 2ca26b192e096ba6df33b1a615d63ad105088e6c3995401325c7357b66fc74a9 (tar-sha256); compiled at -O3 -Xr */
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
	int hg;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		DrawBitmapSPFast(&pt, data, w, hg = ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0));
	} else
		DrawBitmap(&pt, 0);
	return 0;
}
