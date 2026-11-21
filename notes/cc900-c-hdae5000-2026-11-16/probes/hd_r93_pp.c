/* hd_r93_pp.c (lane_hd round 93, 2026-11-21): HDAE5000_DbMemoClProc (487 B), one form.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_s=HDAE5000_DbMemoClProc
   The ROM stores the view pointer to v at (xsp+4) and then copies XHL to XWA (`ld xwa,xhl`) where every form so
   far reloads v (`ld xwa,(xsp+4)`) or addresses off XHL.  New idea: v declared `register` although it lives in the
   frame (V4.23 has no register left for it across the calls), which may make V4.23 treat v's value as still held
   in the register it was stored from.  Otherwise e's spelling (hd_r54_pp.c): u a register local in XHL, v = u, the
   first uses through v.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the memo box's view instance (RootFn_GetViewInstance): its frame at +14, two colour words at +22 / +24 */
struct DbView { char p0[14]; struct Box box; int a22; int a24; };

extern char HDAE5000_Str_DebugTime[];

#define GETVIEWP(o) CALLR(struct DbView *, ROOT->GetViewInstance)(o)

long DbMemo_s(long obj, long ev, long arg)
{
    struct Box box;
    struct Box box2;
    struct Box box3;
    struct Point pt;
    struct Point pt2;
    char buf[60];
    register struct DbView *v;
    unsigned int n;
    char *p;
    struct DbView *u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWP(obj);
        v = u;
        CALLV(ROOT->DrawDesignBox)(&v->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        u = GETVIEWP(obj);
        v = u;
        box = v->box;
        box.y1 += 5;
        box.x1 += 5;
        box.x2 -= 5;
        box.y2 -= 5;
        n = (box.x2 - box.x1) / 6;
        pt.x = box.x1;
        pt.y = box.y2 - 8;
        box2 = box;
        box2.y1 += 8;
        box3 = box;
        box3.y1 = box3.y2 - 8;
        pt2.x = box.x1;
        pt2.y = box.y1;
        p = (char *)arg;
        for (;;) {
            CALLV(ROOT->MovePixels)((long)&box2, (long)&pt2);
            CALLV(ROOT->DrawBox)(&box3, v->a22);
            HDAE5000_StrNCpy(buf, p, n);
            buf[n] = 0;
            CALLV(ROOT->DrawString)(&box.x1, &pt.x, (unsigned char *)buf, 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}
