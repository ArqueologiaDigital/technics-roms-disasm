/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 1945b4284c5b3d14a25d4ea91b610a8cbe68d48a535930762493d2e9becad956 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc04=HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock */
struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2f900c[], ram_2f9058[];
extern char ram_2f902e[];
#define F_FGB_ptr ram_2f902e
extern char ram_2f903c[];
#define F_FGB_wid ram_2f903c
extern char ram_2f904a[];
#define F_FGB_num ram_2f904a
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi);
void PP_Svc04(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(0, (void *)&bi);
    PP_L(44) = (unsigned long)bi.base;
    PP_W(48) = bi.size;
    PP_W(50) = bi.count;
    HDAE5000_DebugTrace(ram_2f900c);
    HDAE5000_SPrintf(buf, F_FGB_ptr, PP_L(44));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_wid, PP_W(48));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_num, PP_W(50));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9058);
}
