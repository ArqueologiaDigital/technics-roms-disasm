/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13b_song.c (2026-11-16-75-hd-r13b)
   sha256 7294eb7c36a63cce6a50c885b06d40e7d89d63a85af988bffc6cca6fb590cc5e (tar-sha256); compiled at -Xr
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
