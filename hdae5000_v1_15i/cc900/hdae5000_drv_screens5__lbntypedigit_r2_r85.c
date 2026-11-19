/* Functions of hdae5000_hd_driver.s.  (hdae5000_drv_screens5__lbntypedigit_r2_r85.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_drv_screens5__lbntypedigit_r2_r85.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: TypeDigit_a=HDAE5000_Lbn_TypeDigit
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_DelOpt_InitFromSong HDAE5000_NameHistory_Recall
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_TypeSel_Init HDAE5000_TypeSel_ShowSaveFlags
   cc900-module: HDAE5000_SaveSongWithUi HDAE5000_LoadSongWithUi HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_HardTest_Print HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };

/* ---- this module (calr) ---- */
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;

/* ---- ROM ---- */
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

/* r in QIZ, m in IZ in the ROM.
   r23 (run 95 departed at +249): r and m assigned in their conditions (`ld wa,qiz; cp wa,0`, `ld wa,iz;
   cp wa,0xffff`); m is int: the ROM loads it early for TypeSel_Init (`ld bc,iz` before `pushw 2`) and copies it
   for PartList_Build's push (`ld wa,iz; push wa`), the order of an int converted to the unsigned mask parameter
   (r20's unsigned m was loaded late and pushed as `push iz`); LoadSongWithUi / SetApTimer stacked arguments
   reversed. */
void TypeDigit_a(long obj, unsigned int digit)
{
    int r;      /* r2 form a: r declared FIRST, m last (r82: the v2.06i order gave r IZ in v1.x) */
    int m;

    r = 0;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        HDAE5000_RAM_LbnDir = digit * 100;
        HDAE5000_RAM_LbnSong = 0;
        HDAE5000_RAM_LbnDigitPos = 1;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 1:
        HDAE5000_RAM_LbnDir += digit * 10;
        HDAE5000_RAM_LbnDigitPos = 2;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 2:
        HDAE5000_RAM_LbnDir += digit;
        HDAE5000_RAM_LbnDigitPos = 3;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 3:
        HDAE5000_RAM_LbnSong = digit * 10;
        HDAE5000_RAM_LbnDigitPos = 4;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 4:
        HDAE5000_RAM_LbnSong += digit;
        HDAE5000_RAM_LbnDigitPos = 5;
        if ((r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1))
                == 0) {
            HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
            HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
            } else {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, 0xffff, 0xffff, 0xffff);
            }
            if (HDAE5000_RAM_LoadByNumberMode == 2) {
                HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        1, OBJ_LOAD_BY_NUM);
                HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
            }
        }
    }
    switch (r) {
    case -1:
        CALLV(ROOT->PostEvent)(OBJ_DIR_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_DIR_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
        break;
    case -2:
        CALLV(ROOT->PostEvent)(OBJ_FILE_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_FILE_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
    }
}
