/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r52_sl.c (2026-11-18-13-hd-r52)
   sha256 48b3101dbf40105b399f2f4faadf9319f20d647a9b7a6050d3fa7c9b52a0dce3 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: SelList_p=HDAE5000_SelectListProc */
struct RootFns {
    void *pad0[33];
    void *UpdateScreen;
    void *pad1[5];
    void *DrawLine;
    void *pad2[1];
    void *DrawBox;
    void *DrawFrame;
    void *pad3[1];
    void *MovePixels;
    void *pad4[4];
    void *DrawString;
    void *pad5[5];
    void *InheritedProc;
    void *pad6[1];
    void *RegisterObjectTable;
    void *pad7[6];
    void *SendEvent;
    void *PostEvent;
    void *pad8[7];
    void *ApPostEvent;
    void *pad9[5];
    void *ResEventProc;
    void *ResMethodProc;
    void *pad10[1];
    void *ResNameProc;
    void *pad11[1];
    void *GetCharHeight;
    void *GetCharDescent;
    void *GetCenteredDelta;
    void *ConvertStrings;
    void *pad12[2];
    void *ClassProc;
    void *pad13[54];
    void *FunctionProc;
    void *ApFunctionProc;
    void *MainFunctionProc;
    void *ApFuncCall;
    void *MainFuncCall;
    void *pad14[6];
    void *RegisterTitle;
    void *pad15[1];
    void *GetTitleNow;
    void *pad16[1];
    void *ViewableProc;
    void *pad17[4];
    void *SetVisible;
    void *pad18[11];
    void *GetViewInstance;
    void *pad19[3];
    void *GetClientBox;
    void *pad20[1];
    void *DrawDesignBox;
    void *pad21[57];
    void *SetDialEnable;
    void *SetDialUp;
    void *SetDialDown;
    void *pad22[16];
    void *SetApTimer;
    void *pad23[1];
    void *KillApTimer;
    void *pad24[4];
    void *SetAutoInc;
    void *pad25[55];
    void *GetNamingWindowID;
    void *pad26[9];
    void *DeleteEvent;
    void *SleepMainTask;
    void *WakeUpMainTask;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HIDE 0x1c00002L
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_SEQ_STOP 0x1ca0000L
#define EVT_HDAE_AFTER_LOAD 0x1ca0001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_PAINT 0x1c0000bL
#define EVT_INDEXSW_UP 0x1c00017L
#define EVT_INDEXSW_DOWN 0x1c00018L
#define EVT_INDEXSW_UP_AIC 0x1c00019L
#define EVT_INDEXSW_DOWN_AIC 0x1c0001aL
#define EVT_GET_INDEX 0x1e00051L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_REQ_SEL_NUM 0x1ea0004L
#define EVT_HDAE_ACK_SEL_NUM 0x1ea0005L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_OK2 0x1ea0007L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define EVT_HDAE_SELECT_ALL 0x1ea0009L
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define EVT_HDAE_SELECT_DEL 0x1ea000cL
#define EVT_HDAE_SELECT_DEL_FILE 0x1ea000dL
struct Point { int x; int y; };
struct Rect { int x0; int y0; int x1; int y1; };
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
#define GETVIEWL(o) CALLR(long, ROOT->GetViewInstance)(o)
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
