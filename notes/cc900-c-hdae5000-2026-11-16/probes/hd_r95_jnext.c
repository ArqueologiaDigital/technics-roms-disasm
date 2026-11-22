/* hd_r95_jnext.c (lane_hd round 95, 2026-11-21): HDAE5000_FILE_Naming_Screen (46 B) and
   HDAE5000_LyricJumpEditCheck_Unregistered (87 B), the conditional jump to the next instruction.
   cc900-options: -Xr
   cc900-name: FNaming_e=HDAE5000_FILE_Naming_Screen
   cc900-name: FNaming_f=HDAE5000_FILE_Naming_Screen
   cc900-name: LJUnreg_e=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LJUnreg_f=HDAE5000_LyricJumpEditCheck_Unregistered
   Run 2026-11-21-18-hd-r94-jnext: V4.23 refused round 94's file (THC1-Error-300, void arms `? (void)0 : (void)0`).
   Round 93's `r != 11 ? 0 : 0;` kept the ROM's test and jump, plus a constant load per arm.  Here:
     FNaming_e / LJUnreg_e  (void)(r != 11 ? 0 : 0);  /  (void)(r ? 0 : 0);   (round 94's second form, uncompiled)
     FNaming_f / LJUnreg_f  r != 11 ? r : r;           /  r ? r : r;           (arms the value already in XHL)
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long FNaming_e(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        (void)(r != 11 ? 0 : 0);
    }
    return 0;
}

long FNaming_f(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        r != 11 ? r : r;
    }
    return 0;
}

long LJUnreg_e(long obj, long ev, struct ParaBlk *arg)
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
        (void)(r ? 0 : 0);
        break;
    }
    return 0;
}

long LJUnreg_f(long obj, long ev, struct ParaBlk *arg)
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
        r ? r : r;
        break;
    }
    return 0;
}
