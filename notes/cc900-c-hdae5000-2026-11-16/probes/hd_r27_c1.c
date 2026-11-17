/* lane_hd round 27, helper h_r27c, file 1: functions of the big screen module (hdae5000_hd_driver.s /
   hdae5000_filesystem.s / hdae5000_ui_display.s) that no probe had tried, in ROM address order:
   HDAE5000_HDDTitleSwCatch, HDAE5000_FileLoadSwCatch, HDAE5000_SaveOptNameCheck, HDAE5000_Lbn_StepDigit (whole:
   the survey's pieces _NoDigitTyped .. _SongUnits), HDAE5000_LBNPage1SwCatch (whole: _OnClear .. _OnDigit8Or9),
   HDAE5000_ErrMsgTimerCatchLBN.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Scan HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_BuildMask
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   Reading of the hand source:
   - HDDTitleSwCatch / FileLoadSwCatch test the event with `cp xbc,imm` (no copy to XWA): an `if`, not a switch;
     the edit-switch number is switched on straight from the call (`cp xhl,..`), as the matched LBNLoadSwCatch.
   - SaveOptNameCheck: the shape of hd_r4_g3.c's *Check procedures, whose code V4.23 gave as the ROM's (run 59)
     except for the stacked format; the format and the name buffer are char arrays passed with no conversion
     (the matched TitleInfo_Build: pushw hi16 / pushw lo16).
   - Lbn_StepDigit: the switch is on the global HDAE5000_RAM_LbnDigitPos (unsigned: `cp wa,5; jrl ugt`); the
     third parameter (DE) is never read: the ROM overwrites DE with the first (`ld de,wa`).  m is int and assigned
     in its condition, as r23's LBNLoadSwCatch notes say (`ld bc,iz` before `pushw 2`; `ld wa,iz; pushw wa`).
   - LBNPage1SwCatch: the edit-switch number compared unsigned (`cp xwa,12; jrl ugt`); case bodies in ROM order:
     12 (CLEAR), 5-7 (step), 0, 1, 2, 3, 4 (digits).
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_FdList_Scan(void);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_Lbn_TypeDigit(long obj, int digit);
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned char HDAE5000_RAM_WriteProtect;
extern char ram_23a04e[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */

/* ---- ROM ---- */
extern char HDAE5000_Fmt_s_SaveOptNameCheck[];
extern char HDAE5000_Str_LBNS[];
extern char HDAE5000_Str_TLBN[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

long HDAE5000_HDDTitleSwCatch(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0x8a:
            if (HDAE5000_RAM_WriteProtect == 0)
                HDAE5000_FdList_Scan();
            else
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CPHD_WR, EVT_SHOW, 0L);
            break;
        case 0x0a:
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 0);
        }
    }
    return 0;
}

long HDAE5000_FileLoadSwCatch(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 8:
        case 9:
            HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                    0, OBJ_SELECT_FILE);
            if (HDAE5000_RAM_LyricJump == 2 && (HDAE5000_RAM_SaveOptions.mask & 0x100) == 0x100)
                CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
        }
    }
    return 0;
}

long HDAE5000_SaveOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SaveOptNameCheck, ram_23a04e);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 0;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[9];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        return 0;
    default:
        return 0;
    }
}

void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step)
{
    int m;

    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        return;
    case 1:
        dir += step * 100;
        if (dir >= 100)
            dir = 100;
        else if (dir <= 0)
            dir = 0;
        break;
    case 2:
        dir += step * 10;
        if (dir >= 120)
            dir = 120;
        else if (dir <= 1)
            dir = 0;
        break;
    case 3:
        dir += step;
        if (dir > 120)
            dir = 120;
        else if (dir <= 0)
            dir = 1;
        break;
    case 4:
        song += step * 10;
        if (song >= 10)
            song = 10;
        else if (song <= 0)
            song = 0;
        break;
    case 5:
        song += step;
        if (song > 16)
            song = 16;
        else if (song <= 0)
            song = 1;
    }
    HDAE5000_RAM_LbnDir = dir;
    HDAE5000_RAM_LbnSong = song;
    if (HDAE5000_RAM_LbnDigitPos == 5) {
        HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
        HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
        } else {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, -1, -1, 0xffff);
        }
    }
    HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
}

long HDAE5000_LBNPage1SwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_LBNS);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 12:
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
            break;
        case 5:
        case 6:
        case 7:
            HDAE5000_Lbn_StepDigit(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos,
                                   (arg & 0x80) == 0 ? 1 : -1);
            break;
        case 0:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 0);
            else
                HDAE5000_Lbn_TypeDigit(obj, 1);
            break;
        case 1:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 2);
            else
                HDAE5000_Lbn_TypeDigit(obj, 3);
            break;
        case 2:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 4);
            else
                HDAE5000_Lbn_TypeDigit(obj, 5);
            break;
        case 3:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 6);
            else
                HDAE5000_Lbn_TypeDigit(obj, 7);
            break;
        case 4:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 8);
            else
                HDAE5000_Lbn_TypeDigit(obj, 9);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long HDAE5000_ErrMsgTimerCatchLBN(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_TLBN);
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(arg, EVT_SHOW, 0L);
        HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
        return 0;
    }
}
