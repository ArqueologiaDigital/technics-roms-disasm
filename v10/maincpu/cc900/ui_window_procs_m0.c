/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDesignFrame DrawEditSw GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint LabelProc VwBoxProc */   /* staged module names, repair_module_lines.py */

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

#define EVT_SW_IN             0x1c00007L
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
struct esinst { unsigned char pad[32]; unsigned int id; long func; int dial; };
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern long LabelProc(long obj, long evt, long p);
extern long EditSwProc(long obj, long evt, long p);
struct frinst { unsigned char pad[14]; struct rect r; int i22, i24, i26; };
extern void DrawDesignFrame(struct rect *, int, int, int);
extern int GetVisible(long);
extern long FrameProc(long obj, long evt, long p);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
extern long IconProc(long obj, long evt, long p);
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };
extern void DrawLine(struct pt *, struct pt *, int);
extern long LineProc(long obj, long evt, long p);
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern unsigned char *FDemo_LinkedListLookupField(char *);
extern void DrawBitmapFile(struct pt *, unsigned char *);
extern void ChangePalette(int);
extern char VwUserBitmapByName_Str_BmpExt[];
extern long VwUserBitmapByNameProc(long obj, long evt, long p);

long EditSwProc(long obj, long evt, long p)
{
	struct esinst *h;

	if (evt != EVT_SW_IN) return LabelProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->id == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p)) {
		ApFuncCall(h->func, evt, p);
		if (h->dial != -1) {
			if (p & 0x80) SendEvent(-1L, EVT_INDEXSW_DOWN, (long)h->dial);
			else SendEvent(-1L, EVT_INDEXSW_UP, (long)h->dial);
		}
		return 0;
	}
	return LabelProc(obj, evt, p);
}
long FrameProc(long obj, long evt, long p)
{
	struct frinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	if (GetVisible(obj) == 0) return 1;
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	DrawDesignFrame(&h->r, h->i22, h->i24, h->i26);
	return 0;
}
long IconProc(long obj, long evt, long p)
{
	struct rect r;
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 2;
	r.x1 = pt.x - 2;
	r.x2 = pt.x + 25;
	r.y1 = pt.y - 2;
	r.y2 = pt.y + 25;
	DrawDesignBox(&r, 0xc4, 0xf0);
	DrawIcons(&pt, h->l22);
	return 0;
}
long LineProc(long obj, long evt, long p)
{
	struct pt a, b;
	struct lineinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->dir == 1) {
		a.x = h->x1;
		a.y = h->y1;
		b.x = h->x2;
		b.y = h->y2;
	} else {
		a.x = h->x1;
		a.y = h->y2;
		b.x = h->x2;
		b.y = h->y1;
	}
	DrawLine(&a, &b, h->color);
	return 0;
}
long VwUserBitmapByNameProc(long obj, long evt, long p)
{
	struct pt pt;
	char name[16];
	struct vinst *h;
	unsigned char *f;

	switch (evt) {
	case EVT_SHOW:
		ViewableProc(obj, evt, p);
		return 0;
	case EVT_DRAW:
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		pt.x = h->r.x1;
		pt.y = h->r.y1;
		Strcpy(name, (char *)h->l22);
		Strcat(name, VwUserBitmapByName_Str_BmpExt);
		f = FDemo_LinkedListLookupField(name);
		if (f != 0) DrawBitmapFile(&pt, f);
		else DrawBitmap(&pt, 0);
		return 0;
	case EVT_HIDE:
		ChangePalette(2);
		ViewableProc(obj, evt, p);
		return 0;
	}
	return ViewableProc(obj, evt, p);
}

/* cc900-module: MainLswGet MainRamGet PsListBoxProc PsParaBoxProc SetAutoInc SetDialDown SetDialEnable SetDialUp SndParamBank_WriteFlashDefaults */
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern void DrawBitmapSPFast(struct pt *, unsigned char *, int, int);
extern long VwUserBitmapProc(long obj, long evt, long p);
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEXSW_UP_AIC    0x1c00019L
#define EVT_INDEXSW_DOWN_AIC  0x1c0001aL
#define EVT_LSW_DATA          0x1c0001cL
#define EVT_GET_STRING        0x1e0003aL
#define EVT_CALC_PARAM        0x1e0003dL
#define EVT_GET_LARGE_STEP    0x1e0003eL
#define EVT_GET_SMALL_STEP    0x1e0003fL
#define EVT_GET_LSW_ADDRESS   0x1e00040L
#define EVT_GET_LSW_STRING    0x1e00042L
#define EVT_LSW_DATA_REQ      0x1e00083L
struct pbinst { unsigned char pad[36]; long func; void *value; };
struct lswreq { long addr; int val; int pad; long str; };
extern long PsParaBoxProc(long, long, long);
extern int MainLswGet(long);
extern long AcLswBoxProc(long obj, long evt, long p);
extern long PsParaBoxProc(long obj, long evt, long p);
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_CHECK_INDEX       0x1e00050L
#define EVT_GET_SELECTED      0x1e00090L
struct lbinst { unsigned char pad[26]; int index; unsigned char pad2[14]; char *str; int dials; };
extern long PsListBoxProc(long, long, long);
extern void SetDialUp(long, long, long);
extern void SetDialDown(long, long, long);
extern void SetAutoInc(long, long, long);
extern void SetDialEnable(unsigned int);
extern long AcListBoxProc(long obj, long evt, long p);

long VwUserBitmapProc(long obj, long evt, long p)
{
	int w;
	unsigned char *data;
	struct pt pt;
	struct vinst *h;
	int hg;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		hg = ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0);
		DrawBitmapSPFast((struct pt *)&pt.x, data, w, hg);
	} else
		DrawBitmap(&pt, 0);
	return 0;
}
long AcLswBoxProc(long obj, long evt, long p)
{
	struct lswreq req;
	struct pbinst *h;
	int **pv;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0);
		req.val = *(int *)h->value;
		req.str = p;
		ApFuncCall(h->func, EVT_GET_LSW_STRING, (long)&req);
		return 0;
	case EVT_SHOW:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_HIDE:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		MainLswGet(ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0));
		return 0;
	case EVT_LSW_DATA:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (((struct lswreq *)p)->addr == ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0)) {
			pv = (int **)&h->value;
			**pv = ((struct lswreq *)p)->val;
			ApFuncCall(h->func, EVT_LSW_DATA_REQ, (long)**pv);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		}
		return 0;
	case EVT_INDEXSW_UP_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		return 0;
	case EVT_INDEXSW_UP:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		return 0;
	case EVT_INDEXSW_DOWN_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		return 0;
	case EVT_INDEXSW_DOWN:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		return 0;
	default:
		return PsParaBoxProc(obj, evt, p);
	}
}
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
