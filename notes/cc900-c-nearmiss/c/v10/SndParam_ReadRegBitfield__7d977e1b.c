/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283a.c (2026-11-16-107-p6-r21)
   sha256 7d977e1b84fde5b654e37b6a6c3d68f9fd9f03a4001a215e73154c642a6c15aa (tar-sha256); compiled at -Xr */
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
    int o1;

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
            v = (v ^ x) & m2;
            s = d[9];
            v >>= s;
            if (v != 0) v ^= m >> s;
        } else {
            v = 3;
        }
    }
    return v;
}
