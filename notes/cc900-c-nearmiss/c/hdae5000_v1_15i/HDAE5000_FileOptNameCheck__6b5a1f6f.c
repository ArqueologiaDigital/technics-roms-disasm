/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_name_checks_hd_driver.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 6b5a1f6fc83028afce87a7a54e59662381a87f9ca9a0c913c2efcb36eb088f02 (tar-sha256); compiled at -Xr
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
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char HDAE5000_Fmt_s_FileOptNameCheck[];
long HDAE5000_FileOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    struct ParaBlk *p;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        p = arg;
        HDAE5000_SPrintf(p->str, HDAE5000_Fmt_s_FileOptNameCheck,
                         HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
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
