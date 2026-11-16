/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_G_2m271.c (2026-11-16-68-p6-r12)
   sha256 1ba4d5a45f7e687d8f2e19e617f20853521caadbb38622446736edc915561169 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper G, round 2, module 271 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): EditSwProc
   (ui/ui_window_procs.s), which reaches LabelProc with calr, so both are in this one file.  LabelProc is the
   p6_G_2a.c form.  Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */

#define EVT_SW_IN             0x1c00007L
#define EVT_DRAW              0x1c0000dL
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
/* an edit switch's instance: id at +32, its ApFunction at +34, the dial step at +38 (-1: none) */
struct esinst { unsigned char pad[32]; unsigned int id; long func; int dial; };

extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);

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
	DrawString(&r, &pt, (char *)h->l22, h->l26, h->i30, 0xf7);
	return 0;
}

long EditSwProc(long obj, long evt, long p)
{
	struct esinst *h;

	if (evt != EVT_SW_IN) return LabelProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->id != SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p)) return LabelProc(obj, evt, p);
	ApFuncCall(h->func, evt, p);
	if (h->dial != -1) {
		if (p & 0x80) SendEvent(-1L, EVT_INDEXSW_DOWN, (long)h->dial);
		else SendEvent(-1L, EVT_INDEXSW_UP, (long)h->dial);
	}
	return 0;
}
