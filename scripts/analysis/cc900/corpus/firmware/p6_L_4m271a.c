/* Phase 6, lane_p6 helper L, round 4, form a: module 271 (audio/presentation_sound_nav.s), new.
   - SetWallColor: palette 8 / 6 / 4 / 2 / 0 for colour 1 / 0xf9 / 2 / 0xf8 / other, then ChangeWallPalette (a
     tail jp).  A switch: the ROM compares 1, 0xf9, 2, 0xf8 (last case first) and places the default right after
     the compares (a default written last).
   - IvScreenProc: everything but EVT_DRAW goes to ScreenProc (a conditional tail jrl); EVT_DRAW returns 0.
   - TtlScreenProc: ScreenProc first; on EVT_DRAW also the title bar: the view's rect copied, whether a PsPageBox
     is in it ((unsigned int)(x != 0), the ROM's scc), DrawTitleBar(&rect, v+38, 0, v+34, flag). */
/* cc900-module: DrawTitleBar ScreenProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW 0x1c0000dL
#define EVT_SEARCH_CLASS 0x1e00024L
#define NAKA_CLASS_PsPageBox 0x1600024L
struct rect { int x0, y0, x1, y1; };
struct tview { char p0[14]; struct rect r; char p22[12]; long f34; long f38; };
extern void ChangeWallPalette(int n);
extern long ScreenProc(long obj, long evt, long par);
extern struct tview *GetViewInstance(long id);
extern long SendEvent(long, long, long);
extern void DrawTitleBar(struct rect *r, long a, int b, long c, unsigned int d);
extern void SetWallColor(int c);
extern long IvScreenProc(long obj, long evt, long par);
extern long TtlScreenProc(long obj, long evt, long par);

void SetWallColor(int c)
{
	int n;

	switch (c) {
	case 0xf8:
		n = 2;
		break;
	case 2:
		n = 4;
		break;
	case 0xf9:
		n = 6;
		break;
	case 1:
		n = 8;
		break;
	default:
		n = 0;
	}
	ChangeWallPalette(n);
}

long IvScreenProc(long obj, long evt, long par)
{
	if (evt != EVT_DRAW)
		return ScreenProc(obj, evt, par);
	return 0;
}

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
