/* lane_hd round 50, helper h_lyb: HDAE5000_TypeSel_ShowSaveFlags (hdae5000_hd_driver.s, 423 B), no calr of its own;
   the twin of DelOpt_ShowFlags (hd_r50_show_fs.c) on the save options.  No earlier C defined it.
   cc900-options: -Xr
   Ends in `jp (xhl)`: a void function whose last statement is a call through a pointer (HardTest_Print's tail
   jump).  Each flag byte widened and scaled (extz wa; sla wa,2) indexes the pointer table and is loaded into XDE
   before the function pointer. */
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
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_TLX, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[8]]);
}
