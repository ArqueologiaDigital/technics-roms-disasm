/* hdae5000_v1_15i: the functions of hdae5000/cc900/hdae5000_pclink_page.c that V4.23 reproduces in HD-AE5000 v1.15i with the tree's own object ids (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_pclink_page.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_PcLink_ShowStatus
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

/* other modules (call) */
extern void HDAE5000_PPORT_StartLink(void);
extern void HDAE5000_PPORT_Reset(void);

extern char HDAE5000_RAM_PcLinkStatusText[];
extern char HDAE5000_Str_PCLK[];
extern char HDAE5000_Str_PORTISACTIVE[];
extern char HDAE5000_Str_Blank14[];

/* at most 25 characters of s into the status text (from its column 7), then shown in OBJ_PP_STATUS.
   The ROM keeps the length in HL (the StrLen result, clamped in place) and loads the destination with
   `lda xwa,(HDAE5000_RAM_PcLinkStatusText+7:24); push xwa` (a converted argument). */

long HDAE5000_PC_DATA_LINK_PAGE(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_PCLK);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
        case 1:
            HDAE5000_PcLink_ShowStatus(HDAE5000_Str_PORTISACTIVE);
            HDAE5000_PPORT_StartLink();
            break;
        case 6:
        case 7:
            HDAE5000_PPORT_Reset();
            HDAE5000_PcLink_ShowStatus(HDAE5000_Str_Blank14);
            CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            break;
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
