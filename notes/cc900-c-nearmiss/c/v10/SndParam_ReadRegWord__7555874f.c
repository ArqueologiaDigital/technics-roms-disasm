/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m283a.c (2026-11-16-88-p6-r16)
   sha256 7555874f9f4353c9597576e92cbf7fd9fb6eeffaa5c4f99a7e0a3421b042df3b (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
extern unsigned int *SndParam_WordValueListPtrs[];
int SndParam_ReadRegWord(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    unsigned int *lst;
    int i;

    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return -1;
    v = ((unsigned int *)blk)[d[5]];
    lst = SndParam_WordValueListPtrs[d[11]];
    for (i = 0; i <= 5; i++) {
        if (v == *lst++) return i;
    }
    return 0;
}
