/* Functions of hdae5000_hd_driver.s.  (hdae5000_sfx_bitcheck.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_sfx_bitcheck.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_BuildMask HDAE5000_PartList_Build
   cc900-data: HDAE5000_SfxLswBitCheck 1 = HDAE5000_SfxLswBitCheck_CaseTable
   cc900-data: HDAE5000_SfxPmtBitCheck 1 = HDAE5000_SfxPmtBitCheck_CaseTable
   cc900-data: HDAE5000_SfxSqtBitCheck 1 = HDAE5000_SfxSqtBitCheck_CaseTable
   cc900-data: HDAE5000_SfxCmpBitCheck 1 = HDAE5000_SfxCmpBitCheck_CaseTable
   cc900-data: HDAE5000_SfxTmBitCheck 1 = HDAE5000_SfxTmBitCheck_CaseTable
   cc900-data: HDAE5000_SfxMspBitCheck 1 = HDAE5000_SfxMspBitCheck_CaseTable
   cc900-data: HDAE5000_SfxRcmBitCheck 1 = HDAE5000_SfxRcmBitCheck_CaseTable
   cc900-data: HDAE5000_SfxMdBitCheck 1 = HDAE5000_SfxMdBitCheck_CaseTable
   cc900-data: HDAE5000_SfxTlxBitCheck 1 = HDAE5000_SfxTlxBitCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern long ram_23a0a6;                         /* no tree name; the hand source spells (0x23a0a6) */

/* ---- ROM ---- */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Fmt_s_SfxLswBitCheck[];
extern char HDAE5000_Fmt_s_SfxPmtBitCheck[];
extern char HDAE5000_Fmt_s_SfxSqtBitCheck[];
extern char HDAE5000_Fmt_s_SfxCmpBitCheck[];
extern char HDAE5000_Fmt_s_SfxTmBitCheck[];
extern char HDAE5000_Fmt_s_SfxMspBitCheck[];
extern char HDAE5000_Fmt_s_SfxRcmBitCheck[];
extern char HDAE5000_Fmt_s_SfxMdBitCheck[];
extern char HDAE5000_Fmt_s_SfxTlxBitCheck[];

long HDAE5000_SfxLswBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxLswBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxPmtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxPmtBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[1] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[1] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[1];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxSqtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxSqtBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[2] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[2] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[2];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxCmpBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxCmpBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[3] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[3] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[3];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxTmBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxTmBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[4] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[4] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[4];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxMspBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxMspBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[5] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[5] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[5];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxRcmBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxRcmBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[6] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[6] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[6];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxMdBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxMdBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[7] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[7] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[7];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SfxTlxBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    struct ParaBlk *p;
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        p = arg;
        HDAE5000_SPrintf(p->str, HDAE5000_Fmt_s_SfxTlxBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[p->value]);
        ram_23a0a6 = p->value;
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[8] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        if (ram_23a0a6 == 1) {
            ram_23a0a6 = 2;
            r = 2;
        } else {
            ram_23a0a6 = 1;
            r = 1;
        }
        if (HDAE5000_RAM_SaveOptions.flag[8] == 0)
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                (int)HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

/* variant: p and r declared in their case blocks */
