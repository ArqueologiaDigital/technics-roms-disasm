/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/presentation_sound_nav_m0.c (2026-11-19-43-p6-r48)
   sha256 4f13fc32be3c94c6f865429ec450b2dcad807a28467af1d73b7434f6ed7c75f5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_DRAW 0x1c0000dL
#define EVT_SEARCH_CLASS 0x1e00024L
#define NAKA_CLASS_PsPageBox 0x1600024L
struct rect { int x0, y0, x1, y1; };
struct tview { char p0[14]; struct rect r; char p22[12]; long f34; long f38; };
extern long ScreenProc(long obj, long evt, long par);
extern struct tview *GetViewInstance(long id);
extern long SendEvent(long, long, long);
extern void DrawTitleBar(struct rect *r, long a, int b, long c, unsigned int d);
long TtlScreenProc(long obj, long evt, long par)
{
	struct tview *v;
	struct rect r;
	unsigned int f;
	struct rect *pr;

	if (evt != EVT_DRAW)
		return ScreenProc(obj, evt, par);
	ScreenProc(obj, evt, par);
	v = GetViewInstance(obj);
	r = v->r;
	f = (unsigned int)(SendEvent(obj, EVT_SEARCH_CLASS, NAKA_CLASS_PsPageBox) != 0);
	pr = &r;
	DrawTitleBar(pr, v->f38, 0, v->f34, f);
	return 0;
}
