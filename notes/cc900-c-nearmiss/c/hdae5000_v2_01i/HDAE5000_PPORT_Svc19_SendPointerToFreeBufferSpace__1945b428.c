/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_pport_services3.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 1945b4284c5b3d14a25d4ea91b610a8cbe68d48a535930762493d2e9becad956 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
extern char ram_2f9286[], ram_2f92be[];
extern char ram_2f92ae[];
#define F_work_adr ram_2f92ae
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2f9286);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[202]);
    HDAE5000_DebugTrace(ram_2f92be);
    return PPIB + 202;
}
