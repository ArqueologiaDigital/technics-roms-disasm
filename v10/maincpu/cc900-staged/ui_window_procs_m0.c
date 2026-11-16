/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawEditSw GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint MainLswGet MainRamGet PsListBoxProc PsParaBoxProc SetAutoInc SetDialDown SetDialEnable SetDialUp VwBoxProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SHOW              0x1c00001L
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_INDEXSW_UP_AIC    0x1c00019L
#define EVT_INDEXSW_DOWN_AIC  0x1c0001aL
#define EVT_GET_STRING        0x1e0003aL
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_CHECK_INDEX       0x1e00050L
#define EVT_GET_SELECTED      0x1e00090L
struct lbinst { unsigned char pad[26]; int index; unsigned char pad2[14]; char *str; int dials; };
extern long PsListBoxProc(long, long, long);
extern void SetDialUp(long, long, long);
extern void SetDialDown(long, long, long);
extern void SetAutoInc(long, long, long);
extern void SetDialEnable(unsigned int);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern long AcListBoxProc(long obj, long evt, long p);

long AcListBoxProc(long obj, long evt, long p)
{
	struct lbinst *h;

	switch (evt) {
	case EVT_SHOW:
		PsListBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, (long)h->index);
		SetDialDown(obj, EVT_INDEXSW_UP, (long)h->index);
		SetDialEnable(1);
		return 0;
	case EVT_INDEXSW_UP_AIC:
	case EVT_INDEXSW_UP:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) return 0;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) - 1));
		SetAutoInc(obj, EVT_INDEXSW_UP_AIC, p);
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, p);
		SetDialDown(obj, EVT_INDEXSW_UP, p);
		SetDialEnable(1);
		return 0;
	case EVT_INDEXSW_DOWN_AIC:
	case EVT_INDEXSW_DOWN:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) return 0;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) + 1));
		SetAutoInc(obj, EVT_INDEXSW_DOWN_AIC, p);
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, p);
		SetDialDown(obj, EVT_INDEXSW_UP, p);
		SetDialEnable(1);
		return 0;
	case EVT_GET_STRING:
		Strcpy((char *)p, ((struct lbinst *)GetViewInstance(obj))->str);
		return 0;
	default:
		return PsListBoxProc(obj, evt, p);
	}
}
