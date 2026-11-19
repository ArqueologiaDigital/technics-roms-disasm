/* Functions of hdae5000_hd_driver.s.  (hdae5000_saveopt_name__saveopt_r71.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_saveopt_name__saveopt_r71.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Scan HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_BuildMask
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_SaveOptNameCheck 1 = HDAE5000_SaveOptNameCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern char ram_23d286[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */

/* ---- ROM ---- */
extern char HDAE5000_Fmt_s_SaveOptNameCheck[];

long HDAE5000_SaveOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SaveOptNameCheck, ram_23d286);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 0;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        return 0;
    default:
        return 0;
    }
}
