/* hd_r94_jnext.c (lane_hd round 94, 2026-11-21): HDAE5000_FILE_Naming_Screen (46 B) and
   HDAE5000_LyricJumpEditCheck_Unregistered (87 B), the conditional jump to the next instruction.
   cc900-options: -Xr
   cc900-name: FNaming_d=HDAE5000_FILE_Naming_Screen
   cc900-name: FNaming_e=HDAE5000_FILE_Naming_Screen
   cc900-name: LJUnreg_d=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LJUnreg_e=HDAE5000_LyricJumpEditCheck_Unregistered
   Run 2026-11-21-17-hd-r93-jnext (hd_r93_jnext.c): the conditional expression evaluated for nothing,
   `r != 11 ? 0 : 0;` (FNaming_b), KEPT the ROM's `cp xhl,11; jr z` and the pointer in XIX: the only difference
   was V4.23 loading each arm's constant (`ld a,0` twice).  `||` / `&&` forms dropped the test (a) or built a truth
   value (c).  So the arms must generate nothing: void arms.
     FNaming_d / LJUnreg_d  r != 11 ? (void)0 : (void)0;   /   r ? (void)0 : (void)0;
     FNaming_e / LJUnreg_e  (void)(r != 11 ? 0 : 0);         /   (void)(r ? 0 : 0);
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long FNaming_d(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        r != 11 ? (void)0 : (void)0;
    }
    return 0;
}

long FNaming_e(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        (void)(r != 11 ? 0 : 0);
    }
    return 0;
}

long LJUnreg_d(long obj, long ev, struct ParaBlk *arg)
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
        r ? (void)0 : (void)0;
        break;
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
