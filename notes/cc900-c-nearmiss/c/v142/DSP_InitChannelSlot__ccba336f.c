/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23b.c (2026-11-19-1-sub-r23a-copy)
   sha256 ccba336ff34e844561aa8d49ef2ca3a33a37c8ad63d2b97d7bfd67071d5b0c44 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
#pragma pack(1)
struct b11 { unsigned char b[11]; };
#pragma pack()
struct b58 { unsigned char b[58]; };
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n)
{
    unsigned char *t;
    unsigned char *q;
    unsigned char *u;

    t = ToneDB_Find_SubToneRecord(rec, (unsigned char)n, 0xff);
    *(struct b58 *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) = *(struct b58 *)t;
    u = (unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c);
    t = u;
    q = u + 16;
    *(struct b11 *)((unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) + 58) = *(struct b11 *)WaveSel_StageA1_FromToneSlot(0, q, (unsigned char)n, 0xff);
    q[2] &= 0xcf;
    q[2] |= 0x10;
    q = t + 37;
    *(struct b11 *)((unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) + 69) = *(struct b11 *)WaveSel_StageA1_FromToneSlot(1, q, (unsigned char)n, 0xff);
    q[2] &= 0xcf;
    q[2] |= 0x10;
}
