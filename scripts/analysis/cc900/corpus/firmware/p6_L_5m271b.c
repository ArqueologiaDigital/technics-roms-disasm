/* Phase 6, lane_p6 helper L, round 5, form b: module 271, TtlScreenProc with the flag a plain int from `!= 0` (no
   cast; DrawTitleBar's last parameter int) and &r passed directly, to see which register the flag gets. */
/* cc900-module: DrawTitleBar ScreenProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW 0x1c0000dL
#define EVT_SEARCH_CLASS 0x1e00024L
#define NAKA_CLASS_PsPageBox 0x1600024L
struct rect { int x0, y0, x1, y1; };
struct tview { char p0[14]; struct rect r; char p22[12]; long f34; long f38; };
extern long ScreenProc(long obj, long evt, long par);
extern struct tview *GetViewInstance(long id);
extern long SendEvent(long, long, long);
extern void DrawTitleBar(struct rect *r, long a, int b, long c, int d);
extern long TtlScreenProc(long obj, long evt, long par);

long TtlScreenProc(long obj, long evt, long par)
{
	struct tview *v;
	struct rect r;
	int f;

	if (evt != EVT_DRAW)
		return ScreenProc(obj, evt, par);
	ScreenProc(obj, evt, par);
	v = GetViewInstance(obj);
	r = v->r;
	f = SendEvent(obj, EVT_SEARCH_CLASS, NAKA_CLASS_PsPageBox) != 0;
	DrawTitleBar(&r, v->f38, 0, v->f34, f);
	return 0;
}
