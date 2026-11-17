/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1a.c (2026-11-16-44-hd-r1)
   sha256 3d6106c93617b98bcac5898cac04887249bee17a21630bc45a65c43a896e7307 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char HDAE5000_RAM_HdInitResult;
extern void HDAE5000_HD_Init(void);
int HDAE5000_Check_HD_Present(void)
{
    HDAE5000_RAM_HdInitResult = 0;
    HDAE5000_HD_Init();
    return HDAE5000_RAM_HdInitResult;
}
