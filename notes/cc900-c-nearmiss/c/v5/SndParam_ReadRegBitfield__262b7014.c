/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sndparam_routines_m0_xr.c (2026-11-17-1-p6-r28-staged)
   sha256 262b7014dc5b45cc99916d3db30114962698029a817df39636aed6006cf8a4fc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
