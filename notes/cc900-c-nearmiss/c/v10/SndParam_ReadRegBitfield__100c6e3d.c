/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283b.c (2026-11-16-118-p6-r23)
   sha256 100c6e3d84f736414619f20e5bbb021e5d1130789fe6ff9b479a192b7b3f948e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *SndParam_BlockRamPtrs[];
int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char x;
    unsigned char m;
    unsigned char m2;
    unsigned char s;
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
            s = d[9];
            v >>= s;
            if (v != 0) {
                m >>= s;
                v ^= m;
            }
        } else {
            v = 3;
        }
    }
    return v;
}
