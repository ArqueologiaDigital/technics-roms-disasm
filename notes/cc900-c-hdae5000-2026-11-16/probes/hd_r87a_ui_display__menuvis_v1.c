/* Functions of hdae5000_ui_display.s.  (hdae5000_ui_display.c, v1.x)
   Firmware C (cc900 phase 6) for HD-AE5000 v1.15i / v1.10i, round 87 (2026-11-20).
   cc900-options: -Xr
   v1.x hides objects 0x7f00d0 / 0x7f00d2 in the seventh and eighth calls: OBJ_COPY_HD_SW_TO / OBJ_COPY_HD_SW_SELECT
   in v1.x's own header, where v2.06i hides OBJ_CP_FD_HDSWTO / OBJ_CP_FD_HDSWSEL (0x7f00da / 0x7f00dc in v1.x).
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
