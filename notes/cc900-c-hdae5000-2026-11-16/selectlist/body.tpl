long @NAME@(long obj, long ev, long arg)
{
    struct Point p1;
    struct Point p2;
    struct Rect client;
    struct Rect box;
    char buf[50];
    @VDECL@
    unsigned int i;
    unsigned int j;
    unsigned int cw;
    unsigned int ch;
    char *str;
    int k;
    long idx;
@REGS@

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, -1L);
        return 0;

    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        @GET@
        *V_SHOWN(@U@) = 1;
        if (V_DIAL(@V@) != 0) {
            CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
            CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
            CALLV(ROOT->SetDialEnable)(1);
        }
        CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_SHOW, 0L);
        return 0;
        @END@

    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        @GET@
        *V_SHOWN(@U@) = 0;
        return 0;
        @END@

    case EVT_PAINT:
        /* the vertical lines between the columns */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        @GET@
        if (V_COLS(@U@) >= 2) {
            CALLV(ROOT->GetClientBox)(obj, (int *)&client);
            cw = (client.x1 - client.x0) / V_COLS(@V@);
            p1.y = client.y0 + 1;
            p2.y = client.y1 - 1;
            i = 1;
            while (i < V_COLS(@V@)) {
@PAINTX@
                if (V_COLOR(@V@) == 7)
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 0xff);
                else
                    CALLV(ROOT->DrawLine)((int *)&p1, (int *)&p2, 7);
                i++;
            }
        }
        return 0;
        @END@

    case EVT_PARA_DRAW:
        /* arg = the cell to draw, -1 for all */
        @GET@
        if (*V_STRP(@U@) == 0)
            str = HDAE5000_TextPtrs_01Selectlist0203040506070809[0];
        else
            str = *V_STRP(@V@);
        if (*V_SHOWN(@V@) != 1)
            return 0;
        CALLV(ROOT->GetClientBox)(obj, (int *)&client);
        cw = (client.x1 - client.x0) / V_COLS(@V@);
        ch = (client.y1 - client.y0) / V_ROWS(@V@);
        i = 0;
        j = 0;
        k = 0;
        while (i < V_ROWS(@V@) * V_COLS(@V@)) {
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
@CELLDECL@
                a = i % V_ROWS(@V@);
                @COL@ = i / V_ROWS(@V@);
                t = client.y0 + ch * a + 1;
                box.y0 = t;
                box.y1 = t + ch - 1;
                t = client.x0 + cw * @COLUSE@ + 1;
                box.x0 = t;
                box.x1 = t + cw - 4;
                p1.x = box.x0;
                p1.y = box.y0 + (ch >> 1);
                p1.y += CALLR(int, ROOT->GetCenteredDelta)(V_FONT(@V@))
                        + -(CALLR(int, ROOT->GetCharHeight)(V_FONT(@V@))
                            - CALLR(int, ROOT->GetCharDescent)(V_FONT(@V@))) / 2;
                if (*V_SEL(@V@) == i) {
                    if (V_STYLE(@V@) == 0) {
                        CALLV(ROOT->DrawBox)(&box, 0xff);
                        CALLV(ROOT->DrawString)((void *)&box, (void *)&p1, (void *)buf, V_FONT(@V@), 0, 0xf7);
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(@V@));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(@V@), V_FG(@V@), V_COLOR(@V@));
                        CALLV(ROOT->DrawFrame)(&box, 0xf2);
                    }
                } else {
                    if (V_STYLE(@V@) == 0) {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(@V@));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(@V@), V_FG(@V@), V_COLOR(@V@));
                    } else {
                        CALLV(ROOT->DrawBox)(&box, V_COLOR(@V@));
                        CALLV(ROOT->DrawString)(&box.x0, &p1.x, &buf[0], V_FONT(@V@), V_FG(@V@), V_COLOR(@V@));
                    }
                }
            }
            i++;
        }
        return 0;
        @END@

    case EVT_HDAE_CHANGE_SEL_NUM:
        /* arg = the step; outside the page the owner is told */
        @GET@
        n = *V_SEL(@U@);
        n += (int)arg;
        if (n < 0)
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_UNDER_FLOW, (long)n);
        else if (n >= V_COLS(@V@) * V_ROWS(@V@))
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_OVER_FLOW, (long)n);
        else
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_SET_SEL_NUM, (long)n);
        return 0;
        @END@

    case EVT_HDAE_SET_SEL_NUM:
        @GET@
        n = *V_SEL(@U@);
        *V_SEL(@V@) = (int)arg;
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)n);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)*V_SEL(@V@));
        CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_CHANGE_SEL_NUM, (long)*V_SEL(@V@));
        return 0;
        @END@

    case EVT_HDAE_REQ_SEL_NUM:
        @GET@
        CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_ACK_SEL_NUM, (long)*V_SEL(@U@));
        return 0;
        @END@

    case EVT_HDAE_SET_STR_ADR:
        @GET@
        *V_STRP(@U@) = (char *)arg;
        return 0;
        @END@

    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        /* arg = the switch; the list's switches are idx .. idx + 8 */
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        d = 0;
        idx = CALLR(long, ROOT->SendEvent)(obj, EVT_GET_INDEX, 0L);
        @GET@
        if (arg == idx) {
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                d = -1;
            step:
                CALLV(ROOT->SendEvent)(obj, EVT_HDAE_CHANGE_SEL_NUM, (long)d);
                if (V_AUTOINC(@V@) != 0)
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                if (V_DIAL(@V@) != 0) {
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
            d = V_ROWS(@V@);
            goto step;
        }
        if (idx + 2 == arg) {
            d = -V_ROWS(@V@);
            goto step;
        }
        if (idx + 3 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_OK, (long)*V_SEL(@V@));
            return 0;
        }
        if (idx + 4 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_SAVE, (long)*V_SEL(@V@));
            return 0;
        }
        if (idx + 5 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_DEL_FILE, (long)*V_SEL(@V@));
            return 0;
        }
        if (idx + 6 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_OK2, (long)*V_SEL(@V@));
            return 0;
        }
        if (idx + 7 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_DEL, (long)*V_SEL(@V@));
            return 0;
        }
        if (idx + 8 == arg) {
            CALLV(ROOT->MainFuncCall)(V_OWNER(@V@), EVT_HDAE_SELECT_ALL, (long)*V_SEL(@V@));
            return 0;
        }
        return 0;
        @END@

    case EVT_HDAE_SEQ_STOP:
    case EVT_HDAE_AFTER_LOAD:
    case EVT_HDAE_TIMER_BACK:
        @GET@
        CALLV(ROOT->MainFuncCall)(V_OWNER(@U@), ev, arg);
        break;
        @END@
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
