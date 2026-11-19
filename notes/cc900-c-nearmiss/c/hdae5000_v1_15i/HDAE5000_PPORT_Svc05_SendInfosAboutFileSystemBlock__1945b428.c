/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_pport_services3.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 1945b4284c5b3d14a25d4ea91b610a8cbe68d48a535930762493d2e9becad956 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc05=HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock */
struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2f905a[], ram_2f90ac[];
extern char ram_2f9082[];
#define F_FEB_ptr ram_2f9082
extern char ram_2f9090[];
#define F_FEB_wid ram_2f9090
extern char ram_2f909e[];
#define F_FEB_num ram_2f909e
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi);
void PP_Svc05(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(1, (void *)&bi);
    PP_L(52) = (unsigned long)bi.base;
    PP_W(56) = bi.size;
    PP_W(58) = bi.count;
    HDAE5000_DebugTrace(ram_2f905a);
    HDAE5000_SPrintf(buf, F_FEB_ptr, PP_L(52));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_wid, PP_W(56));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_num, PP_W(58));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f90ac);
}
