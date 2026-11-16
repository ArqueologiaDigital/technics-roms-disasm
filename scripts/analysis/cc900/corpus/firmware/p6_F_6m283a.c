/* lane_p6 helper F, round 6, module 283 (audio/sndparam_routines.s), form a.
   Refinements of run 88: the ROM loads the -1 result into HL before the block lookup and returns with `ret z`,
   so the readers keep their result in a variable set to -1 first.  SndParam_ReadRegBitfield: the offset as an
   int local (the ROM reuses BC and indexes +1 through DE), the pending-write case tested last.
   SndParam_ResetDefaultTable: the first-word store through an integer address (lane_hd's idiom for the ROM's
   lda + register-indirect store).  New: SndParam_BinarySearch (byte key in a sorted byte table, 0 if found). */

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
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + (signed char)(d[11] << 2));
    for (r = 0; r <= 5; r++) {
        if (v == *lst++) return r;
    }
    return 0;
}

int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char m;
    unsigned char s;
    unsigned char *blk;
    int o;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        o = d[5];
        if (!(blk[o + 1] & 4)) {
            v = blk[o];
            m = d[6];
            v = (v ^ d[10]) & m;
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
    int r;

    r = -1;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) r = *(unsigned int *)(blk + 8) & 0x1ff;
    return r;
}

void SndParam_ResetDefaultTable(void)
{
    ram_96d4[0] = SndParam_ClearRecordTemplate;
    *(unsigned int *)((unsigned long)&ram_96d4[0] + 0) = 0xffff;
}

int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    if (n != 0) {
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
