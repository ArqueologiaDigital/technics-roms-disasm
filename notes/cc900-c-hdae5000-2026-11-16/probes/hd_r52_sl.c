/* hd_r52_sl.c (lane_hd round 52): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), four forms written by
   selectlist/gen.py --round 52.  It calls nothing relatively.
   cc900-options: -Xr
   cc900-name: SelList_p=HDAE5000_SelectListProc
   cc900-name: SelList_q=HDAE5000_SelectListProc
   cc900-name: SelList_r=HDAE5000_SelectListProc
   cc900-name: SelList_s=HDAE5000_SelectListProc
   Read-out of run 2026-11-18-4-hd-r50 (hd_r50_sl.c): only a register local u keeps the call's result in XHL, so
   that the function pointer is loaded into XIX as in the ROM (forms k and the label's); without one (m), or with
   `u = v = ..` / `v = ..; u = v;` (h, i, j), the pointer goes through XHL and v is reloaded from the stack.  Form k
   (f's order, the label's spelling) differs from the ROM only in item 4: at the nine first uses the ROM copies u
   to XWA and reads (xwa+N), V4.23 reads (xhl+N) straight.  These forms use u as an INTEGER at those nine places,
   V_xxx(u) = *(T *)(u + N) on a long (the integer-address idiom), instead of the cast (unsigned char *)u:
     SelList_p  long u;  u = GETVIEWL(obj); v = (unsigned char *)u;  first use V_xxx(u)
     SelList_q  unsigned long u (the call's result as unsigned long)
     SelList_r  v = (unsigned char *)(u = GETVIEWL(obj));
     SelList_s  first use V_xxx((long)u)
   The INDEXSW case keeps k's spelling there.
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

long SelList_p(long obj, long ev, long arg)
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
        *V_SHOWN(u) = 1;
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
        *V_SHOWN(u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (V_COLS(u) >= 2) {
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
        if (*V_STRP(u) == 0)
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
        n = *V_SEL(u);
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
        n = *V_SEL(u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL(u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_STRP(u) = (char *)arg;
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
        CALLV(ROOT->MainFuncCall)(V_OWNER(u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_q(long obj, long ev, long arg)
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
    unsigned long u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        *V_SHOWN(u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        *V_SHOWN(u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        if (V_COLS(u) >= 2) {
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
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        if (*V_STRP(u) == 0)
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
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        n = *V_SEL(u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        n = *V_SEL(u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL(u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        *V_STRP(u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
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
        u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_r(long obj, long ev, long arg)
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
    long u;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        v = (unsigned char *)(u = GETVIEWL(obj));
        *V_SHOWN(u) = 1;
        if (V_DIAL(v) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_SHOW, 0L);
        return 0;

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        v = (unsigned char *)(u = GETVIEWL(obj));
        *V_SHOWN(u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        v = (unsigned char *)(u = GETVIEWL(obj));
        if (V_COLS(u) >= 2) {
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
        v = (unsigned char *)(u = GETVIEWL(obj));
        if (*V_STRP(u) == 0)
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
        v = (unsigned char *)(u = GETVIEWL(obj));
        n = *V_SEL(u);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(v) * V_ROWS(v))
            CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;

    case EVT_HDAE_SET_SEL_NUM:
        v = (unsigned char *)(u = GETVIEWL(obj));
        n = *V_SEL(u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        v = (unsigned char *)(u = GETVIEWL(obj));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL(u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        v = (unsigned char *)(u = GETVIEWL(obj));
        *V_STRP(u) = (char *)arg;
        return 0;

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        v = (unsigned char *)(u = GETVIEWL(obj));
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
        v = (unsigned char *)(u = GETVIEWL(obj));
        CALLV(ROOT->MainFuncCall)(V_OWNER(u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long SelList_s(long obj, long ev, long arg)
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
        *V_SHOWN((long)u) = 1;
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
        *V_SHOWN((long)u) = 0;
        return 0;

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        if (V_COLS((long)u) >= 2) {
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
        if (*V_STRP((long)u) == 0)
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
        n = *V_SEL((long)u);
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
        n = *V_SEL((long)u);
        *V_SEL(v) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(v));
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(v));
        return 0;

    case EVT_HDAE_REQ_SEL_NUM:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        CALLV(ROOT->MainFuncCall)(V_OWNER(v), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL((long)u));
        return 0;

    case EVT_HDAE_SET_STR_ADR:
        u = GETVIEWL(obj);
        v = (unsigned char *)u;
        *V_STRP((long)u) = (char *)arg;
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
        CALLV(ROOT->MainFuncCall)(V_OWNER((long)u), ev, arg);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
