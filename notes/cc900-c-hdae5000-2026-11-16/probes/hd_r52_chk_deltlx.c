/* lane_hd round 52, helper h_chk: second try at HDAE5000_DelTlxEditCheck (run 2026-11-18-7-hd-r51 differed only
   in GET_MIN).  The ROM computes `flag==1 ? 2 : 1` FIRST, in the general form (test, ld xhl,2, jump, ld xhl,1),
   then tests flag==0 and loads 0.  V4.23 preloads the constant arm of every ?: of round 50, so here statements on
   a local r, hoping r lives in XHL (assigned only where no call follows):
   HDAE5000_DelTlxEditCheck: r declared at the top;  DelTlx_b: r declared in the case block;
   DelTlx_c: one statement `r = flag == 1 ? (0, 2L) : (0, 1L);` (comma arms are not constants, so the general
   form) then `if (flag == 0) r = 0;`.
   cc900-options: -Xr
   cc900-name: DelTlx_b=HDAE5000_DelTlxEditCheck
   cc900-name: DelTlx_c=HDAE5000_DelTlxEditCheck
   cc900-module: HDAE5000_TypeSel_BuildMask
   cc900-data: HDAE5000_DelTlxEditCheck 1 = HDAE5000_DelTlxEditCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);

extern struct TypeSel HDAE5000_RAM_DeleteOptions;

extern char *HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[];
extern char HDAE5000_Fmt_s_DelTlxEditCheck[];

long HDAE5000_DelTlxEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelTlxEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[8] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_DeleteOptions.flag[8] == 1)
            r = 2;
        else
            r = 1;
        if (HDAE5000_RAM_DeleteOptions.flag[8] == 0)
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long DelTlx_b(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelTlxEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[8] == 0 ? 0L : 2L;
    case EVT_GET_MIN: {
        long r;
        if (HDAE5000_RAM_DeleteOptions.flag[8] == 1)
            r = 2;
        else
            r = 1;
        if (HDAE5000_RAM_DeleteOptions.flag[8] == 0)
            r = 0;
        return r;
    }
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long DelTlx_c(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelTlxEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[8] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        r = HDAE5000_RAM_DeleteOptions.flag[8] == 1 ? (0, 2L) : (0, 1L);
        if (HDAE5000_RAM_DeleteOptions.flag[8] == 0)
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}
