/* lane_p6 helper F, round 4, module 283 (audio/sndparam_routines.s), form b.
   As form a, with: the value-list pointer indexed by a byte offset (the ROM shifts the index in A and reads
   `(xbc+a)`), the bit-field mask and shift held in locals, and the default-table word stored directly. */

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
    int i;

    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return -1;
    v = ((unsigned int *)blk)[d[5]];
    lst = *(unsigned int **)((char *)SndParam_WordValueListPtrs + (unsigned char)(d[11] << 2));
    for (i = 0; i <= 5; i++) {
        if (v == *lst++) return i;
    }
    return 0;
}

int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char m;
    unsigned char s;
    unsigned char *blk;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        if (blk[d[5] + 1] & 4) {
            v = 3;
        } else {
            m = d[6];
            v = (blk[d[5]] ^ d[10]) & m;
            s = d[9];
            v >>= s;
            if (v != 0) v ^= m >> s;
        }
    }
    return v;
}

int SndParam_ReadRegAddress(unsigned char *d)
{
    unsigned char *blk;

    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk == 0) return -1;
    return *(unsigned int *)(blk + 8) & 0x1ff;
}

void SndParam_ResetDefaultTable(void)
{
    ram_96d4[0] = SndParam_ClearRecordTemplate;
    ram_96d4[0].w[0] = 0xffff;
}
