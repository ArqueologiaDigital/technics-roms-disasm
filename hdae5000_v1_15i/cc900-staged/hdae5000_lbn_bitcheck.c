/* hdae5000_v1_15i: the functions of hdae5000/cc900/hdae5000_lbn_bitcheck.c that V4.23 reproduces in HD-AE5000 v1.15i with the tree's own object ids (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_lbn_bitcheck.c.
   cc900-options: -Xr
*/
/* lane_hd round 52, helper h_chk: second try at the nine LBN*BitCheck procedures (hd_r50_chk_lbn.c, run
   2026-11-18-7-hd-r51).  Two changes, both from what V4.23 made of round 50:
   - MAX / MIN: V4.23 preloads a CONSTANT false arm of ?: (ld xhl,0 before the test), the ROM tests first.  The
     false arm is now the comma expression (0, 0L), not a constant, so the outer ?: takes the general form (test,
     true arm, jump, false arm); the inner ?: keeps the preload form and jumps to the outer's end, as V4.23 did with
     nested ?: in run 51.
   - RAM_DATA_REQ: V4.23 pushed the mask straight from memory (pushw (mem)); the ROM loads it into WA and pushes WA.
     The mask is now passed through an (int) cast, a conversion.
   Variants of LBNTmBitCheck: LbnTm_b = statement form (local r, hoping for XHL and jump-to-jump threading),
   mask cast as above; hd_r52_chk_maskb.c tries other mask forms on SfxLswBitCheck.
   cc900-options: -Xr
   cc900-name: LbnTlxBitCheckUnreg=HDAE5000_LBNTlxBitCheck_Unregistered
   cc900-module: HDAE5000_TypeSel_BuildMask HDAE5000_PartList_Build
   cc900-data: HDAE5000_LBNLswBitCheck 1 = HDAE5000_LBNLswBitCheck_CaseTable
   cc900-data: HDAE5000_LBNPmtBitCheck 1 = HDAE5000_LBNPmtBitCheck_CaseTable
   cc900-data: HDAE5000_LBNSqtBitCheck 1 = HDAE5000_LBNSqtBitCheck_CaseTable
   cc900-data: HDAE5000_LBNCmpBitCheck 1 = HDAE5000_LBNCmpBitCheck_CaseTable
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

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;

/* ---- ROM ---- */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Fmt_s_LBNLswBitCheck[];
extern char HDAE5000_Fmt_s_LBNPmtBitCheck[];
extern char HDAE5000_Fmt_s_LBNSqtBitCheck[];
extern char HDAE5000_Fmt_s_LBNCmpBitCheck[];
extern char HDAE5000_Fmt_s_LBNTmBitCheck[];
extern char HDAE5000_Fmt_s_LBNMspBitCheck[];
extern char HDAE5000_Fmt_s_LBNRcmBitCheck[];
extern char HDAE5000_Fmt_s_LBNMdBitCheck[];
extern char HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered[];

long HDAE5000_LBNLswBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[0] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[0] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNPmtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[1] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[1] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[1];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNSqtBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[2] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[2] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[2];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNCmpBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[3] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[3] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[3];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNMspBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[5] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[5] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[5];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNRcmBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[6] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[6] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[6];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_LBNMdBitCheck(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[7] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[7] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[7];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                    (int)HDAE5000_RAM_SaveOptions.mask);
        } else
            HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, 0xffff, 0xffff, 0xffff);
        return 0;
    default:
        return 0;
    }
}

/* variant: statement form, local r */
