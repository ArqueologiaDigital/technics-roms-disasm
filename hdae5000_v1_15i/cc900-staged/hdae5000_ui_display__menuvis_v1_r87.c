/* hdae5000_v1_15i: v1.x per-tree C, round 87 (2026-11-20), run 2026-11-20-1-hd-r87-v1gap
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r87a_ui_display__menuvis_v1.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    if (hide == 0)
        v = 1;
    else
        v = 0;
    CALLV(ROOT->SetVisible)(OBJ_SELECT_DIR_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DEL, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_SELECT_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    CALLV(ROOT->SetVisible)(OBJ_COPY_HD_SW_TO, v);
    CALLV(ROOT->SetVisible)(OBJ_COPY_HD_SW_SELECT, v);
    CALLV(ROOT->SetVisible)(OBJ_SW_HD_FORMAT, v);
}
