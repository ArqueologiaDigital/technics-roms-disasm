/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small2.c (2026-11-17-13-hd-r42-ports)
   sha256 41fb532d04b1cddcad2b89adfb641aa4f14ab58d55121e6a1f2ac49d2d663760 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern int HDAE5000_HD_WriteFile(void *, unsigned long, void *);
extern int HDAE5000_HD_AppendFile(void *, unsigned long, void *);
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
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
