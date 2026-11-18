/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_lbn_bitcheck.c (2026-11-18-17-hd-r54-staged)
   sha256 3cc050220afd12bd589e14259d2e4d5ea06ac8a6c0a149fa5d594d7edab7b044 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_LARGE_STEP 0x1e0003eL
#define EVT_GET_SMALL_STEP 0x1e0003fL
#define EVT_GET_MAX 0x1e00043L
#define EVT_GET_MIN 0x1e00044L
#define EVT_GET_RAM_ADDRESS 0x1e00045L
#define EVT_GET_RAM_SIZE 0x1e00046L
#define EVT_GET_RAM_STRING 0x1e00047L
#define EVT_RAM_DATA_REQ 0x1e00082L
#define OBJ_HD_FILE_OPTION 0x7f0102L
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Fmt_s_LBNPmtBitCheck[];
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
