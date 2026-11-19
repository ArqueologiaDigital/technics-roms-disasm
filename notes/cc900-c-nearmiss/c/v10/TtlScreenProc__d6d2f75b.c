/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m271a.c (2026-11-19-29-p6-r46)
   sha256 d6d2f75b0e94b203a6f85f6c0deb8195b69561ae0676c5409a0eadf8c707277d (tar-sha256); compiled at -O3 -Xr */
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

	if (evt != EVT_DRAW)
		return ScreenProc(obj, evt, par);
	ScreenProc(obj, evt, par);
	v = GetViewInstance(obj);
	r = v->r;
	f = (unsigned int)(SendEvent(obj, EVT_SEARCH_CLASS, NAKA_CLASS_PsPageBox) != 0);
	DrawTitleBar(&r, v->f38, 0, v->f34, f);
	return 0;
}
