/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283a.c (2026-11-16-100-p6-r19)
   sha256 cc163c69f7fc974d121e418b768ffd0651b39c90bbb6d1ba4e4deea36d2095c0 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char m;
    unsigned char s;
    unsigned char *blk;
    int o;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        o = d[5];
        if (!(blk[o + 1] & 4)) {
            v = blk[o];
            m = d[6];
            v = (v ^ d[10]) & m;
            s = d[9];
            v >>= s;
            if (v != 0) v ^= m >> s;
        } else {
            v = 3;
        }
    }
    return v;
}
