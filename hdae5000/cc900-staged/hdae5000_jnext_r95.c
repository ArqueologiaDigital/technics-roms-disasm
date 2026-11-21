/* hdae5000: FILE_Naming_Screen (hdae5000_hd_driver.s) and LyricJumpEditCheck_Unregistered, round 95 (2026-11-21), run 2026-11-21-19-hd-r95-jnext: the result's test is a conditional expression evaluated for nothing, whose arms are the tested value
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r95_jnext.c.
   cc900-options: -Xr
   cc900-name: FNaming_f=HDAE5000_FILE_Naming_Screen
   cc900-name: LJUnreg_f=HDAE5000_LyricJumpEditCheck_Unregistered
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long FNaming_f(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        r != 11 ? r : r;
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
