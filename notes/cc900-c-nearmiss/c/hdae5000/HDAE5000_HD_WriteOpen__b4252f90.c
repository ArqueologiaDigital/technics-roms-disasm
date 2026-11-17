/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13b_songb.c (2026-11-16-75-hd-r13b)
   sha256 b4252f902ad21efc35fa63b27fd852bacb6d14b8afd4fbd253e89f3b5e8503f4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
int HDAE5000_HD_WriteOpen(long *slot)
{
    if (HDAE5000_RAM_HdStreamState != 0) {
        HDAE5000_RAM_HdStreamState = 0;
        return -1;
    }
    HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
    HDAE5000_RAM_HdStreamSlot = slot;
    HDAE5000_RAM_HdStreamState = 1;
    return 0;
}
