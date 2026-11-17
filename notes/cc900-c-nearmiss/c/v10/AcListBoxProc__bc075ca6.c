/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_6m271a.c (2026-11-16-100-p6-r19)
   sha256 bc075ca6d6c0cf917b1bf121bd79d23bbeae99784e1a636de07748b880b717f1 (tar-sha256); compiled at -O3 -XS -Xr */
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
