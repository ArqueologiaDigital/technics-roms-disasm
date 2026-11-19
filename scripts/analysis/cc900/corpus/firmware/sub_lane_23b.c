/* lane_sub, round 23, form b (KN5000 sub-CPU payload v1.42), 2026-11-19.
   The odd-size record copies (11 bytes, the ROM: five words then one `ldi`): sub_T_18c.c's DSP_InitChannelSlot with
   the 11-byte struct declared after `#pragma pack(1)`, to see whether V4.23 knows a packing pragma (a struct
   assignment pads the size to even and copies six words).  A file of its own: an unknown pragma may stop it.
   cc900-options: -Xr */

/* cc900-module: DSP_InitChannelSlot */

#pragma pack(1)
struct b11 { unsigned char b[11]; };
#pragma pack()
struct b58 { unsigned char b[58]; };

extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);

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
