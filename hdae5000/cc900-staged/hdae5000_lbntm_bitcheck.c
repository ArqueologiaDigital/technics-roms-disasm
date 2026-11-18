/* LBNTmBitCheck of hdae5000_filesystem.s
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r52_chk_lbn.c.
   cc900-options: -Xr
   cc900-name: LbnTm_b=HDAE5000_LBNTmBitCheck
   cc900-module: HDAE5000_TypeSel_BuildMask HDAE5000_PartList_Build
   cc900-data: HDAE5000_LBNTmBitCheck 1 = HDAE5000_LBNTmBitCheck_CaseTable
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

/* variant: statement form, local r */
long LbnTm_b(long obj, long ev, struct ParaBlk *arg)
{
    long r;

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
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 2;
            if (HDAE5000_RAM_SaveOptions.flag[4] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_MIN:
        if (HDAE5000_RAM_LbnDigitPos == 5) {
            r = 1;
            if (HDAE5000_RAM_SaveOptions.flag[4] == 0)
                r = 0;
        } else
            r = 0;
        return r;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[4];
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
