/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283b.c (2026-11-16-100-p6-r19)
   sha256 bb5d49ddbd4ab0b4fe2ff807261d08c6b49e6f23f0462ecf3f07c15844c1c009 (tar-sha256); compiled at -Xr */
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
