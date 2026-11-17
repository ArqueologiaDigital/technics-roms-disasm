/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_12m283a.c (2026-11-16-128-p6-r27)
   sha256 79f2e856f8bf39c4a2869ad9a87d8c94f91d7503644f03a26ee59515df3eafc9 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char m2;
    unsigned char x;
    unsigned char m;
    unsigned char *blk;
    int o1;
    int o;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        o = d[5];
        o1 = o + 1;
        if (!(blk[o1] & 4)) {
            v = blk[o];
            m = d[6];
            m2 = m;
            x = d[10];
            v ^= x;
            v &= m2;
            x = d[9];
            v >>= x;
            if (v != 0) {
                m >>= x;
                v ^= m;
            }
        } else {
            v = 3;
        }
    }
    return v;
}
