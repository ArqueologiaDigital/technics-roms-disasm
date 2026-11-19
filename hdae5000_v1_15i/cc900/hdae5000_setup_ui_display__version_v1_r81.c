/* Functions of hdae5000_ui_display.s.  (hdae5000_setup_ui_display__version_v1_r81.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_setup_ui_display__version_v1_r81.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo HDAE5000_CopyVersionString
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(char *);

extern char HDAE5000_Str_V115i[];   /* "V1.15i" */
#define VERSION HDAE5000_Str_V115i

int HDAE5000_CopyVersionString(char *dst);

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
