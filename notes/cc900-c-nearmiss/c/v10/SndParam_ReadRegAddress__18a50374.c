/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_12m283b.c (2026-11-16-128-p6-r27)
   sha256 18a50374eea2534e422c8333c706e4577707f44d267531cdb2da3be25227ba2b (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    r = (int)(*(unsigned int *)(blk + 8) & 0x1ff);
    return r;
}
