/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_pport_services3.c (2026-11-16-117-hd-r29-staged)
   sha256 d02261e790403f69cc316f78d7152dcfd5ed756f754a464df3598d1d7ee5dd48 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc06=HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock */
struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2f90ae[], ram_2f9108[];
extern char ram_2f90d0[];
#define F_FLS_ptr ram_2f90d0
extern char ram_2f90de[];
#define F_FLS_wid ram_2f90de
extern char ram_2f90ec[];
#define F_FLS_num ram_2f90ec
extern char ram_2f90fa[];
#define F_FLS_ent ram_2f90fa
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi);
void PP_Svc06(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(2, (void *)&bi);
    PP_L(60) = (unsigned long)bi.base;
    PP_W(64) = bi.size;
    PP_W(66) = bi.count;
    PP_W(68) = bi.extra;
    HDAE5000_DebugTrace(ram_2f90ae);
    HDAE5000_SPrintf(buf, F_FLS_ptr, PP_L(60));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_wid, PP_W(64));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_num, PP_W(66));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_ent, PP_W(68));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9108);
}
