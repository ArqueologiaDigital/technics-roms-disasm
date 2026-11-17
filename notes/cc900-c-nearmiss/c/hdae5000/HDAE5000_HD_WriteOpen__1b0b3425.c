/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_song.c (2026-11-16-119-hd-r30)
   sha256 1b0b3425565dbcd8f801136a0c450ece38c98939f682467189952383017fc424 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
int HDAE5000_HD_WriteOpen(long *slot)
{
    int ret;

    if (HDAE5000_RAM_HdStreamState != 0) {
        HDAE5000_RAM_HdStreamState = 0;
        ret = -1;
    } else {
        HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        HDAE5000_RAM_HdStreamSlot = slot;
        HDAE5000_RAM_HdStreamState = 1;
        ret = 0;
    }
    return ret;
}
