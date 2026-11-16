/* lane_p6 helper F, round 11, module 283 (audio/sndparam_routines.s), form a.  (BinarySearch and
   ResetDefaultTable matched in r23; not repeated.)
   SndParam_ReadRegWord: r23 form a was right except the list index (C, base in XWA) and form b right in the index
   (A, base XBC) but shifted logically and with a `++r` loop test that took WA.  Here: form a's loop, form b's
   inline index, shifted as a signed byte (sla).
   SndParam_ReadRegBitfield: r23 form b fixed the offsets (offset+1 local declared first).  The ROM's shift count
   lives in the xor byte's register, so they are one variable; it is declared first (the ROM gives it E, the mask C
   and the mask copy B).
   SndParam_ReadRegAddress: the ROM computes the word in WA and moves it to HL; neither a bitfield nor an early
   return did that.  Here the masked word goes to a local that is returned directly. */

extern unsigned char *SndParam_BlockRamPtrs[];
extern char SndParam_WordValueListPtrs[];

int SndParam_ReadRegWord(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    unsigned int *lst;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = ((unsigned int *)blk)[d[5]];
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[(signed char)((signed char)d[11] << 2)];
    r = 0;
    do {
        if (v == *lst++) return r;
        r++;
    } while (r <= 5);
    return 0;
}

int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char x;
    unsigned char m;
    unsigned char m2;
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
    v = *(unsigned int *)(blk + 8) & 0x1ff;
    return v;
}
