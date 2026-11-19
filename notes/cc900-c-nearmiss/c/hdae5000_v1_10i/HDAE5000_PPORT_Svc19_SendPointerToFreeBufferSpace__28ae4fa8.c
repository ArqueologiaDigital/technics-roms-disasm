/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hd_r71m_pport_services3__svc19.c (2026-11-19-59-hd-r71-v1misc)
   sha256 28ae4fa8f5e026ff1c79fc870d7f4bb54e1e00d07954da86992ec02fbe7bdc18 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
extern char ram_2e0d8a[], ram_2e0dc2[];
extern char ram_2e0db2[];
#define F_work_adr ram_2e0db2
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2e0d8a);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[192]);
    HDAE5000_DebugTrace(ram_2e0dc2);
    return PPIB + 192;
}
