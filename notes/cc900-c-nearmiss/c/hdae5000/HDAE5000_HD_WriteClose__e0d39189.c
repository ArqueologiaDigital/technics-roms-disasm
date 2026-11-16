/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13_nab.c (2026-11-16-74-hd-r13)
   sha256 e0d391891772a0e5698a11347fbd3107687329a21419a0f7f0fbfe08f2009d9e (tar-sha256); compiled at -Xr */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern int HDAE5000_HD_WriteFile(unsigned long, unsigned long, long *);
extern int HDAE5000_HD_AppendFile(unsigned long, unsigned long, long *);
void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
