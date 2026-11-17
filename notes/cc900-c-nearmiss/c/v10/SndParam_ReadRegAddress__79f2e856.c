/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_12m283a.c (2026-11-16-128-p6-r27)
   sha256 79f2e856f8bf39c4a2869ad9a87d8c94f91d7503644f03a26ee59515df3eafc9 (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = *(unsigned int *)(blk + 8);
    v &= 0x1ff;
    return v;
}
