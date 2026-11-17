/* lane_p6 helper F, round 12, module 283 (audio/sndparam_routines.s), form a.  (BinarySearch, ResetDefaultTable
   and ReadRegWord matched; not repeated.)
   SndParam_ReadRegBitfield (r25 +47, form b): the merged xor-byte / shift-count variable now gets the ROM's E.
   Only the two mask bytes are swapped against the ROM (ours: mask B, copy C; ROM: mask C, copy B).  In r23 and
   r25 the first-declared of the three byte locals got B and the second E, so here the copy is declared first,
   then the xor byte, then the mask.
   SndParam_ReadRegAddress (+27): the ROM reads and masks the word in WA, then moves it to HL.  Here the word goes
   to a local, is masked in place by a separate statement, and that local is returned. */

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

int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = *(unsigned int *)(blk + 8);
    v &= 0x1ff;
    return v;
}
