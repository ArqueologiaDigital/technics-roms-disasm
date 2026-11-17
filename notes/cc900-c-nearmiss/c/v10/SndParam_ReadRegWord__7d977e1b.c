/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283a.c (2026-11-16-107-p6-r21)
   sha256 7d977e1b84fde5b654e37b6a6c3d68f9fd9f03a4001a215e73154c642a6c15aa (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
extern unsigned int *SndParam_WordValueListPtrs[];
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
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + (signed char)((signed char)d[11] << 2));
    for (r = 0; r <= 5; r++) {
        if (v == *lst++) return r;
    }
    return 0;
}
