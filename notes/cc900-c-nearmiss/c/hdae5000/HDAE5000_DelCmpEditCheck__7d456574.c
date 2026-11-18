/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_del_editcheck.c (2026-11-18-11-hd-r51-ports)
   sha256 7d456574b66943651c58f84e067d2ad557daad20dd5dcb75e3240e9bf3318097 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_LARGE_STEP 0x1e0003eL
#define EVT_GET_SMALL_STEP 0x1e0003fL
#define EVT_GET_MAX 0x1e00043L
#define EVT_GET_MIN 0x1e00044L
#define EVT_GET_RAM_ADDRESS 0x1e00045L
#define EVT_GET_RAM_SIZE 0x1e00046L
#define EVT_GET_RAM_STRING 0x1e00047L
#define EVT_RAM_DATA_REQ 0x1e00082L
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern char *HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[];
extern char HDAE5000_Fmt_s_DelCmpEditCheck[];
long HDAE5000_DelCmpEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelCmpEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[3] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[3] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[3];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}
