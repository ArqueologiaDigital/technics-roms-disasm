/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_edit_checks.c (2026-11-18-10-hd-r51-staged)
   sha256 2cf84895bd98263712343a824b653830ef0783b6108ffe6ab8489a1f33217fdc (tar-sha256); compiled at -Xr
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
struct ParaBlk { unsigned char pad[14]; long value; char *str; };
extern unsigned char HDAE5000_RAM_LyricBackColor;
extern char *ram_2e2ad0[];
extern char HDAE5000_Fmt_s_LyricBackColorCheck[];
long HDAE5000_LyricBackColorCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_LyricBackColorCheck, ram_2e2ad0[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 4;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_LyricBackColor;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}
