/* hdae5000_v2_01i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-62-hd-r74-v201 (hd_r74v_setup_ui_display__version.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r74v_setup_ui_display__version.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo HDAE5000_CopyVersionString
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(char *);

extern char HDAE5000_Str_V201i[];   /* "V2.01i" */
#define VERSION HDAE5000_Str_V201i

int HDAE5000_CopyVersionString(char *dst);

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
