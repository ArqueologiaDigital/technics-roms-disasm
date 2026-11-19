/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_sfx_bitcheck.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 ce486c0d6171bb88606d90d4fa3b30b73040d311a88d126026c5db3c2ba4a92f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_LARGE_STEP 0x1e0003eL
#define EVT_GET_SMALL_STEP 0x1e0003fL
#define EVT_GET_MAX 0x1e00043L
#define EVT_GET_MIN 0x1e00044L
#define EVT_GET_RAM_ADDRESS 0x1e00045L
#define EVT_GET_RAM_SIZE 0x1e00046L
#define EVT_GET_RAM_STRING 0x1e00047L
#define EVT_RAM_DATA_REQ 0x1e00082L
#define OBJ_HD_FILE_OPTION 0x7f0104L
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Fmt_s_SfxTmBitCheck[];
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
