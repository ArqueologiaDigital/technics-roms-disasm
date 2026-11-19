/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3__svc19_r75.c (2026-11-19-64-hd-r76-staged)
   sha256 49a98baca68b34e9f12be6361afd4c7a9b3bbbdff9aacfbb28fa174db82385db (tar-sha256); compiled at -Xr
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
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[192]);
    HDAE5000_DebugTrace(ram_2e0c32);
    return PPIB + 192;
}
