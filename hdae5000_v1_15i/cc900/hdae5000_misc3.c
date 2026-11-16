/* Functions of hdae5000_ui_display.s.  (hdae5000_misc3.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_misc3.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
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

/* no label in the tree: the procedure at 0x285f8b */

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
