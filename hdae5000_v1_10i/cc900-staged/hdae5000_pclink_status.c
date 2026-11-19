/* hdae5000_v1_10i: the functions of hdae5000/cc900/hdae5000_pclink_status.c that V4.23 reproduces in HD-AE5000 v1.10i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_pclink_status.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_PcLink_ShowStatus
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

extern unsigned char HDAE5000_RAM_PcLinkStatusText[];

void HDAE5000_PcLink_ShowStatus(char *s)
{
    unsigned int n;

    n = HDAE5000_StrLen(s);
    if (n > 25)
        n = 25;
    HDAE5000_StrNCpy((char *)&HDAE5000_RAM_PcLinkStatusText[7], s, n);
    CALLV(ROOT->SendEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_PcLinkStatusText);
    CALLV(ROOT->SendEvent)(OBJ_PP_STATUS, EVT_PARA_DRAW, -1L);
}
