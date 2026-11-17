/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283b.c (2026-11-16-118-p6-r23)
   sha256 100c6e3d84f736414619f20e5bbb021e5d1130789fe6ff9b479a192b7b3f948e (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    return *(unsigned int *)(blk + 8) & 0x1ff;
}
