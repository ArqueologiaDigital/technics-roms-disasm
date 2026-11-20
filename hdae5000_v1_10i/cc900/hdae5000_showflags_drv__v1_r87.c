/* Functions of hdae5000_hd_driver.s.  (hdae5000_showflags_drv__v1_r87.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_showflags_drv__v1_r87.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern struct TypeSel HDAE5000_RAM_SaveOptions;
/* "---", "NO ", "YES" (34 characters: unique in its first 31) */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];

void HDAE5000_TypeSel_ShowSaveFlags(void)
{
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_LSW, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[0]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_PMT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[1]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_SQT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[2]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_CMP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[3]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_TM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[4]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_MSP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[5]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_RCM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[6]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_MD, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[7]]);
}
