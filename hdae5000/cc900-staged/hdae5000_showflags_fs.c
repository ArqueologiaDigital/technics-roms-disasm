/* FdList_Redisplay and DelOpt_ShowFlags of hdae5000_filesystem.s
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r50_show_fs.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
/* +0 title text (14), +14 the 20 rows of 12, +0x100 present flags, +0x114 selected flags */
extern unsigned char HDAE5000_RAM_FdList[];
/* "---", "OFF", "DEL" (35 characters: unique in its first 31) */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[];

void HDAE5000_FdList_Redisplay(void)
{
    unsigned int i;

    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_FdList);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    for (i = 0; i < 20; i++) {
        HDAE5000_RAM_FdList[(unsigned long)(i * 12 + 10) + 14] = ' ';
        if (HDAE5000_RAM_FdList[(unsigned long)i + 0x114] == 1)
            HDAE5000_RAM_FdList[(unsigned long)(i * 12 + 10) + 14] = '*';
    }
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, (long)&HDAE5000_RAM_FdList[14]);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
}

void HDAE5000_DelOpt_ShowFlags(void)
{
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_LSW, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[0]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_PMT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[1]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_SQT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[2]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_CMP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[3]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_TM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[4]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_MSP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[5]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_RCM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[6]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_MD, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[7]]);
    CALLV(ROOT->PostEvent)(OBJ_DEL_EDIT_TLX, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[HDAE5000_RAM_DeleteOptions.flag[8]]);
}
