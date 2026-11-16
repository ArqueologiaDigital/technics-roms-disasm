/* lane_p6 helper F, round 9, module 283 (audio/sndparam_routines.s), form b: alternatives to form a.
   BinarySearch tests `n >= 1`; ReadRegAddress masks the local in a second statement; ResetDefaultTable's pointer
   local is `register`; ReadRegBitfield reads the pending flag through `(blk + 1)[o]`; ReadRegWord shifts a
   signed char local. */

extern unsigned char *SndParam_BlockRamPtrs[];
extern unsigned int *SndParam_WordValueListPtrs[];
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];

int SndParam_ReadRegWord(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    unsigned int *lst;
    signed char c;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = ((unsigned int *)blk)[d[5]];
    c = d[11];
    c <<= 2;
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + c);
    for (r = 0; r <= 5; r++) {
        if (v == *lst++) return r;
    }
    return 0;
}

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

int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        v = *(unsigned int *)(blk + 8);
        v &= 0x1ff;
        r = v;
    }
    return r;
}

void SndParam_ResetDefaultTable(void)
{
    register struct SpRec12 *p;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    p = ram_96d4;
    p->w[0] = 0xffff;
}

int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    if (n >= 1) {
        hi = n - 1;
        do {
            mid = (lo + hi) >> 1;
            e = t[mid];
            if (key == e) return 0;
            if (key > e) lo = mid + 1;
            else hi = mid - 1;
        } while (lo <= hi);
    }
    return -1;
}
