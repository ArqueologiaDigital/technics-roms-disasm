/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283a.c (2026-11-16-100-p6-r19)
   sha256 cc163c69f7fc974d121e418b768ffd0651b39c90bbb6d1ba4e4deea36d2095c0 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) r = *(unsigned int *)(blk + 8) & 0x1ff;
    return r;
}
