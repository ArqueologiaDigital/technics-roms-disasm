/* Functions of hdae5000_ui_display.s.  (hdae5000_show_error_title.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_show_error_title.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

/* show an error: SetGlobalError(code), then replace any pending title interrupt by the message title */
void HDAE5000_ShowErrorMessageTitle(int code)
{
    CALLV(HAMA->SetGlobalError)((unsigned char)code);
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
}
