/* hdae5000_v1_15i: FILE_Naming_Screen (hdae5000_hd_driver.s), v2.06i's C of round 95 (2026-11-21), the same hand text in this tree
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r95_jnext.c.
   cc900-options: -Xr
   cc900-name: FNaming_f=HDAE5000_FILE_Naming_Screen
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long FNaming_f(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        r != 11 ? r : r;
    }
    return 0;
}
