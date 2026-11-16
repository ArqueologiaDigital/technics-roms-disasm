/* lane_hd round 4, helper h_small, group 3, form b: hd_r4_g3.c's functions (same names) with:
   - SendPartMsg defined K&R style (char parameters, int-widened arguments), with early returns and the two
     message arrays filled by assignments from extern templates (a struct copy) instead of auto initialisers;
   - Apply's case 0 written `return;`.
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck */
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

struct Msg4 { unsigned char b[4]; };
extern struct Msg4 ram_2e272e;   /* HDAE5000_SeparateOutput_MsgTemplateA (its first 31 characters are shared with B) */
extern struct Msg4 ram_2e2732;   /* HDAE5000_SeparateOutput_MsgTemplateB */

void SepOut_SendPartMsg(part, bank, mode)
unsigned char part, bank, mode;
{
    struct Msg4 a;
    struct Msg4 b;

    a = ram_2e272e;
    b = ram_2e2732;   /* HDAE5000_SeparateOutput_MsgTemplateB */
    if (part >= 16)
        return;
    if (bank > 1)
        return;
    if (mode > 2)
        return;
    a.b[1] = part;
    b.b[1] = part;
    if (bank == 0)
        a.b[3] = 0x01;
    else
        a.b[3] = 0x20;
    if (mode == 0)
        b.b[3] = 0;
    else if (mode == 1)
        b.b[3] = 1;
    else
        b.b[3] = 2;
    CALLV(HAMA->sendCOMM)(0, 4, &a);
    CALLV(HAMA->sendCOMM)(0, 4, &b);
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
        return;
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
