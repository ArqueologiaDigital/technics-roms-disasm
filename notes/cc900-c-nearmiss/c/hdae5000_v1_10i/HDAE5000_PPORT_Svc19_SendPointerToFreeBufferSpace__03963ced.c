/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 03963cedc9dbc34f1dee373186161e8b7f858ac29fea0e4df22ac21e5815ac68 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
extern char ram_2e0bfa[], ram_2e0c32[];
extern char ram_2e0c22[];
#define F_work_adr ram_2e0c22
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2e0bfa);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[202]);
    HDAE5000_DebugTrace(ram_2e0c32);
    return PPIB + 202;
}
