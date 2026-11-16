/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283b.c (2026-11-16-107-p6-r21)
   sha256 53cb568b54e7d0b445ed3ebdfaa2071a9d155552b182d093e04f113112383e92 (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
extern unsigned int *SndParam_WordValueListPtrs[];
int SndParam_ReadRegWord(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    unsigned int *lst;
    signed char c;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = ((unsigned int *)blk)[d[5]];
    c = d[11];
    c <<= 2;
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + c);
    for (r = 0; r <= 5; r++) {
        if (v == *lst++) return r;
    }
    return 0;
}
