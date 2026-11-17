/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283a.c (2026-11-16-118-p6-r23)
   sha256 c3cd59d1f5affaf9f3a5d10c7a8c858173f6970cda4882faede02b8ca900cb50 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
struct SpAddr { unsigned int w0[4]; unsigned int pad : 7; unsigned int addr : 9; };
int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        r = ((struct SpAddr *)blk)->addr;
    }
    return r;
}
