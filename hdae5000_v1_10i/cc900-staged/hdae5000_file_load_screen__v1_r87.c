/* hdae5000_v1_10i: v1.x per-tree C, round 87 (2026-11-20), run 2026-11-20-1-hd-r87-v1gap
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r87a_file_load_screen__v1.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_Init HDAE5000_DelOpt_InitFromSong HDAE5000_SongScreen_Refresh
   cc900-data: HDAE5000_FILE_LOAD_Screen 1 = HDAE5000_FILE_LOAD_Screen_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define APFUNC_HDDNamingCheck 0x012a0001L       /* NAKA_APFUNC_HDDNamingCheck (hdae5000_ui_tree.s) */

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

/* this module (calr) */
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all);
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
/* other modules (call) */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

long HDAE5000_FILE_LOAD_Screen(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
        HDAE5000_RAM_CurSong = arg;
        CALLV(ROOT->ApFuncCall)(APFUNC_HDDNamingCheck, EVT_SET_STRING,
                                HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_FILE_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_DEL_FILE:
        HDAE5000_RAM_CurSong = arg;
        HDAE5000_DelOpt_InitFromSong(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_FILE_DEL_SCREEN, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_DEL:
        CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_DIR, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_CurDir == 0)
            break;
        HDAE5000_RAM_CurDir--;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_SET_SEL_NUM, arg + 16);
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_CurDir >= 119)
            break;
        HDAE5000_RAM_CurDir++;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_SET_SEL_NUM, arg - 16);
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurSong = arg;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
        HDAE5000_SongScreen_Refresh(0, 1);
    case EVT_HDAE_SET_SEL_NUM:
    case EVT_HDAE_REQ_SEL_NUM:
    case EVT_HDAE_ACK_SEL_NUM:
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
    case EVT_HDAE_SET_STR_ADR:
    case 0x01ea000aL:
    case EVT_SW_IN:
        ;
    }
    return 0;
}
