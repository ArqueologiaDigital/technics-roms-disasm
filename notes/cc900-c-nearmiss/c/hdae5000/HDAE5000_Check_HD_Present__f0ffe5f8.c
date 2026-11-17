/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1b.c (2026-11-16-44-hd-r1)
   sha256 f0ffe5f8f88030190806f17337dda0ecbdcfedf242b4b2ef171faac50dbb205b (tar-sha256); compiled at -O3 -Xr */
extern unsigned char HDAE5000_RAM_HdInitResult;
extern void HDAE5000_HD_Init(void);
int HDAE5000_Check_HD_Present(void)
{
    HDAE5000_RAM_HdInitResult = 0;
    HDAE5000_HD_Init();
    return (int)HDAE5000_RAM_HdInitResult;
}
