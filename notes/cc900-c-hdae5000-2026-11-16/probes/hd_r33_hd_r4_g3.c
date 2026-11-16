/* lane_hd round 4, helper h_small, group 3 (one calr group = one module): SEPARATE OUTPUT, in ROM address order:
   HDAE5000_SeparateOutput_SendPartMsg, _SeparateOutput_Apply, _SeparateOutputModeCheck, _SeparateDrumPartCheck,
   _SeparateBassPartCheck.  Options: -Xr.
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck
   (hd_r33_hd_r4_g3.c, helper h_data, round 33: hd_r4_g3.c's text with the places of V4.23's own data added)
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 1 = HDAE5000_SeparateOutput_MsgTemplateA
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 2 = HDAE5000_SeparateOutput_MsgTemplateB
   cc900-data: HDAE5000_SeparateOutputModeCheck 1 = HDAE5000_SeparateOutputModeCheck_CaseTable
   cc900-data: HDAE5000_SeparateDrumPartCheck 1 = HDAE5000_SeparateDrumPartCheck_CaseTable
   cc900-data: HDAE5000_SeparateBassPartCheck 1 = HDAE5000_SeparateBassPartCheck_CaseTable
   Reading of the hand source:
   - SendPartMsg's two 4-byte messages are initialised auto arrays: V4.23 copies the initialiser from a hidden ROM
     copy (HDAE5000_SeparateOutput_MsgTemplateA / B = {0xb0,0,0x9b,0} / {0xb0,0,0x9d,0}) with two ldiw each; the first
     declared is at the higher frame address (xsp+4), as round 3 found; `ld l,c` saves C from ldiw's BC counter.
     Its parameters are char (it reads A, C, E) but Apply loads BC / DE with 16-bit zeros and widens A: char
     arguments are passed widened (form b tries a K&R definition instead).
   - `uc - 1` is computed in byte width (`dec 1,a; extz wa`), V4.23's own narrowing (run 2026-11-16-45 SeqPart_*).
   - Apply's switch: V4.23 compares the cases in REVERSE SOURCE ORDER (AttenCpToHDSwCatch, run 49: 07, 0d, 85 for
     source order 85, 0d, 07; HD_GetBlockInfo's 2, 1, 0 fits both readings), so the source order is 0, 1, 2, 3.
   - The three *Check procedures: (obj, event, arg) with arg a parameter block (+0x0e the value as a long, +0x12 the
     destination string).  Case bodies in ROM order: GET_RAM_STRING, LARGE_STEP, SMALL_STEP, MAX, MIN, RAM_ADDRESS,
     RAM_SIZE, RAM_DATA_REQ, then the default; GET_LSW_* fall to the default (return 0, no InheritedProc).
   - The format strings are pushed as 32-bit constants (`pushw hi16 / lo16`), which V4.23 does for a stacked string
     literal and not for an extern array (h_pport, run 56): written as constant pointers at their ROM addresses.
     The value-text tables are extern arrays indexed by a long (`ld xbc, sym` immediate: a dereference). */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern unsigned char HDAE5000_RAM_SeparateDrumPartSent;
extern unsigned char HDAE5000_RAM_SeparateBassPartSent;
extern char *HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[];
extern char *HDAE5000_TextPtrs_NONE_to_16[];
extern char *HDAE5000_TextPtrs_NONE_to_16_2[];

#define FMT_S_MODE ((const char *)0x2e2786L)   /* HDAE5000_Fmt_s_SeparateOutputModeCheck, "%s" */
#define FMT_S_DRUM ((const char *)0x2e2848L)   /* HDAE5000_Fmt_s_SeparateDrumPartCheck */
#define FMT_S_BASS ((const char *)0x2e290aL)   /* HDAE5000_Fmt_s_SeparateBassPartCheck */

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
        HDAE5000_SPrintf(arg->str, FMT_S_MODE, HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[arg->value]);
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
        HDAE5000_SPrintf(arg->str, FMT_S_DRUM, HDAE5000_TextPtrs_NONE_to_16[arg->value]);
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
        HDAE5000_SPrintf(arg->str, FMT_S_BASS, HDAE5000_TextPtrs_NONE_to_16_2[arg->value]);
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
