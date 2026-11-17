/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_module.c (2026-11-16-105-hd-r23b)
   sha256 f721493898ffe347f63ad95ec5c545423ef33b04332f244f5af5436afc2e1b69 (tar-sha256); compiled at -Xr
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
