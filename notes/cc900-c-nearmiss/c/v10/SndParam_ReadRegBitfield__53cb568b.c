/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283b.c (2026-11-16-107-p6-r21)
   sha256 53cb568b54e7d0b445ed3ebdfaa2071a9d155552b182d093e04f113112383e92 (tar-sha256); compiled at -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char m;
    unsigned char m2;
    unsigned char x;
    unsigned char s;
    unsigned char *blk;
    int o;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        o = d[5];
        if (!((blk + 1)[o] & 4)) {
            v = blk[o];
            m = d[6];
            m2 = m;
            x = d[10];
            v ^= x;
            v &= m2;
            s = d[9];
            v >>= s;
            if (v != 0) v ^= m >> s;
        } else {
            v = 3;
        }
    }
    return v;
}
