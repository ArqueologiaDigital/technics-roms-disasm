/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDesignFrame DrawEditSw GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint LabelProc MainLswGet MainRamGet PsListBoxProc PsParaBoxProc SetAutoInc SetDialDown SetDialEnable SetDialUp VwBoxProc */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern char sw_n7f[], sw_n80[], sw_n81[];
extern char *__cdecl Strcpy(char *, char *);
extern void DrawEditSw(unsigned int sw);
#define EVT_DRAW              0x1c0000dL
struct vinst { unsigned char pad[14]; struct rect r; char *str; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern long LabelProc(long obj, long evt, long p);

/* cc900-name: sw_n7f=DrawEditSw_Str_N7f */
/* cc900-name: sw_n80=DrawEditSw_SelectVariantA_Str_N80 */
/* cc900-name: sw_n81=DrawEditSw_SelectVariantC_Str_N81 */
void DrawEditSw(unsigned int sw)
{
	struct rect r;
	struct pt pt;
	char s[6];
	int w, hg;

	if (sw != 0xff && sw != 0xf) {
		GetEditSwPoint(sw, &pt);
		if (pt.y != 0xef) {
			if (pt.x == 0) Strcpy(s, sw_n7f);
			else Strcpy(s, sw_n80);
		} else
			Strcpy(s, sw_n81);
		w = CalcTotalWidth(s, 0);
		hg = GetCharHeight(0);
		if (pt.x == 0) {
			r.x1 = -2;
			r.y1 = pt.y - hg / 2;
		}
		if (pt.x == 0x13f) {
			r.x1 = 0x13e - w;
			r.y1 = pt.y - hg / 2;
		}
		if (pt.y == 0xef) {
			r.x1 = pt.x - w / 2 - 1;
			r.y1 = 0xf5 - hg;
		}
		pt.x = r.x1 + 2;
		pt.y = r.y1 + 1;
		r.x2 = w + r.x1 + 1;
		r.y2 = hg + r.y1;
		DrawString(&r, &pt, &s[0], 0, 0xf4, 0xf7);
	}
}

long LabelProc(long obj, long evt, long p)
{
	struct pt pt;
	struct rect r;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	r = h->r;
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 1;
	DrawString((struct rect *)&r.x1, &pt, h->str, h->l26, h->i30, 0xf7);
	return 0;
}
