/* hdae5000_v1_10i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-63-hd-r75-v1fix (hd_r75c_pport_services3__svc19.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r75c_pport_services3__svc19.c.
   cc900-options: -Xr
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_RAM_PportInfoBlock[];

#define PPIB HDAE5000_RAM_PportInfoBlock

/* trace banners and blank lines (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2e0bfa[], ram_2e0c32[];                                   /* Svc19 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2e0c22[];
#define F_work_adr ram_2e0c22

/* HDAE5000_DebugTrace (this module, calr) is called undeclared, as in v2.06i's file */

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2e0bfa);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[192]);
    HDAE5000_DebugTrace(ram_2e0c32);
    return PPIB + 192;
}
