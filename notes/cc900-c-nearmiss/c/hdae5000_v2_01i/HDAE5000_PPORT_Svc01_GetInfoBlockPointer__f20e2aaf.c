/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_pport_svc2.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 f20e2aaf8e26d9a7427909f5a5c99f1dcfb2002cb2365e8473f65bfdaf0db0de (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc01=HDAE5000_PPORT_Svc01_GetInfoBlockPointer */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern char ram_2f8f5e[], ram_2f8f8c[];
extern char ram_2f8f7c[];
#define F_ppib_adr ram_2f8f7c
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void HDAE5000_DebugTrace(char *s);
unsigned char *PP_Svc01(void)
{
    char buf[32];

    HDAE5000_DebugTrace(ram_2f8f5e);
    HDAE5000_SPrintf(buf, F_ppib_adr, (unsigned long)HDAE5000_RAM_PportInfoBlock);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f8f8c);
    return HDAE5000_RAM_PportInfoBlock;
}
