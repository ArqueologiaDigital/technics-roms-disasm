/* hd_r27_a5.c (helper h_r27a): the PC DATA LINK page of hdae5000_hd_driver.s.
   Calr group: HDAE5000_PcLink_ShowStatus HDAE5000_PC_DATA_LINK_PAGE.
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
void HDAE5000_PcLink_ShowStatus(char *s)
{
    unsigned int n;

    if ((n = HDAE5000_StrLen(s)) > 25)
        n = 25;
    HDAE5000_StrNCpy((void *)(HDAE5000_RAM_PcLinkStatusText + 7), s, n);
    CALLV(ROOT->SendEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_PcLinkStatusText);
    CALLV(ROOT->SendEvent)(OBJ_PP_STATUS, EVT_PARA_DRAW, -1L);
}

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
