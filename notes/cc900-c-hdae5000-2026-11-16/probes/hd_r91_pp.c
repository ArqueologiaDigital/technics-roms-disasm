/* hd_r91_pp.c (lane_hd round 91, 2026-11-20): HDAE5000_DbMemoClProc (hd-ae5000_v2_06i.s, 487 B), four forms.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_l=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_m=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_n=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_p=HDAE5000_DbMemoClProc
   Read-out of runs -18-16-hd-r54 .. -19-4-hd-r60 (forms c .. k): all give the ROM's code but one instruction after
   each GetViewInstance call: the ROM moves the view pointer, still in XHL, to XWA and takes the member address from
   there (`ld xwa,xhl; lda xwa,(xwa+14)` / `ld xwa,xhl; lda xiy,(xwa+14)`); the first use through u gives
   `lda xwa,(xhl+14)` (c, e), through v or an assignment a reload `ld xwa,(xsp+4)` (f .. k), the integer u + 14
   `add xhl,14; ld xwa,xhl` (d).  Elsewhere in this ROM a value that goes through WA / XWA before use is a
   CONVERTED one (README; CodeDigit, AcLanguageText1Proc).  So these convert u at its first use:
     l  struct DbView *u;  the argument converted after:  (long)&u->box;  box = *(struct Box *)(long)&u->box
     m  struct DbView *u;  u through long:  &((struct DbView *)(long)u)->box
     n  char *u;           a pointer conversion:  &((struct DbView *)u)->box
     p  unsigned long u;   &((struct DbView *)u)->box
   Everything else is e's spelling (hd_r54_pp.c).
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
#define GETVIEWC(o) CALLR(char *, ROOT->GetViewInstance)(o)
#define GETVIEWU(o) CALLR(unsigned long, ROOT->GetViewInstance)(o)

long DbMemo_l(long obj, long ev, long arg)
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
        CALLV(ROOT->DrawDesignBox)((long)&u->box, 0xc5, v->a22);
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
        box = *(struct Box *)(long)&u->box;
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

long DbMemo_m(long obj, long ev, long arg)
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
        CALLV(ROOT->DrawDesignBox)(&((struct DbView *)(long)u)->box, 0xc5, v->a22);
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
        box = ((struct DbView *)(long)u)->box;
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

long DbMemo_n(long obj, long ev, long arg)
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
    char *u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWC(obj);
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
        u = GETVIEWC(obj);
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
            CALLV(ROOT->DrawString)(&box.x1, &pt.x, (unsigned char *)buf, 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}

long DbMemo_p(long obj, long ev, long arg)
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
    unsigned long u;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWU(obj);
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
        u = GETVIEWU(obj);
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
            CALLV(ROOT->DrawString)(&box.x1, &pt.x, (unsigned char *)buf, 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}
