/* Functions of hdae5000_ui_display.s.  (hdae5000_setup.c, ported to hdae5000_v1_10i)
   Firmware C (cc900 phase 6), built by Toshiba V4.23.
   cc900-options: -Xr
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo HDAE5000_CopyVersionString
   v1.10i: the version string is HDAE5000_Str_V110i ("V1.10i"); the code is otherwise the same.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(char *);

extern char HDAE5000_Str_V110i[];   /* "V1.10i" */
#define VERSION HDAE5000_Str_V110i

int HDAE5000_CopyVersionString(char *dst);

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
