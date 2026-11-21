/* hd_r92_pp.c (lane_hd round 92, 2026-11-20): HDAE5000_DbMemoClProc (hd-ae5000_v2_06i.s, 487 B), two forms.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_q=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_r=HDAE5000_DbMemoClProc
   After each GetViewInstance call the ROM stores the view pointer to v (`ld (xsp+4),xhl`), then copies it from XHL
   to XWA and takes the member address there (`ld xwa,xhl; lda xwa,(xwa+14)`).  Seen: through the register local u
   V4.23 addresses off XHL directly (`lda xwa,(xhl+14)`: forms c, e, and round 91's converted l .. p); through v or
   an assignment operand it reloads v (`ld xwa,(xsp+4)`: f .. k).  The ROM's copy is the shape of a value V4.23
   computes into its work register first.  These make the first use a comma expression, whose value is such a
   computed value, with the store to v as its left operand:
     q  struct DbView *u;  &(v = u, u)->box;   box = (v = u, u)->box
     r  long u;            &(v = (struct DbView *)u, (struct DbView *)u)->box;   box = (likewise)->box
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
#define GETVIEWL(o) CALLR(long, ROOT->GetViewInstance)(o)

long DbMemo_q(long obj, long ev, long arg)
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
        CALLV(ROOT->DrawDesignBox)(&(v = u, u)->box, 0xc5, v->a22);
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
        box = (v = u, u)->box;
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

long DbMemo_r(long obj, long ev, long arg)
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
        CALLV(ROOT->DrawDesignBox)(&(v = (struct DbView *)u, (struct DbView *)u)->box, 0xc5, v->a22);
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
        box = (v = (struct DbView *)u, (struct DbView *)u)->box;
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
