/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_edit_checks.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_edit_checks.c.
   cc900-options: -Xr
   cc900-name: LoadByNumEditCheck=HDAE5000_LoadByNumberModeEditCheck
   cc900-name: JumpAfterLoadEditCheck=HDAE5000_JumpAfterLoadModeEditCheck
   cc900-module: HDAE5000_Set_Menu_Visibility
   cc900-data: HDAE5000_WriteProtectEditCheck 1 = HDAE5000_WriteProtectEditCheck_CaseTable
   cc900-data: HDAE5000_LyricJumpEditCheck 1 = HDAE5000_LyricJumpEditCheck_CaseTable
   cc900-data: HDAE5000_WriteConfirmEditCheck 1 = HDAE5000_WriteConfirmEditCheck_CaseTable
   cc900-data: HDAE5000_QuickLoadModeEditCheck 1 = HDAE5000_QuickLoadModeEditCheck_CaseTable
   cc900-data: HDAE5000_LoadByNumberModeEditCheck 1 = HDAE5000_LoadByNumberModeEditCheck_CaseTable
   cc900-data: HDAE5000_JumpAfterLoadModeEditCheck 1 = HDAE5000_JumpAfterLoadModeEditCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_Set_Menu_Visibility(int hide);   /* the ROM loads the byte and extends it to WA */

/* ---- RAM ---- */
extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned char HDAE5000_RAM_LyricForeColor;
extern unsigned char HDAE5000_RAM_LyricBackColor;

/* ---- ROM ---- */
extern char *HDAE5000_TextPtrs_OFF_ON[];
extern char *HDAE5000_TextPtrs_RED_to_YELLOW[];
extern char *ram_2e2ad0[];       /* HDAE5000_TextPtrs_RED_to_YELLOW_2: its first 31 characters are the other's */
extern char HDAE5000_Fmt_s_WriteProtectEditCheck[];
extern char HDAE5000_Fmt_1d[];
extern char HDAE5000_Fmt_s_LyricForeColorCheck[];
extern char HDAE5000_Fmt_s_LyricBackColorCheck[];
extern char HDAE5000_Fmt_s_WriteConfirmEditCheck[];
extern char HDAE5000_Fmt_1d_QuickLoadModeEditCheck[];
extern char HDAE5000_Fmt_1d_LoadByNumberModeEditCheck[];
extern char HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck[];

long HDAE5000_WriteProtectEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_WriteProtectEditCheck, HDAE5000_TextPtrs_OFF_ON[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 1;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_WriteProtect;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_Set_Menu_Visibility(HDAE5000_RAM_WriteProtect);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LyricJumpEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d, arg->value);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 2;
    case EVT_GET_MIN:
        return 1;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_LyricJump;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_WriteConfirmEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_WriteConfirmEditCheck, HDAE5000_TextPtrs_OFF_ON[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 1;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_WriteConfirm;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_QuickLoadModeEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_QuickLoadModeEditCheck, arg->value);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 3;
    case EVT_GET_MIN:
        return 1;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_QuickLoadMode;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long LoadByNumEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LoadByNumberModeEditCheck, arg->value);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 2;
    case EVT_GET_MIN:
        return 1;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_LoadByNumberMode;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long JumpAfterLoadEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck, arg->value);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 2;
    case EVT_GET_MIN:
        return 1;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_JumpAfterLoad;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}
