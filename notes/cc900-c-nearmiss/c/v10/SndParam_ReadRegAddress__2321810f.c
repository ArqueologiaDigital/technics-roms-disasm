/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_11m283b.c (2026-11-16-123-p6-r25)
   sha256 2321810f484af7121bfa772224129e3b1f53c7f689b80e8d63876ce3367adf98 (tar-sha256); compiled at -Xr */
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
    return v & 0x1ff;
}
