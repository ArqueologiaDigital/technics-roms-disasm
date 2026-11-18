/* FORM B of p6_I_1m271a.c: MainLswPartGet's id written idx + (part << 16).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 1, module 271 (ui/ui_widget_defs.s, an -O3 -Xr file), form a.  New.
   MainLswGet(id) and MainLswPartGet(part, idx): the Get members of the MainLswAdd / MainLswPut family (staged in
   v10/maincpu/cc900/ui_widget_defs_m271_b.c): a 12-byte request {id, 0, 0, 0} from Malloc sent to MainPmanControl
   as EVT_LSW_GET / EVT_LSW_PART_GET, then queued for EVT_AUTO_FREE, through FuncCall (not MainFuncCall: the ROM
   calls FuncCall at 0xfa4932).  Return 0.  The part form packs (part << 16) + idx as the id, both zero-extended.
   Form b: that sum written idx + (part << 16). */

#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_GET 0x1e00059L
#define EVT_LSW_PART_GET 0x1e0005cL

struct lswreq { long id; int a; int b; long z; };

extern void *__cdecl Malloc(unsigned int);
extern void FuncCall(long fn, long evt, void *par);
extern int MainLswGet(long id);
extern int MainLswPartGet(unsigned int part, unsigned int idx);

int MainLswGet(long id)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = id;
    p->a = 0;
    p->b = 0;
    p->z = 0;
    FuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_GET, p);
    FuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}

int MainLswPartGet(unsigned int part, unsigned int idx)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = idx + ((unsigned long)part << 16);
    p->a = 0;
    p->b = 0;
    p->z = 0;
    FuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PART_GET, p);
    FuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}
