/* lane_p6 helper F, round 10, module 283 (audio/sndparam_routines.s), form b: alternatives to form a.
   SndParam_BinarySearch: hi starts at n and the entry test is its post-decrement (`sub` + borrow), then a
   bottom-tested loop.  SndParam_ReadRegWord: do-while scan; the list table subscripted as a byte array with the
   shifted signed byte written inline.  SndParam_ReadRegBitfield: offset+1 local declared before the offset; the
   value copy of the mask declared after; the mask shifted in place.  SndParam_ReadRegAddress: early return of the
   masked word (no result local).  SndParam_ResetDefaultTable: returns the record pointer (a `register` local). */

extern unsigned char *SndParam_BlockRamPtrs[];
extern char SndParam_WordValueListPtrs[];
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];

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
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[(signed char)(d[11] << 2)];
    r = 0;
    do {
        if (v == *lst++) return r;
    } while (++r <= 5);
    return 0;
}

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

int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    return *(unsigned int *)(blk + 8) & 0x1ff;
}

struct SpRec12 *SndParam_ResetDefaultTable(void)
{
    register struct SpRec12 *p;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    p = ram_96d4;
    p->w[0] = 0xffff;
    return p;
}

int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n;
    if (hi-- != 0) {
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
