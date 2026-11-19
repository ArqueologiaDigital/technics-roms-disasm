/* Phase 6, lane_p6 helper L, round 5, form a: module 271 (audio/presentation_sound_nav.s), retries.
   - SetWallColor (r46 Xr +3): the ROM's bodies follow the compares in the order default, 0xf8, 2, 0xf9, 1, the
     last falling into the tail jp: the default written FIRST in the switch.
   - TtlScreenProc (r46 O3Xr +66): the ROM computes the rect's address into XWA before the stack pushes and keeps
     the PsPageBox flag in DE: the address assigned to a pointer local just before the call (idiom 1). */
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
extern long TtlScreenProc(long obj, long evt, long par);

void SetWallColor(int c)
{
	int n;

	switch (c) {
	default:
		n = 0;
		break;
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
	}
	ChangeWallPalette(n);
}

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
