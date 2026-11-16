/* lane_p6 helper F, round 4, module 283 (audio/sndparam_routines.s), form a.
   The register readers of a sound-parameter descriptor d (bytes: +4 block, +5 offset, +6 mask, +9 shift,
   +10 xor, +11 value-list index): SndParam_ReadRegWord (index of the block word in a 6-entry value list),
   SndParam_ReadRegBitfield, SndParam_ReadRegAddress, and SndParam_ResetDefaultTable (a 12-byte template copied
   to RAM 0x96d4, first word then set to 0xffff).
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

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
    lst = SndParam_WordValueListPtrs[d[11]];
    for (i = 0; i <= 5; i++) {
        if (v == *lst++) return i;
    }
    return 0;
}

int SndParam_ReadRegBitfield(unsigned char *d)
{
    unsigned char v;
    unsigned char *blk;

    v = 0;
    blk = SndParam_BlockRamPtrs[d[4]];
    if (blk != 0) {
        if (blk[d[5] + 1] & 4) {
            v = 3;
        } else {
            v = (blk[d[5]] ^ d[10]) & d[6];
            v >>= d[9];
            if (v != 0) v ^= d[6] >> d[9];
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
    struct SpRec12 *p;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    p = ram_96d4;
    p->w[0] = 0xffff;
}
