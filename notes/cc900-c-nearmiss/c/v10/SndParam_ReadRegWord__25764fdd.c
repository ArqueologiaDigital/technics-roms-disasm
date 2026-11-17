/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_11m283a.c (2026-11-16-123-p6-r25)
   sha256 25764fdd3eabbdab5ec6fde73caec032c16d8fcd9b11fd720b7a3f5102cc6cbe (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
extern char SndParam_WordValueListPtrs[];
int SndParam_ReadRegWord(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    unsigned int *lst;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = ((unsigned int *)blk)[d[5]];
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[(signed char)((signed char)d[11] << 2)];
    r = 0;
    do {
        if (v == *lst++) return r;
        r++;
    } while (r <= 5);
    return 0;
}
