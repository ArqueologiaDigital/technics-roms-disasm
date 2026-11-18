/* lane_hd round 50, helper h_chk: the load-by-number edit checks of hdae5000_filesystem.s, in ROM order:
   HDAE5000_FileLBNNameCheck and the nine LBN*BitCheck procedures (one per part kind: flag[0..8] of the save
   options, HDAE5000_RAM_SaveOptions+2..+10; the TLX one is unregistered and never runs).  Each answers the
   numeric-edit events of an object: RAM_STRING (prints "---"/NO/YES, or blank while no song is typed),
   LARGE/SMALL_STEP, MAX/MIN (0 unless a song is typed and the part exists), RAM_ADDRESS, RAM_SIZE and
   RAM_DATA_REQ (rebuild the mask and the part list of the HD FILE OPTION object).
   MAX / MIN as nested ?: -- the ROM's inner test jumps straight to the outer join, the shape of a ?: inside the
   true arm of a ?: (the inner one in V4.23's preload form: false value first, as in AttenHDFormatSwCatch).
   cc900-options: -Xr
   cc900-name: LbnTlxBitCheckUnreg=HDAE5000_LBNTlxBitCheck_Unregistered
   cc900-module: HDAE5000_TypeSel_BuildMask HDAE5000_PartList_Build
   cc900-data: HDAE5000_FileLBNNameCheck 1 = HDAE5000_FileLBNNameCheck_CaseTable
   cc900-data: HDAE5000_LBNLswBitCheck 1 = HDAE5000_LBNLswBitCheck_CaseTable
   cc900-data: HDAE5000_LBNPmtBitCheck 1 = HDAE5000_LBNPmtBitCheck_CaseTable
   cc900-data: HDAE5000_LBNSqtBitCheck 1 = HDAE5000_LBNSqtBitCheck_CaseTable
   cc900-data: HDAE5000_LBNCmpBitCheck 1 = HDAE5000_LBNCmpBitCheck_CaseTable
   cc900-data: HDAE5000_LBNTmBitCheck 1 = HDAE5000_LBNTmBitCheck_CaseTable
   cc900-data: HDAE5000_LBNMspBitCheck 1 = HDAE5000_LBNMspBitCheck_CaseTable
   cc900-data: HDAE5000_LBNRcmBitCheck 1 = HDAE5000_LBNRcmBitCheck_CaseTable
   cc900-data: HDAE5000_LBNMdBitCheck 1 = HDAE5000_LBNMdBitCheck_CaseTable
   cc900-data: HDAE5000_LBNTlxBitCheck_Unregistered 1 = HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);

/* ---- other modules (call) ---- */
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;

/* ---- ROM ---- */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Str_Blank26[];
extern char HDAE5000_Fmt_s_FileLBNNameCheck[];
extern char HDAE5000_Fmt_s_LBNLswBitCheck[];
extern char HDAE5000_Fmt_s_LBNPmtBitCheck[];
extern char HDAE5000_Fmt_s_LBNSqtBitCheck[];
extern char HDAE5000_Fmt_s_LBNCmpBitCheck[];
extern char HDAE5000_Fmt_s_LBNTmBitCheck[];
extern char HDAE5000_Fmt_s_LBNMspBitCheck[];
extern char HDAE5000_Fmt_s_LBNRcmBitCheck[];
extern char HDAE5000_Fmt_s_LBNMdBitCheck[];
extern char HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered[];

long HDAE5000_FileLBNNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_FileLBNNameCheck,
                             HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_Str_Blank26);
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
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNLswBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNLswBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNPmtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNPmtBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[1] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[1] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[1];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNSqtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNSqtBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[2] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[2] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[2];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNCmpBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNCmpBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[3] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[3] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[3];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNTmBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNTmBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[4] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[4] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[4];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNMspBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNMspBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[5] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[5] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[5];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNRcmBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNRcmBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[6] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[6] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[6];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNMdBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNMdBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[7] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[7] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[7];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long LbnTlxBitCheckUnreg(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered,
                             HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        else
            HDAE5000_StrCpy(arg->str, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[0]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[8] == 0 ? 0L : 2L) : 0L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_LbnDigitPos == 5 ? (HDAE5000_RAM_SaveOptions.flag[8] == 0 ? 0L : 1L) : 0L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}
