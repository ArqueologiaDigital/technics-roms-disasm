/* lane_p6 helper F, round 9, module 283 (audio/sndparam_routines.s), form a.  Near-misses of run r19.
   SndParam_BinarySearch (+5): the ROM tests the empty table by the borrow of `hi = n - 1` (sub / jr c), then
   runs a bottom-tested loop.  SndParam_ReadRegAddress (+27): the masked word goes through a local (the ROM builds
   it in WA, then moves it to HL).  SndParam_ResetDefaultTable (+17): the first-word store through a pointer local.
   SndParam_ReadRegBitfield (+23): offset and offset + 1 as two locals, mask / xor / shift bytes as locals
   (lane_sub's spelling (a)).  SndParam_ReadRegWord: the list offset shifted as a signed byte (the ROM's sla). */

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
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return r;
    v = ((unsigned int *)blk)[d[5]];
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + (signed char)((signed char)d[11] << 2));
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

int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;
    unsigned int v;
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        v = *(unsigned int *)(blk + 8) & 0x1ff;
        r = v;
    }
    return r;
}

void SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    q = &ram_96d4[0].w[0];
    *q = 0xffff;
}

int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n - 1;
    if (hi < n) {
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
