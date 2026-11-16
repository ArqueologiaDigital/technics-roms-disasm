/* hd_r27_a5b.c (helper h_r27a): second form of HDAE5000_PcLink_ShowStatus (hd_r27_a5.c): the length clamped by
   a separate statement, the destination as &text[7] cast to char *.
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
