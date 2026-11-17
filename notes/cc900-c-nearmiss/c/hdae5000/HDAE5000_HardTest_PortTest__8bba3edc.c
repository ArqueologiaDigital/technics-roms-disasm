/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_hardtest_port.c (2026-11-16-116-hd-r27c)
   sha256 8bba3edcffbd6ecadc5b57390e769a5d3826d4507db5edbbaf061414fec8708b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char HDAE5000_PPI_LoopbackByte(int b);
extern void HDAE5000_HardTest_Print(char *line);
extern void HDAE5000_PPI_Init(void);
extern char HDAE5000_Str_PortTestOK[];
extern char HDAE5000_Str_PortTestError[];
void HDAE5000_HardTest_PortTest(void)
{
    int i;
    int err;

    err = 0;
    HDAE5000_PPI_Init();
    for (i = 0; i < 0x100; i++)
        err |= HDAE5000_PPI_LoopbackByte((unsigned char)i);
    if (err == 0)
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestOK);
    else
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestError);
}
