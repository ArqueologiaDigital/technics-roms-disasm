/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283a.c (2026-11-16-118-p6-r23)
   sha256 c3cd59d1f5affaf9f3a5d10c7a8c858173f6970cda4882faede02b8ca900cb50 (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
extern char SndParam_WordValueListPtrs[];
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
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[c];
    r = 0;
    do {
        if (v == *lst++) return r;
        r++;
    } while (r <= 5);
    return 0;
}
