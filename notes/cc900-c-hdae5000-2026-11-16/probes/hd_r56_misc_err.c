/* hd_r56_misc_err.c (helper h_misc, lane_hd round 56): HDAE5000_LyricJumpEditCheck_Unregistered (hdae5000_hd_driver.s,
   0x285f8b, 87 B), four new forms.  Calls only the main CPU and the library: its own calr group.
   cc900-options: -Xr
   cc900-name: LyricJumpUnreg_d=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LyricJumpUnreg_e=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LyricJumpUnreg_f=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LyricJumpUnreg_g=HDAE5000_LyricJumpEditCheck_Unregistered

   Run 2026-11-18-20-hd-r55 (hd_r54_misc_err.c, forms LyricJumpUnreg / _b / _c): all three DIFF at +26, the same
   way: everything up to the EVT_SW_IN body is the ROM's, but V4.23 dropped the test of SendEvent's result
   (`if (x) ;`, `if (x == 0) break;`, `if (x != 0) {}` all became a bare call) and, the result being unused, loaded
   the function pointer into XHL.  The ROM loads it into XIX and keeps `or xhl,xhl; jr z` to the following
   `ld xhl,0`.  V4.23 puts the pointer in XIX when the call's result is used (Frame_Handler's GetTitleNow
   compare, run hd-r20; LBNPage1SwCatch's switch), so these keep the result alive with a test the front end
   cannot fold into the case's own break:
     LyricJumpUnreg_d  `if (SendEvent(...) == 0) goto done;` with `done:` on the common `return 0`
     LyricJumpUnreg_e  the result in a long local r, then `if (r == 0) goto done;`
     LyricJumpUnreg_f  `switch (SendEvent(...)) { case 0: goto done; }`
     LyricJumpUnreg_g  `if (SendEvent(...)) ; else goto done;`
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long LyricJumpUnreg_d(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg) == 0)
            goto done;
        break;
    }
done:
    return 0;
}

long LyricJumpUnreg_e(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg);
        if (r == 0)
            goto done;
        break;
    }
done:
    return 0;
}

long LyricJumpUnreg_f(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            goto done;
        }
        break;
    }
done:
    return 0;
}

long LyricJumpUnreg_g(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg))
            ;
        else
            goto done;
        break;
    }
done:
    return 0;
}
