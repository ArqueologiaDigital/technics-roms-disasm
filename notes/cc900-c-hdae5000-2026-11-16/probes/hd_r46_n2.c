/* hd_r46_n2.c (lane_hd round 46, helper h_n2): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), the class
   procedure of the select lists, and four variants.  It calls nothing relatively.  From hd_r39_m5a.c, whose three
   forms were compiled in run 2026-11-17-15-hd-r44.
   cc900-options: -Xr
   cc900-name: SelList_d=HDAE5000_SelectListProc
   cc900-name: SelList_e=HDAE5000_SelectListProc
   cc900-name: SelList_f=HDAE5000_SelectListProc
   cc900-name: SelList_g=HDAE5000_SelectListProc

   The "difference at +23" of the index is not one: it is the first `jrl z` of the event compares, whose distance
   `--show` leaves unresolved.  The frame (104 bytes) and every stack offset are the ROM's in all three forms.

   Read-out of run 15 (forms of hd_r39_m5a.c: label, b = SelList_b, c = SelList_c), item numbers as in that file:

   | #  | item                              | state     | spelling that gives the ROM's code (run 15)                    |
   |----|-----------------------------------|-----------|----------------------------------------------------------------|
   | 1  | frame layout                      | settled   | scalars declared v, i, j, cw, ch, str, k after the aggregates  |
   | 2  | k as index register               | settled   | `int k`                                                        |
   | 3  | registers of a / column / t / n   | UNSETTLED | none: see below                                                |
   | 4  | view pointer copied to XWA        | UNSETTLED | none: see below                                                |
   | 5  | PAINT / cell coordinates          | settled   | a local: `t = ..; p1.x = t; p2.x = t;` and `box.y0 = t; ..`    |
   | 6  | `cw * column`                     | settled   | the column in an `unsigned int` (b's `col`): cw loaded first   |
   | 7  | `arg == i`                        | settled   | `(unsigned long)arg == i` (label; b's spelling gives the same) |
   | 8  | rows * cols operand order         | settled   | `V_ROWS * V_COLS` in the loop test, the reverse in CHANGE      |
   | 9  | DrawString addresses loaded first | settled   | `&box.x0, &p1.x, &buf[0]` (label), all three calls             |
   | 10 | CHANGE_SEL_NUM add and test       | settled   | `n = *sel; n += (int)arg; if (n < 0)` (label)                  |

   Notes on the settled ones.  5: c's `p2.x = p1.x = ..` also gives PAINT's two stores from BC, but its
   `box.y1 = (box.y0 = ..) + ch - 1` adds into BC where the ROM copies BC to WA; b's local gives both.  6: an int
   column, as `cw * n` and as `n * cw`, loads the column first and multiplies by cw in memory.  7: c's `i == arg`
   compares XWA with arg in memory.  9: b's three spellings (comma expressions, a prototyped call, same-type casts)
   all load the addresses after the pushes; c's (void *) and (long) casts give the ROM's code at the 2nd and 3rd
   call, its `&box.x0, &p1.x, buf` does not.  10: b's `(n = *sel + (int)arg) < 0` copies n and compares with 0; c's
   `n = *sel + (int)arg;` loads arg first and adds the cell from memory.

   3, unsettled.  ROM: row (a) in HL, column in DE, t in BC, n of CHANGE / SET_SEL_NUM in DE, d in WA.
     label (t, n, a, d, u declared; n is also the column; u in XHL): a DE, n BC, t DE with a copy `ld de,bc`.
       Run 113 declared u, a, n, t, d and got the same, so declaration order alone did not move these.
     b (t, col, a, n, d; no u): t BC, col HL, a DE, n DE: right but for a and col exchanged.
     c (n, a, d; no t, no u; n is also the column): a HL, n DE: right, but it has no t and the int column.
     A local that receives the view pointer (u, in XHL) seems to keep HL from the others.
   4, unsettled.  ROM: `ld xix,(GetViewInstance); call (xix); ld (xsp+4),xhl; ld xwa,xhl; ld xwa,(xwa+N)`, and
     in the INDEXSW case, where the pointer is not used at once, no `ld xwa,xhl`.
     label (`u = GETVIEW; v = u;` then `*V_SHOWN((char *)u)`): XIX and the store are right, but the access is
       `ld xwa,(xhl+N)`: a pointer-to-pointer cast is no conversion.
     b, c (`V_X(v = GETVIEW(obj))`, with and without a cast): the function pointer in XHL and v reloaded from the
       stack.  So the ROM has a register local in XHL and a real conversion on its use.

   The five forms here hold the settled spellings and differ only in items 3 and 4:
     label      4: `long u; v = (unsigned char *)u;`, used as `(unsigned char *)u`.   3: declared t, col, a, n, d, u.
     SelList_d  4: `long u; long v; v = u;`, both cast at every use.
                3: c's allocation plus t: declared n, a, t; the column is n, spelled `cw * (unsigned int)n`; PAINT
                   without t (`p2.x = p1.x = ..`), so that the locals first appear in the order a, n, t.
     SelList_e  4: `void *u; v = u;`, used as `(unsigned char *)u`.
                3: a, col, t declared in the block of the cell (and t in PAINT's loop block); n, d, u outside.
     SelList_f  4: as the label, but u declared in a block of each case (does it still keep HL?).
                3: declared t, a, col, n, d (a and col exchanged against b).
     SelList_g  4: `unsigned char *u; v = u;`, used as `(unsigned char *)(unsigned long)u`.   3: as the label.
   Reading them: item 4 shows right after each GetViewInstance call (9 places); item 3 in the cell arithmetic of
   PARA_DRAW (after the two `div`) and in CHANGE / SET_SEL_NUM.  label against g isolates item 4.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct Point { int x; int y; };
struct Rect { int x0; int y0; int x1; int y1; };

/* the view instance's fields, by offset (longs sit at odd word offsets, so no struct) */
#define V_COLOR(p)   (*(int *)((p) + 22))
#define V_FONT(p)    (*(long *)((p) + 28))
#define V_FG(p)      (*(int *)((p) + 32))
#define V_OWNER(p)   (*(long *)((p) + 34))
#define V_STRP(p)    (*(char ***)((p) + 38))
#define V_COLS(p)    (*(int *)((p) + 42))
#define V_ROWS(p)    (*(int *)((p) + 44))
#define V_SEL(p)     (*(int **)((p) + 46))
#define V_DIAL(p)    (*(int *)((p) + 50))
#define V_AUTOINC(p) (*(int *)((p) + 52))
#define V_SHOWN(p)   (*(int **)((p) + 54))
#define V_STYLE(p)   (*(int *)((p) + 58))

#define GETVIEW(o) CALLR(unsigned char *, ROOT->GetViewInstance)(o)
#define GETVIEWL(o) CALLR(long, ROOT->GetViewInstance)(o)
#define GETVIEWV(o) CALLR(void *, ROOT->GetViewInstance)(o)

extern char *HDAE5000_TextPtrs_01Selectlist0203040506070809[];

long HDAE5000_SelectListProc(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    unsigned char *v;
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
    int t;
    unsigned int col;
    unsigned int a;
    int n;
    int d;
    long u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_SHOWN((unsigned char *)u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_SHOWN((unsigned char *)u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (V_COLS((unsigned char *)u) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS(v);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS(v)) {
                t = client.x0 + cw * i - 1;
                p1.x = t;
                p2.x = t;
                if (V_COLOR(v) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (*V_STRP((unsigned char *)u) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP(v);
        if (*V_SHOWN(v) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS(v);
        ch = (client.y1 - client.y0) / V_ROWS(v);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS(v) * V_COLS(v)) {
            buf[0] = 0;
            while (str[j] != 0) {
                if (str[j] == 9) {
                    buf[k] = 0;
                    j++;
                    k = 0;
                    break;
                }
                buf[k] = str[j];
                k++;
                j++;
            }
            if (arg == -1L || (unsigned long)arg == i) {
                a = i % V_ROWS(v);
                col = i / V_ROWS(v);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * col + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT(v))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT(v))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT(v))) / 2;
                if (*V_SEL(v) == i) {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT(v), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    }
                }
            }
            i++;
        }
        return 0;

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        n = *V_SEL((unsigned char *)u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        n = *V_SEL((unsigned char *)u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((unsigned char *)u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_STRP((unsigned char *)u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC(v) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL(v) != 0) {
                    CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, idx);
                    CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, idx);
                    CALLV(ROOT->SetDialEnable)(1);
                }
                return 0;
            default:
                d = 1;
                goto step;
            }
        }
        if (idx + 1 == arg) {
            d = V_ROWS(v);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS(v);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_SAVE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK2, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_ALL, (long)*V_SEL(v));
            return 0;
        }
        return 0;

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_d(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    long v;
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
    int n;
    unsigned int a;
    int t;
    int d;
    long u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = u;
        *V_SHOWN((unsigned char *)u) = 1;
        if (V_DIAL((unsigned char *)v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = u;
        *V_SHOWN((unsigned char *)u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = u;
        if (V_COLS((unsigned char *)u) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS((unsigned char *)v);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS((unsigned char *)v)) {
                p2.x = p1.x = client.x0 + cw * i - 1;
                if (V_COLOR((unsigned char *)v) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        u = GETVIEWL(obj);
        v = u;
        if (*V_STRP((unsigned char *)u) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP((unsigned char *)v);
        if (*V_SHOWN((unsigned char *)v) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS((unsigned char *)v);
        ch = (client.y1 - client.y0) / V_ROWS((unsigned char *)v);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS((unsigned char *)v) * V_COLS((unsigned char *)v)) {
            buf[0] = 0;
            while (str[j] != 0) {
                if (str[j] == 9) {
                    buf[k] = 0;
                    j++;
                    k = 0;
                    break;
                }
                buf[k] = str[j];
                k++;
                j++;
            }
            if (arg == -1L || (unsigned long)arg == i) {
                a = i % V_ROWS((unsigned char *)v);
                n = i / V_ROWS((unsigned char *)v);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * (unsigned int)n + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT((unsigned char *)v))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT((unsigned char *)v))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT((unsigned char *)v))) / 2;
                if (*V_SEL((unsigned char *)v) == i) {
                    if (V_STYLE((unsigned char *)v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT((unsigned char *)v), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR((unsigned char *)v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT((unsigned char *)v), V_FG((unsigned char *)v), V_COLOR((unsigned char *)v));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE((unsigned char *)v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR((unsigned char *)v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT((unsigned char *)v), V_FG((unsigned char *)v), V_COLOR((unsigned char *)v));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR((unsigned char *)v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT((unsigned char *)v), V_FG((unsigned char *)v), V_COLOR((unsigned char *)v));
                    }
                }
            }
            i++;
        }
        return 0;

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        u = GETVIEWL(obj);
        v = u;
        n = *V_SEL((unsigned char *)u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS((unsigned char *)v) * V_ROWS((unsigned char *)v))
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        u = GETVIEWL(obj);
        v = u;
        n = *V_SEL((unsigned char *)u);
        *V_SEL((unsigned char *)v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL((unsigned char *)v));
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL((unsigned char *)v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEWL(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((unsigned char *)u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEWL(obj);
        v = u;
        *V_STRP((unsigned char *)u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        u = GETVIEWL(obj);
        v = u;
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC((unsigned char *)v) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL((unsigned char *)v) != 0) {
                    CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, idx);
                    CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, idx);
                    CALLV(ROOT->SetDialEnable)(1);
                }
                return 0;
            default:
                d = 1;
                goto step;
            }
        }
        if (idx + 1 == arg) {
            d = V_ROWS((unsigned char *)v);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS((unsigned char *)v);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_OK, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_SAVE, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_OK2, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_DEL, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)v), EVT_HDAE_SELECT_ALL, (long)*V_SEL((unsigned char *)v));
            return 0;
        }
        return 0;

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        u = GETVIEWL(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_e(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    unsigned char *v;
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
    int n;
    int d;
    void *u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWV(obj);
        v = u;
        *V_SHOWN((unsigned char *)u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWV(obj);
        v = u;
        *V_SHOWN((unsigned char *)u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWV(obj);
        v = u;
        if (V_COLS((unsigned char *)u) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS(v);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS(v)) {
                int t;

                t = client.x0 + cw * i - 1;
                p1.x = t;
                p2.x = t;
                if (V_COLOR(v) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        u = GETVIEWV(obj);
        v = u;
        if (*V_STRP((unsigned char *)u) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP(v);
        if (*V_SHOWN(v) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS(v);
        ch = (client.y1 - client.y0) / V_ROWS(v);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS(v) * V_COLS(v)) {
            buf[0] = 0;
            while (str[j] != 0) {
                if (str[j] == 9) {
                    buf[k] = 0;
                    j++;
                    k = 0;
                    break;
                }
                buf[k] = str[j];
                k++;
                j++;
            }
            if (arg == -1L || (unsigned long)arg == i) {
                unsigned int a;
                unsigned int col;
                int t;

                a = i % V_ROWS(v);
                col = i / V_ROWS(v);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * col + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT(v))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT(v))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT(v))) / 2;
                if (*V_SEL(v) == i) {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT(v), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    }
                }
            }
            i++;
        }
        return 0;

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        u = GETVIEWV(obj);
        v = u;
        n = *V_SEL((unsigned char *)u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        u = GETVIEWV(obj);
        v = u;
        n = *V_SEL((unsigned char *)u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEWV(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((unsigned char *)u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEWV(obj);
        v = u;
        *V_STRP((unsigned char *)u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        u = GETVIEWV(obj);
        v = u;
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC(v) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL(v) != 0) {
                    CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, idx);
                    CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, idx);
                    CALLV(ROOT->SetDialEnable)(1);
                }
                return 0;
            default:
                d = 1;
                goto step;
            }
        }
        if (idx + 1 == arg) {
            d = V_ROWS(v);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS(v);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_SAVE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK2, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_ALL, (long)*V_SEL(v));
            return 0;
        }
        return 0;

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        u = GETVIEWV(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_f(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    unsigned char *v;
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
    int t;
    unsigned int a;
    unsigned int col;
    int n;
    int d;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_SHOWN((unsigned char *)u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;
        }

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_SHOWN((unsigned char *)u) = 0;
        return 0;
        }

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (V_COLS((unsigned char *)u) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS(v);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS(v)) {
                t = client.x0 + cw * i - 1;
                p1.x = t;
                p2.x = t;
                if (V_COLOR(v) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;
        }

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (*V_STRP((unsigned char *)u) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP(v);
        if (*V_SHOWN(v) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS(v);
        ch = (client.y1 - client.y0) / V_ROWS(v);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS(v) * V_COLS(v)) {
            buf[0] = 0;
            while (str[j] != 0) {
                if (str[j] == 9) {
                    buf[k] = 0;
                    j++;
                    k = 0;
                    break;
                }
                buf[k] = str[j];
                k++;
                j++;
            }
            if (arg == -1L || (unsigned long)arg == i) {
                a = i % V_ROWS(v);
                col = i / V_ROWS(v);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * col + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT(v))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT(v))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT(v))) / 2;
                if (*V_SEL(v) == i) {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT(v), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    }
                }
            }
            i++;
        }
        return 0;
        }

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        n = *V_SEL((unsigned char *)u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;
        }

    case EVT_HDAE_SET_SEL_NUM:
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        n = *V_SEL((unsigned char *)u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;
        }

    case EVT_HDAE_REQ_SEL_NUM:
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((unsigned char *)u));
        return 0;
        }

    case EVT_HDAE_SET_STR_ADR:
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_STRP((unsigned char *)u) = (char *)arg;
        return 0;
        }

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC(v) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL(v) != 0) {
                    CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, idx);
                    CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, idx);
                    CALLV(ROOT->SetDialEnable)(1);
                }
                return 0;
            default:
                d = 1;
                goto step;
            }
        }
        if (idx + 1 == arg) {
            d = V_ROWS(v);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS(v);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_SAVE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK2, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_ALL, (long)*V_SEL(v));
            return 0;
        }
        return 0;
        }

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        {
        long u;

        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)u), ev, arg);
        break;
        }
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_g(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    unsigned char *v;
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
    int t;
    unsigned int col;
    unsigned int a;
    int n;
    int d;
    unsigned char *u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEW(obj);
        v = u;
        *V_SHOWN((unsigned char *)(unsigned long)u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEW(obj);
        v = u;
        *V_SHOWN((unsigned char *)(unsigned long)u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEW(obj);
        v = u;
        if (V_COLS((unsigned char *)(unsigned long)u) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS(v);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS(v)) {
                t = client.x0 + cw * i - 1;
                p1.x = t;
                p2.x = t;
                if (V_COLOR(v) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        u = GETVIEW(obj);
        v = u;
        if (*V_STRP((unsigned char *)(unsigned long)u) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP(v);
        if (*V_SHOWN(v) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS(v);
        ch = (client.y1 - client.y0) / V_ROWS(v);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS(v) * V_COLS(v)) {
            buf[0] = 0;
            while (str[j] != 0) {
                if (str[j] == 9) {
                    buf[k] = 0;
                    j++;
                    k = 0;
                    break;
                }
                buf[k] = str[j];
                k++;
                j++;
            }
            if (arg == -1L || (unsigned long)arg == i) {
                a = i % V_ROWS(v);
                col = i / V_ROWS(v);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * col + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT(v))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT(v))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT(v))) / 2;
                if (*V_SEL(v) == i) {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT(v), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE(v) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(v));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(v), V_FG(v), V_COLOR(v));
                    }
                }
            }
            i++;
        }
        return 0;

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        u = GETVIEW(obj);
        v = u;
        n = *V_SEL((unsigned char *)(unsigned long)u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        u = GETVIEW(obj);
        v = u;
        n = *V_SEL((unsigned char *)(unsigned long)u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEW(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((unsigned char *)(unsigned long)u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEW(obj);
        v = u;
        *V_STRP((unsigned char *)(unsigned long)u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        u = GETVIEW(obj);
        v = u;
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC(v) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL(v) != 0) {
                    CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, idx);
                    CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, idx);
                    CALLV(ROOT->SetDialEnable)(1);
                }
                return 0;
            default:
                d = 1;
                goto step;
            }
        }
        if (idx + 1 == arg) {
            d = V_ROWS(v);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS(v);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_SAVE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_OK2, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_DEL, (long)*V_SEL(v));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_SELECT_ALL, (long)*V_SEL(v));
            return 0;
        }
        return 0;

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        u = GETVIEW(obj);
        v = u;
        CALLV(ROOT->MainFuncCall)(V_OWNER((unsigned char *)(unsigned long)u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
