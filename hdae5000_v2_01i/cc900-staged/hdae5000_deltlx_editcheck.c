/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_deltlx_editcheck.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_deltlx_editcheck.c.
   cc900-options: -Xr
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
