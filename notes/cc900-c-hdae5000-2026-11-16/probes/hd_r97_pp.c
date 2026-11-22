/* hd_r97_pp.c (lane_hd round 97, 2026-11-21, UNRUN: written while the VM was blocked): HDAE5000_DbMemoClProc
   (hd-ae5000_v2_06i.s, 487 B), two forms.
   It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: DbMemo_t=HDAE5000_DbMemoClProc
   cc900-name: DbMemo_w=HDAE5000_DbMemoClProc
   The one difference left (twice): after storing the view pointer to v the ROM copies it from XHL to XWA and takes
   the member address in place (`ld xwa,xhl; lda xwa,(xwa+14)` / `ld xwa,xhl; lda xiy,(xwa+14)`).  Through u V4.23
   addresses off XHL, through v it reloads, and conversions, comma, `register v` change nothing (rounds 55-93).  New
   idea: the copy is an assignment to a SECOND, short-lived register local (w) whose only use is that member
   address: if V4.23 gives it XWA (no call inside its live range), `w = u` is `ld xwa,xhl` and `&w->box`, w then
   dead, is `lda xwa,(xwa+14)`:
     DbMemo_t  a block `{ struct DbView *w = u; DrawDesignBox(&w->box, ..); }` / `{ .. w = u; box = w->box; }`
     DbMemo_w  w declared at function scope (after u), assigned at each site
   Otherwise e's spelling (hd_r54_pp.c).  If one matches, SelectListProc's nine sites take the same change
   (selectlist/gen.py).
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

long DbMemo_t(long obj, long ev, long arg)
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
        {
            struct DbView *w = u;

            CALLV(ROOT->DrawDesignBox)(&w->box, 0xc5, v->a22);
        }
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
        {
            struct DbView *w = u;

            box = w->box;
        }
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

long DbMemo_w(long obj, long ev, long arg)
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
    struct DbView *w;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        u = GETVIEWP(obj);
        v = u;
        w = u;
        CALLV(ROOT->DrawDesignBox)(&w->box, 0xc5, v->a22);
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
        w = u;
        box = w->box;
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
