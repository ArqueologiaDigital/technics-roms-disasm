/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_services3.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_pport_services3.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace
   cc900-module: HDAE5000_DebugTrace
   v1.10i port (h_v1misc 2026-11-19): PP_Svc19 only.  As v1.15i's (work buffer at PportInfoBlock 0x23b400 + 192),
   with v1.10i's trace banner, blank line and "work adr" format (0x2e0bfa, 0x2e0c32, 0x2e0c22; the tree's
   pport_services3.c names them the same way).
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
