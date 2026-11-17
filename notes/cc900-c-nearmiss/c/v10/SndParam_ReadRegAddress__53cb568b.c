/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283b.c (2026-11-16-107-p6-r21)
   sha256 53cb568b54e7d0b445ed3ebdfaa2071a9d155552b182d093e04f113112383e92 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        v = *(unsigned int *)(blk + 8);
        v &= 0x1ff;
        r = v;
    }
    return r;
}
