/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sndparam_routines_m283_xr.c (2026-11-16-125-p6-r26-staged)
   sha256 dc2986ff7c25851bfb7fe5662afe1298d5defa273416a1040bbbd15128657c8e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
