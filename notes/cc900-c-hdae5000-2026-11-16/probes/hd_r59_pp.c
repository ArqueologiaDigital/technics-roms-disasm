/* hd_r59_pp.c (lane_hd round 59): HDAE5000_DbMemoClProc (hd-ae5000_v2_06i.s, 487 B), three forms.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_i=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_j=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_k=HDAE5000_DbMemoClProc
   Read-out of run 2026-11-18-24-hd-r56 (hd_r55_pp.c): forms f, g and h all give the ROM's code but for one
   instruction after each GetViewInstance call: the ROM copies the call's result, still in XHL, to XWA (`ld xwa,xhl`)
   right after storing it to v at (xsp+4); V4.23 reloads v from the stack.  f and g nested only `v = u` in the first
   use.  V4.23 takes the value of an assignment used as an operand again from the right-hand register (Lyrics_FindEvent),
   so these nest the CALL itself in the first use, with no register local u:
     i  &(v = GETVIEWP(obj))->box / box = (v = GETVIEWP(obj))->box
     j  the same through the long call, converted: (v = (struct DbView *)GETVIEWL(obj))
     k  a register local u assigned inside: (v = (u = GETVIEWP(obj)))
   Everything else is h's spelling.
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

long DbMemo_i(long obj, long ev, long arg)
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

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        CALLV(ROOT->DrawDesignBox)(&(v = GETVIEWP(obj))->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        box = (v = GETVIEWP(obj))->box;
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

long DbMemo_j(long obj, long ev, long arg)
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

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        CALLV(ROOT->DrawDesignBox)(&(v = (struct DbView *)GETVIEWL(obj))->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        box = (v = (struct DbView *)GETVIEWL(obj))->box;
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

long DbMemo_k(long obj, long ev, long arg)
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
        CALLV(ROOT->DrawDesignBox)(&(v = (u = GETVIEWP(obj)))->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        box = (v = (u = GETVIEWP(obj)))->box;
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
