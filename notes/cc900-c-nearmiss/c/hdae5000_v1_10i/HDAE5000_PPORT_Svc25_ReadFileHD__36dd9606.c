/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services__svc25_r75.c (2026-11-19-64-hd-r76-staged)
   sha256 36dd96068d61f21ad514313f66f6c2a4c88c11c46a5ef8275dd347bf63521495 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc25=HDAE5000_PPORT_Svc25_ReadFileHD */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
#define PPIB HDAE5000_RAM_PportInfoBlock
extern char ram_2e0cc0[];
extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, unsigned long *slot);
extern int HDAE5000_HD_ReadFileNext(void *dst, unsigned long n, unsigned long *slot);
extern void HDAE5000_DebugTrace(char *s);
int PP_Svc25(void *dst, unsigned long n)
{
    int ret;

    ret = 1;
    HDAE5000_DebugTrace(ram_2e0cc0);
    if (HDAE5000_RAM_PportReadState == 1) {
        HDAE5000_RAM_PportReadState = 2;
        if (HDAE5000_HD_ReadFile(dst, n, *(unsigned long **)(PPIB + 4288)) != -1)
            ret = 0;
    } else if (HDAE5000_RAM_PportReadState == 2) {
        if (HDAE5000_HD_ReadFileNext(dst, n, *(unsigned long **)(PPIB + 4288)) != -1)
            ret = 0;
    } else
        HDAE5000_RAM_PportReadState = 0;
    return ret;
}
