/* Functions of hdae5000_hd_driver.s.  (hdae5000_sepout.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_sepout.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck
   cc900-module: HDAE5000_SeparateOutput_SendPartMsg HDAE5000_SeparateOutput_Apply
   cc900-data: HDAE5000_SeparateOutputModeCheck 1 = HDAE5000_SeparateOutputModeCheck_CaseTable
   cc900-data: HDAE5000_SeparateDrumPartCheck 1 = HDAE5000_SeparateDrumPartCheck_CaseTable
   cc900-data: HDAE5000_SeparateBassPartCheck 1 = HDAE5000_SeparateBassPartCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern unsigned char HDAE5000_RAM_SeparateDrumPartSent;
extern unsigned char HDAE5000_RAM_SeparateBassPartSent;
extern char *HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[];
extern char *HDAE5000_TextPtrs_NONE_to_16[];
extern char *HDAE5000_TextPtrs_NONE_to_16_2[];

extern char ram_2cacee[];                               /* HDAE5000_Fmt_s_SeparateOutputModeCheck, "%s" */
extern char ram_2cadb0[];                               /* HDAE5000_Fmt_s_SeparateDrumPartCheck */
extern char ram_2cae72[];                               /* HDAE5000_Fmt_s_SeparateBassPartCheck */
extern char HDAE5000_Fmt_s_SeparateOutputModeCheck[];
extern char HDAE5000_Fmt_s_SeparateDrumPartCheck[];
extern char HDAE5000_Fmt_s_SeparateBassPartCheck[];

void HDAE5000_SeparateOutput_Apply(void)
{
    CALLV(HAMA->SetSepaOutMode)(HDAE5000_RAM_SeparateOutputMode);
    if (HDAE5000_RAM_SeparateDrumPartSent != 0) {
        HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateDrumPartSent = 0;
    }
    if (HDAE5000_RAM_SeparateBassPartSent != 0) {
        HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateBassPartSent = 0;
    }
    switch (HDAE5000_RAM_SeparateOutputMode) {
    case 0:
        break;
    case 1:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        break;
    case 2:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 0);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    case 3:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 2);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 1);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    }
}

long SepOutModeCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2cacee, HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 3;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateOutputMode;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}

/* variant: the format under its tree label */

long HDAE5000_SeparateDrumPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2cadb0, HDAE5000_TextPtrs_NONE_to_16[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 16;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateDrumPart;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}

/* variant: the format under its tree label */

long HDAE5000_SeparateBassPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2cae72, HDAE5000_TextPtrs_NONE_to_16_2[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 16;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateBassPart;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}

/* variant: the format under its tree label */
