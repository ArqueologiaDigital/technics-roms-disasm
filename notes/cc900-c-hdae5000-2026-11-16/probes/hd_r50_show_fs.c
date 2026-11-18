/* lane_hd round 50, helper h_lyb: two leaf-like display routines of hdae5000_filesystem.s, no calr of their own:
   HDAE5000_FdList_Redisplay (0x289665, 284 B) and HDAE5000_DelOpt_ShowFlags (0x28a2f0, 423 B).  No earlier C defined them.
   cc900-options: -Xr
   Both end in `jp (xhl)`: a void function whose last statement is a call through a pointer, as the matched
   HardTest_Print (hdae5000_hardtest_print.c), which V4.23 -Xr ends with that tail jump.
   FdList_Redisplay: the list as a flat byte array, its row texts at +14, 12 bytes a row with the mark at +10, and the
   selected flags at +0x114: the ROM computes (i * 12 + 10) in 16 bits, widens it (extz xwa) and adds the member
   offset in 32 bits with the array address as an immediate (ld xbc,FdList; add xbc,xwa), the CopyToHd_Execute
   idiom [(unsigned long)i + OFFSET].  The text addresses passed through XWA (lda xwa,(..); ld xde,xwa): (long).
   DelOpt_ShowFlags: the flag byte widened and scaled (extz wa; sla wa,2) to index the pointer table, loaded into
   XDE before the function pointer (a non-constant argument first). */
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
