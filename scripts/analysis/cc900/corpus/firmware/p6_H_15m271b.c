/* Round 15 form b: as round 14 (run 2026-11-17-2: +20, only PARA_DRAW differs: the ROM re-reads the value pointer
   after storing the page through it), with that store and the SendEvent argument written through a pointer to the
   field, `pv = &t->value; **pv = p; ... **pv`, so the pointer is re-read through the held field address.
   lane_p6 helper H, round 14, module 271 (ui/ui_widget_defs.s), file d: PsPageBoxProc (new), on its own because the
   ROM reaches GetClientBox relatively here but absolutely from PsToggleBoxProc (forms a-c), so the two cannot share a
   module line.  The page box shows "PAGE n/m"; its instance holds +22 a word handed to DrawStringCentered and +28 a
   pointer to the page number.
   Cases in the reverse of the ROM's compare chain; MIN / MAX share `return 1`.  The parameter stays in XIZ; PARA_DRAW
   reads the page number into a second local before the GET_PAGE_MAX SendEvent (the ROM keeps it in IZ across that
   call, then pushes it under the result, cdecl right to left).  Frame: the instance pointer +4 (plain), then the
   address-taken locals in reverse declaration order: text buffer +8, centre +264, box +268.  DrawStringCentered's
   three register arguments are member / element addresses (the ROM computes them before its stack arguments). */
/* cc900-module: GetBoxCenter GetClientBox VwBoxProc */

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct pginst { unsigned char pad[22]; int w22; unsigned char pad2[4]; int *value; };
#define EVT_SHOW            0x1c00001L
#define EVT_PARA_DRAW       0x1c0000fL
#define EVT_PAGE_CHANGE     0x1c0001eL
#define EVT_CHECK_EDIT_SW   0x1e00053L
#define EVT_GET_PAGE_MIN    0x1e00054L
#define EVT_GET_PAGE_MAX    0x1e00055L
#define EVT_GET_PAGE_NOW    0x1e00056L
#define EVT_SET_PAGE        0x1e0007fL
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L

extern long VwBoxProc(long, long, long);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern void DrawStringCentered(struct rect *, struct pt *, char *, long, int, int);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
/* cc900-name: pg_fmt=PsPageBox_Confirm_DrawValue_Str_PAGE_Fmtd_Fmtd */
extern char pg_fmt[];

long PsPageBoxProc(long obj, long evt, long p)
{
    struct pginst *t;
    struct rect box;
    struct pt c;
    char buf[256];
    int cur;
    int **pv;

    switch (evt) {
    case EVT_SHOW:
        VwBoxProc(obj, evt, p);
        if (p == 4 || p == 3 || p == 5 || p == 0)
            SendEvent(-1L, EVT_PAGE_CHANGE, *((struct pginst *)GetViewInstance(obj))->value);
        return 0;
    case EVT_PARA_DRAW:
        t = GetViewInstance(obj);
        if (p != 0) {
            pv = &t->value;
            **pv = (int)p;
            SendEvent(-1L, EVT_PAGE_CHANGE, **pv);
        }
        cur = *t->value;
        Sprintf_Locked(buf, pg_fmt, cur, (int)SendEvent(obj, EVT_GET_PAGE_MAX, 0));
        GetClientBox(obj, &box);
        GetBoxCenter(&box, &c);
        DrawStringCentered((struct rect *)&box.x1, (struct pt *)&c.x, &buf[0], 0L, 0, t->w22);
        return 0;
    case EVT_CHECK_EDIT_SW:
        return (unsigned int)(SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p) == 0x10);
    case EVT_GET_PAGE_MIN:
    case EVT_GET_PAGE_MAX:
        return 1;
    case EVT_GET_PAGE_NOW:
        return *((struct pginst *)GetViewInstance(obj))->value;
    case EVT_SET_PAGE:
        *((struct pginst *)GetViewInstance(obj))->value = (int)p;
        return 0;
    default:
        return VwBoxProc(obj, evt, p);
    }
}
