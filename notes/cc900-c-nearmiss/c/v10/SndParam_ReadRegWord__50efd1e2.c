/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m283b.c (2026-11-16-88-p6-r16)
   sha256 50efd1e278fa3afd62fb24cf9230373917a958333655c5050e23d53d8b723ae5 (tar-sha256); compiled at -Xr */
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
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + (unsigned char)(d[11] << 2));
    for (i = 0; i <= 5; i++) {
        if (v == *lst++) return i;
    }
    return 0;
}
