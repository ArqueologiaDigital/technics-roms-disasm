/* lane_hd round 54, helper h_lyb: hd_r50_fload.c with the table's eight holes (0x01EA0003..7, 9..B) written as
   empty cases beside SW_IN.  Run 2026-11-18-13-hd-r52: every body matched, but with only the six real 0x01EA000n
   cases V4.23 wrote a compare chain on XBC instead of `ld xwa,xbc; sub; table` (6 of 14 is too sparse; LyricBox's
   6 of 7 and Lbn_StepDigit's 6 of 6 got tables): the holes make the range dense.
   r50's notes follow.
   lane_hd round 50, helper h_lyb: HDAE5000_FILE_LOAD_Screen (hdae5000_hd_driver.s, 0x283da0, with its arms
   _Ev01C00001 .. _Default; the screen procedure of the HD song list: SHOW, the list's soft buttons and over / under
   flow).  No earlier C.
   cc900-options: -Xr
   cc900-data: HDAE5000_FILE_LOAD_Screen 1 = HDAE5000_FILE_LOAD_Screen_CaseTable
   cc900-module: HDAE5000_TypeSel_Init HDAE5000_DelOpt_InitFromSong HDAE5000_SongScreen_Refresh
   Shape: arg lives in XIZ (pushed, no frame), as SEL_DIR_Screen's.  Source order SHOW, 8, D, C, 1, 0, 2, SW_IN:
   the compare chain tests SW_IN then SHOW (reverse source order), the six 0x01EA000n cases are the 14-entry table.
   SW_IN goes straight to the end, so it is an empty case after CHANGE_SEL_NUM, whose body falls into it (the ROM
   has no jump between them).  UNDER / OVER_FLOW jump straight to the end when the directory is at its limit:
   written as an early break (an `if (..) { .. }` would jump to the case's own closing break).  The part-mask test
   is drv_screens3's matched `(m = Song_PartMask(..)) != 0xffff` (ROM ld wa,hl; cp wa,0xffff; m stays in HL). */
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
    case EVT_HDAE_SELECT_ALL:
    case EVT_HDAE_SET_STR_ADR:
    case 0x01ea000bL:
    case EVT_SW_IN:
        ;
    }
    return 0;
}
