/* lane_hd round 52, helper h_pp, form a: HDAE5000_DbMemoClProc (hd-ae5000_v2_06i.s, 0x28122a, 487 bytes), the
   class procedure of the debug memo box ("DbMemoClProc" in HDAE5000_ClassProc_Table).  Options: -Xr.  It is alone in
   its file: it makes no relative call (StrNCpy / StrLen are library `call`s).
   The PC-link (PPORT) command handlers and helpers of hdae5000_ui_display.s that round 52 also listed are all hand
   assembly (a nop after every odd-length instruction, `ei 0` / `ei 7` around CallService, arguments in BC / HL / W /
   XIY, handlers ending in `jp` to CommandLoop_Poll, XSP swaps): none is written here.
   Reading of the hand source:
   - frame 106 bytes + pushed XIZ; obj lives in XIZ, ev stays in XBC (only the switch and the default read it), arg
     is stored at the top (xsp+106).  Locals by falling address, first declared highest: box 98, box2 90, box3 82,
     pt 78, pt2 74, buf[60] 14, p 10, n 8, v 4;
   - `ld (xsp+4),xhl; ld xwa,xhl; lda xwa,(xwa+14)`: the stored view pointer used again from HL, the shape of an
     assignment used as an operand (Lyrics_FindEvent's `pos += (n = ..)`): written as a nested assignment;
   - switch: MEMO_DRAW compared first, then DRAW, no inverted compare, the default body first: `default:` first in
     source, then EVT_DRAW, then EVT_MEMO_DRAW;
   - the box shrink order (y1, x1, x2, y2) is the ROM's `incw / decm` order;
   - (x2 - x1) / 6 is `exts xwa; divs wa,6` (int), n is extz'd when added to p and when indexing buf, and loaded
     before its push to StrNCpy's int parameter (`ld wa,(n); pushw wa`): n is unsigned int;
   - casts where the ROM evaluates an argument into a temporary first: MovePixels' two box / point addresses, the
     DrawString text buffer, SendEvent's string; DrawBox's and DrawString's box / point addresses go straight into
     their registers (no cast);
   - DrawString's three stacked arguments are pushed left to right (3L, then the view's words at +24 and +22, as
     FDFileSelectProc's 3L, 0xff, 0xf5). */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the memo box's view instance (RootFn_GetViewInstance): its frame at +14, two colour words at +22 / +24 */
struct DbView { char p0[14]; struct Box box; int a22; int a24; };

extern char HDAE5000_Str_DebugTime[];

long HDAE5000_DbMemoClProc(long obj, long ev, long arg)
{
    struct Box box;
    struct Box box2;
    struct Box box3;
    struct Point pt;
    struct Point pt2;
    char buf[60];
    char *p;
    unsigned int n;
    struct DbView *v;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        CALLV(ROOT->DrawDesignBox)(&(v = CALLR(struct DbView *, ROOT->GetViewInstance)(obj))->box, 0xc5, v->a22);
        box = v->box;
        box.y1 += 4;
        box.x1 += 4;
        box.x2 -= 4;
        box.y2 -= 4;
        CALLV(ROOT->DrawDesignBox)(&box, 0xc6, v->a22);
        CALLV(ROOT->SendEvent)(obj, EVT_MEMO_DRAW, (long)HDAE5000_Str_DebugTime);
        return 0;
    case EVT_MEMO_DRAW:
        box = (v = CALLR(struct DbView *, ROOT->GetViewInstance)(obj))->box;
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
            CALLV(ROOT->DrawString)(&box, &pt, (long)buf, 3L, v->a24, v->a22);
            if (HDAE5000_StrLen(buf) != n)
                break;
            p += n;
        }
        return 0;
    }
}
