/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 7d3aa481ffa9df690d518ad1de0c8064a21f839050676cab225bd106300437ea (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
		hg = ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0);
		DrawBitmapSPFast((struct pt *)&pt.x, data, w, hg);
	} else
		DrawBitmap(&pt, 0);
	return 0;
}
