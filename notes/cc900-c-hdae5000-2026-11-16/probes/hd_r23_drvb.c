/* hd_r23_drvb.c (helper h_nm3a, lane_hd round 23), form b: alternatives to hd_r23_drv.c (same names) for three of
   its functions, ROM address order.  Declarations as in form a.  Options: -Xr.
   - HDAE5000_FdList_Scan: the FdList accesses whose index is unsigned through pointer arithmetic,
     *(member + index), instead of form a's unsigned long subscript.  Both aim at the ROM's 32-bit form
     (`extz xwa; add xwa,0x114; ld xbc,FdList; add xbc,xwa; cp (xbc),1`), where V4.23 wrote
     `extz xwa; add wa,0x114; lda xbc,(FdList); cp (xbc+wa),1` for a plain unsigned subscript (run 95).
   - HDAE5000_AttenHDFormatSwCatch: the digit as the ternary of r20, with arg `register` (in case the byte select
     V4.23 wrote in run 95 came from reading arg from its stack slot).
   - HDAE5000_Lbn_TypeDigit: m (int) assigned in a statement of its own, then compared: tests whether the int ->
     unsigned conversion of the compare alone gives the ROM's `ld wa,iz; cp wa,0xffff`.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_TypeSel_Init HDAE5000_LoadSongWithUi
   cc900-module: HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);
extern void HDAE5000_SongScreen_Refresh(int page, int skip);   /* the callers load WA, BC (see form a) */
extern void HDAE5000_FlsScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);
extern int HDAE5000_FormatDialog_CodeDigit(int digit);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern int HDAE5000_HD_FormatDrive(int ui);
extern int HDAE5000_HD_StoreSettings(int keep);

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned char ram_22ad9c[];               /* format-code dialog: count, pad, HDAE5000_RAM_FormatCodeDigits */

extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_FMT[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

struct FindBlk { char head[6]; char name[260]; };

int HDAE5000_FdList_Scan(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    unsigned int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                HDAE5000_RAM_FdList.line1[(int)n] = 1;
                HDAE5000_MemCopy((void *)((int)n * 12 + (unsigned long)&HDAE5000_RAM_FdList.rows[3]),
                                 &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    HDAE5000_RAM_FdList.line1[(int)n] = 1;
                    HDAE5000_MemCopy((void *)((int)n * 12 + (unsigned long)&HDAE5000_RAM_FdList.rows[3]),
                                     &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            *(HDAE5000_RAM_FdList.rows + (i * 12 + 10)) = ' ';
            if (*(HDAE5000_RAM_FdList.line2 + i) == 1)
                *(HDAE5000_RAM_FdList.rows + (i * 12 + 10)) = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

long HDAE5000_AttenHDFormatSwCatch(long obj, long ev, register long arg)
{
    int res;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_FMT);
        return 0;
    case EVT_SW_IN:
        res = 0;
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            res = HDAE5000_FormatDialog_CodeDigit((arg & 0x80) ? 0 : 1);
            break;
        case 1:
            res = HDAE5000_FormatDialog_CodeDigit((arg & 0x80) ? 2 : 3);
            break;
        case 2:
            res = HDAE5000_FormatDialog_CodeDigit((arg & 0x80) ? 4 : 5);
            break;
        case 3:
            res = HDAE5000_FormatDialog_CodeDigit((arg & 0x80) ? 6 : 7);
            break;
        case 4:
            res = HDAE5000_FormatDialog_CodeDigit((arg & 0x80) ? 8 : 9);
            break;
        case 6:
        case 7:
            HDAE5000_MemFill(ram_22ad9c, 0, 10);
            CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
        }
        switch (res) {
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_AGAIN_HD_FORMAT, EVT_SHOW, 3L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            break;
        case 2:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_HD_FORMAT, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_FormatDrive(1) == 0) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
                HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
                HDAE5000_SongScreen_Refresh(0, 0);
                HDAE5000_FlsList_BuildPage();
                HDAE5000_FlsScreen_Refresh(0, 2);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_HD_FORMAT, EVT_SHOW, 3L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        case 3:
            HDAE5000_RAM_QuickLoadMode = 1;
            HDAE5000_RAM_LoadByNumberMode = 1;
            HDAE5000_RAM_JumpAfterLoad = 1;
            CALLV(ROOT->SendEvent)(OBJ_WAIT_TR0_RECOVER, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_StoreSettings(0) != -1) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 3L);
                HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        }
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(OBJ_ATTEN_HD_FORMAT, EVT_SHOW, 0L);
        return 0;
    }
}

void HDAE5000_Lbn_TypeDigit(long obj, unsigned int digit)
{
    int r;
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
            m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong);
            if (m != 0xffff) {
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
                if (HDAE5000_RAM_LyricJump == 2 && (HDAE5000_RAM_SaveOptions.mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
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
