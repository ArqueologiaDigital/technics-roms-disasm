/* lane_hd round 39, helper h_m4, file a: the SEPARATE OUTPUT module (one calr group), in ROM address order:
   HDAE5000_SeparateOutput_SendPartMsg (carried unchanged from hd_r33_hd_r4_g3.c, only so that the calr group is whole),
   HDAE5000_SeparateOutput_Apply, HDAE5000_SeparateOutputModeCheck, HDAE5000_SeparateDrumPartCheck,
   HDAE5000_SeparateBassPartCheck, and one variant of each *Check.
   cc900-options: -Xr
   cc900-module: HDAE5000_SeparateOutput_SendPartMsg HDAE5000_SeparateOutput_Apply
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck
   cc900-name: SepOutModeCheck_n=HDAE5000_SeparateOutputModeCheck
   cc900-name: SepDrumCheck_n=HDAE5000_SeparateDrumPartCheck
   cc900-name: SepBassCheck_n=HDAE5000_SeparateBassPartCheck
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 1 = HDAE5000_SeparateOutput_MsgTemplateA
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 2 = HDAE5000_SeparateOutput_MsgTemplateB
   cc900-data: HDAE5000_SeparateOutputModeCheck 1 = HDAE5000_SeparateOutputModeCheck_CaseTable
   cc900-data: HDAE5000_SeparateDrumPartCheck 1 = HDAE5000_SeparateDrumPartCheck_CaseTable
   cc900-data: HDAE5000_SeparateBassPartCheck 1 = HDAE5000_SeparateBassPartCheck_CaseTable
   What run 2026-11-16-59-hd-r8 (hd_r4_g3.c) showed, and the changes:
   - Apply: every instruction was the ROM's; the only difference was `cal` where the ROM has `calr` to SendPartMsg.
     The C is unchanged; the cc900-module line above names the two relative targets of this module.
   - the three *Check procedures: one real difference each.  The format string was written as a cast constant
     (`(const char *)0x2e2786L`) and V4.23 loaded it through XWA (`ld xwa,imm; push xwa`); the ROM pushes it as two
     words (`pushw hi16 / pushw lo16`).  The matched SPrintf calls of this ROM (hdae5000/cc900/hdae5000_fls_refresh.c,
     hdae5000_lbn_show.c) get that from an `extern char X[]` passed to a plain `char *` parameter, no conversion: so
     the prototype's second parameter is `char *` now and the formats are extern arrays.  Main forms name them
     ram_<hex> (the tree labels are longer than 31 characters); the _n variants use the tree labels (their first 31
     characters are unique among the tree's labels as far as the symbol file shows).
     Their switch tables were the ERR-data of run 59; the cc900-data lines (round 33) place them.
   Unsure: whether `jr gt` / `jrl gt` and the table base come out through the checker (they did not differ in the
   listing); SendPartMsg itself is not this helper's and is still a near miss. */
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

extern char ram_2e2786[];                               /* HDAE5000_Fmt_s_SeparateOutputModeCheck, "%s" */
extern char ram_2e2848[];                               /* HDAE5000_Fmt_s_SeparateDrumPartCheck */
extern char ram_2e290a[];                               /* HDAE5000_Fmt_s_SeparateBassPartCheck */
extern char HDAE5000_Fmt_s_SeparateOutputModeCheck[];
extern char HDAE5000_Fmt_s_SeparateDrumPartCheck[];
extern char HDAE5000_Fmt_s_SeparateBassPartCheck[];

void SepOut_SendPartMsg(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, a);
        CALLV(HAMA->sendCOMM)(0, 4, b);
    }
}

void HDAE5000_SeparateOutput_Apply(void)
{
    CALLV(HAMA->SetSepaOutMode)(HDAE5000_RAM_SeparateOutputMode);
    if (HDAE5000_RAM_SeparateDrumPartSent != 0) {
        SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateDrumPartSent = 0;
    }
    if (HDAE5000_RAM_SeparateBassPartSent != 0) {
        SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateBassPartSent = 0;
    }
    switch (HDAE5000_RAM_SeparateOutputMode) {
    case 0:
        break;
    case 1:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        break;
    case 2:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 0);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    case 3:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 2);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 1);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    }
}

long SepOutModeCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2e2786, HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[arg->value]);
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
long SepOutModeCheck_n(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SeparateOutputModeCheck,
                         HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[arg->value]);
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

long HDAE5000_SeparateDrumPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2e2848, HDAE5000_TextPtrs_NONE_to_16[arg->value]);
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
long SepDrumCheck_n(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SeparateDrumPartCheck, HDAE5000_TextPtrs_NONE_to_16[arg->value]);
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

long HDAE5000_SeparateBassPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, ram_2e290a, HDAE5000_TextPtrs_NONE_to_16_2[arg->value]);
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
long SepBassCheck_n(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SeparateBassPartCheck, HDAE5000_TextPtrs_NONE_to_16_2[arg->value]);
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
