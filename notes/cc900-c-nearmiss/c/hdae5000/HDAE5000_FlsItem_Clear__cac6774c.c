/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2_sb.c (2026-11-16-46-hd-r2)
   sha256 cac6774cc4d1b923dc939802f62b72b29ae9ec47c31e6034812529149a34a791 (tar-sha256); compiled at -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLS_COL(c, f, i) (*(HDAE5000_RAM_FlsRecords + (16 + 32 * (c)) + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    FLS_COL(0, fls, item) = 0;
    FLS_COL(1, fls, item) = 0;
    FLS_COL(2, fls, item) = 0;
    FLS_COL(3, fls, item) = 0;
    return 0;
}
