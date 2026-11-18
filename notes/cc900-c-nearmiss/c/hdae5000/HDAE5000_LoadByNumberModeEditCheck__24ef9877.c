/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_edit_checks.c (2026-11-18-11-hd-r51-ports)
   sha256 24ef9877ae2c74d4fdcd8bc2907c397932c5f0be898a4bb20d18e5e41aa9289b (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: LoadByNumEditCheck=HDAE5000_LoadByNumberModeEditCheck */
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
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern char HDAE5000_Fmt_1d_LoadByNumberModeEditCheck[];
long LoadByNumEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LoadByNumberModeEditCheck, arg->value);
        return obj;
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 2;
    case EVT_GET_MIN:
        return 1;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_LoadByNumberMode;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}
