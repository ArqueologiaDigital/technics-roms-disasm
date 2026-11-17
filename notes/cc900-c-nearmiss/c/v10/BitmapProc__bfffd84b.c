/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m0.c (2026-11-16-68-p6-r12)
   sha256 bfffd84b3beb256254db5013c671f4d6f1041528555eea470551b42cca2e6092 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawBitmap(struct pt *, unsigned char *);
long BitmapProc(long obj, long evt, long p)
{
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	DrawBitmap(&pt, (unsigned char *)h->l22);
	return 0;
}
