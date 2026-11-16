/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13_na.c (2026-11-16-74-hd-r13)
   sha256 532eb7d7fff0fcd52986e898a5cafd2e3678d379d6e080609667776872c0dce8 (tar-sha256); compiled at -Xr */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern int HDAE5000_HD_WriteFile(const void *, unsigned long, long *);
extern int HDAE5000_HD_AppendFile(const void *, unsigned long, long *);
void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
