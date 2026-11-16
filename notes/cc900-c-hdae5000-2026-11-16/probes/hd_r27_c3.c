/* lane_hd round 27, helper h_r27c, file 3: functions with no relative call (any C file can hold them), in ROM
   address order: HDAE5000_PPORT_Svc26_ShowStatus (0x284d7f), the unlabelled procedure at 0x285f8b (the code after
   HDAE5000_LyricJumpEditCheck_Epilogue's `ret`, which the survey lists as the tail of
   HDAE5000_LyricJumpEditCheck_Default), HDAE5000_ErrMsgTimerCatch (0x28b403), HDAE5000_HD_RestoreSettings (0x293ee2).
   cc900-options: -Xr
   Reading of the hand source:
   - Svc26_ShowStatus: the length stays in HL (clamped there, then pushed); the string goes through XWA for both
     library calls (`ld xwa,xiz; push xwa`: a converted argument, char * to const char *) and the text is pushed with
     `lda xwa,(sym+7); push xwa` (converted too: an unsigned char array to char *); the SET_STR_ADR argument is
     `lda xwa,(sym); ld xde,xwa` (WRAP, the matched TitleInfo_Build).
   - LyricJumpProc_285f8b: NO LABEL in the tree at 0x285f8b, so the checker cannot place it until one exists; the
     name here is a placeholder.  The event is compared in XBC (it is dead after the switch, so no copy to XWA);
     cases in ROM order GET_RAM_STRING, RAM_DATA_REQ, SW_IN; SW_IN ends in `or xhl,xhl; jr z` to the next
     instruction: an `if` with an empty body.
   - ErrMsgTimerCatch: the shape of the matched AttenDelDirSwCatch (default first).
   - HD_RestoreSettings: the matched HDAE5000_HD_StoreTables with HDAE5000_HD_LoadSettings (hand assembly) in the
     middle.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_LoadSettings(void);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern unsigned char HDAE5000_RAM_PcLinkStatusText[];
extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];
extern char HDAE5000_Str_Timb[];

void HDAE5000_PPORT_Svc26_ShowStatus(char *s)
{
    unsigned int n;

    n = HDAE5000_StrLen(s);
    if (n > 25)
        n = 25;
    HDAE5000_StrNCpy(&HDAE5000_RAM_PcLinkStatusText[7], s, n);
    CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PcLinkStatusText));
    CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_PARA_DRAW, -1L);
}

/* no label in the tree: the procedure at 0x285f8b */
long LyricJumpProc_285f8b(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID) != 0) {
        }
        break;
    }
    return 0;
}

long HDAE5000_ErrMsgTimerCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Timb);
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(arg, EVT_SHOW, 0L);
        return 0;
    }
}

int HDAE5000_HD_RestoreSettings(int keep)
{
    int st;

    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_LoadSettings();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}
