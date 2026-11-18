/* hd_r54_pp.c (lane_hd round 54, helper h_pp): HDAE5000_DbMemoClProc (hd-ae5000_v2_06i.s, 487 B), three forms.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_c=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_d=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_e=HDAE5000_DbMemoClProc
   Read-out of run 2026-11-18-13-hd-r52 (hd_r52_pp1.c / pp1b.c, the nested and the plain assignment of v compile the
   same; best +18).  Everything else matched; three differences:
   1. scalar locals: V4.23 put them in RISING declaration order (p 4, n 8, v 10); the ROM has v 4, n 8, p 10.  All
      forms declare v, n, p;
   2. both GetViewInstance calls: V4.23 loads the function pointer into XHL and re-reads v from the stack; the ROM
      loads it into XIX, stores HL to v and copies HL to XWA (`ld xwa,xhl`).  SelectListProc's idiom: a register
      local u (long, declared last) takes the result, `u = GETVIEWL(obj); v = (struct DbView *)u;`, and the
      first use goes through u:
        c, e  the first use as a pointer cast, ((struct DbView *)u)->box
        d     the first use as an integer address, *(struct Box *)(u + 14) (SelList_p's V_xxx(u) spelling)
      e declares u as a struct DbView * instead of a long;
   3. DrawString: V4.23 left &box / &pt for after the stacked arguments (lda xwa / lda xbc, like constants) and put
      (long)buf straight into XDE; the ROM evaluates all three first: &box straight into XHL, &pt straight into
      XBC, buf through XWA into XDE (a converted argument, like MovePixels' (long)&box2, which matched):
        c  &box.x1, &pt.x,           (long)&buf
        d  (void *)&box, (void *)&pt, (long)&buf[0]
        e  &box.x1, &pt.x,           (unsigned char *)buf
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

#define GETVIEWL(o) CALLR(long, ROOT->GetViewInstance)(o)
#define GETVIEWP(o) CALLR(struct DbView *, ROOT->GetViewInstance)(o)

long DbMemo_c(long obj, long ev, long arg)
{
    struct Box box;
    struct Box box2;
    struct Box box3;
    struct Point pt;
    struct Point pt2;
    char buf[60];
    struct DbView *v;
    unsigned int n;
    char *p;
    long u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWL(obj);
        v = (struct DbView *)u;
        CALLV(ROOT->DrawDesignBox)(&((struct DbView *)u)->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        u = GETVIEWL(obj);
        v = (struct DbView *)u;
        box = ((struct DbView *)u)->box;
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
            CALLV(ROOT->DrawString)(&box.x1, &pt.x, (long)&buf, 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}

long DbMemo_d(long obj, long ev, long arg)
{
    struct Box box;
    struct Box box2;
    struct Box box3;
    struct Point pt;
    struct Point pt2;
    char buf[60];
    struct DbView *v;
    unsigned int n;
    char *p;
    long u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWL(obj);
        v = (struct DbView *)u;
        CALLV(ROOT->DrawDesignBox)((struct Box *)(u + 14), 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        u = GETVIEWL(obj);
        v = (struct DbView *)u;
        box = *(struct Box *)(u + 14);
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
            CALLV(ROOT->DrawString)((void *)&box, (void *)&pt, (long)&buf[0], 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}

long DbMemo_e(long obj, long ev, long arg)
{
    struct Box box;
    struct Box box2;
    struct Box box3;
    struct Point pt;
    struct Point pt2;
    char buf[60];
    struct DbView *v;
    unsigned int n;
    char *p;
    struct DbView *u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWP(obj);
        v = u;
        CALLV(ROOT->DrawDesignBox)(&u->box, 0xc5, v->a22);
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
        box = u->box;
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
