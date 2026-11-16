/* lane_p6 helper F, round 11, module 283 (audio/sndparam_routines.s), form b: alternatives to form a.
   SndParam_ReadRegWord: the index as `(char)((char)d[11] * 4)`.  SndParam_ReadRegBitfield: the merged
   xor-byte / shift-count variable declared after the mask (decl order m, x, m2).  SndParam_ReadRegAddress: the
   word is read into a local, masked in the return expression. */

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
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[(char)((char)d[11] * 4)];
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
    unsigned char m;
    unsigned char x;
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
    v = *(unsigned int *)(blk + 8);
    return v & 0x1ff;
}
