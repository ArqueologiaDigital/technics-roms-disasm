/* lane_p6 helper F, round 12, module 283 (audio/sndparam_routines.s), form b: alternatives to form a.
   SndParam_ReadRegBitfield: byte locals declared xor byte, copy, mask.
   SndParam_ReadRegAddress: the masked word, cast to int, is assigned back to the result variable that held the
   preloaded -1 (the ROM builds it in WA, then ld HL,WA). */

extern unsigned char *SndParam_BlockRamPtrs[];

int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char x;
    unsigned char m2;
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
