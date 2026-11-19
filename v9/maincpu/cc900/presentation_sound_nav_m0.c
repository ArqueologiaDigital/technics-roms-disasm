/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawTitleBar ScreenProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW 0x1c0000dL
#define EVT_SEARCH_CLASS 0x1e00024L
#define NAKA_CLASS_PsPageBox 0x1600024L
struct rect { int x0, y0, x1, y1; };
struct tview { char p0[14]; struct rect r; char p22[12]; long f34; long f38; };
extern long ScreenProc(long obj, long evt, long par);
extern struct tview *GetViewInstance(long id);
extern long SendEvent(long, long, long);
extern void DrawTitleBar(struct rect *r, long a, int b, long c, unsigned int d);
extern long TtlScreenProc(long obj, long evt, long par);

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
