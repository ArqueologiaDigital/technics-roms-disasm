/* lane_p6 helper F, round 10, module 283 (audio/sndparam_routines.s), form a.  One-spot refinements of run r21.
   SndParam_BinarySearch (+5): the ROM computes hi = n - 1 with `sub` and leaves on its borrow, then runs a
   bottom-tested loop: a plain `while (lo <= hi)`, whose test -O3 copies to the entry with lo = 0.
   SndParam_ReadRegWord (Xr +43): the scan loop has no entry test (do-while), and the list table is indexed by a
   signed byte through an array subscript (the ROM puts the base in XBC and indexes with A).
   SndParam_ReadRegBitfield (+23): no offset+1 local (the ROM keeps the offset in BC, offset+1 in DE); the mask
   copy declared first; the mask itself shifted in place.
   SndParam_ReadRegAddress (+27): the ROM computes the masked word in WA and moves it to HL: the field is read as
   a 9-bit bitfield (fields fill from the top bit down, so a 7-bit pad comes first).
   SndParam_ResetDefaultTable (+17): the ROM's pointer is XHL: the function returns it. */

extern unsigned char *SndParam_BlockRamPtrs[];
extern char SndParam_WordValueListPtrs[];
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
struct SpAddr { unsigned int w0[4]; unsigned int pad : 7; unsigned int addr : 9; };

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
    lst = *(unsigned int **)&SndParam_WordValueListPtrs[c];
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
    unsigned char m2;
    unsigned char m;
    unsigned char x;
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
            m2 = m;
            x = d[10];
            v = (v ^ x) & m2;
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
    if (blk != 0) {
        r = ((struct SpAddr *)blk)->addr;
    }
    return r;
}

unsigned int *SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    q = &ram_96d4[0].w[0];
    *q = 0xffff;
    return q;
}

int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n - 1;
    while (lo <= hi) {
        mid = (lo + hi) >> 1;
        e = t[mid];
        if (key == e) return 0;
        if (key > e) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}
