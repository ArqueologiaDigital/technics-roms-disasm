/* lane_sub, round 23, form a (KN5000 sub-CPU payload v1.42), 2026-11-19.
   The odd-size record copies (11 and 295 bytes, the ROM: words then one `ldi`): sub_T_18c.c's DSP_InitChannelSlot
   and DSP_FlushAllSlots with every odd-size struct assignment written as memcpy(dst, src, N) with a prototype, to
   see whether V4.23 expands memcpy inline (a struct assignment pads the size to even and copies one word more).
   cc900-options: -Xr */

/* cc900-module: DSP_InitChannelSlot */

struct b58 { unsigned char b[58]; };
struct e2 { unsigned char b0, b1; };

extern void *memcpy(void *d, const void *s, unsigned int n);
extern unsigned char *ram_4531c;
extern unsigned char ram_7800[];
extern unsigned char DSP1_ImageHeader_UserKit[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern void InterCPU_E1_DMA_Transfer(unsigned char *p, unsigned int n, unsigned long dst);
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
    memcpy((unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) + 58, WaveSel_StageA1_FromToneSlot(0, q, (unsigned char)n, 0xff), 11);
    q[2] &= 0xcf;
    q[2] |= 0x10;
    q = t + 37;
    memcpy((unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) + 69, WaveSel_StageA1_FromToneSlot(1, q, (unsigned char)n, 0xff), 11);
    q[2] &= 0xcf;
    q[2] |= 0x10;
}

void DSP_FlushAllSlots(unsigned char a, unsigned char b)
{
    unsigned char *rec;
    unsigned int i;

    rec = (unsigned char *)ToneDB_Find_ToneRecord(a, b);
    memcpy(ram_4531c + 0x4980, rec, 295);
    for (i = 0; i < 0x80; i++) {
        ((struct e2 *)(((unsigned long)i * 2 + 0x49a7) + ram_4531c))->b1 &= ~0x20;
        ((struct e2 *)(((unsigned long)i * 2 + 0x49a7) + ram_4531c))->b1 |= 0x20;
    }
    for (i = 0; i < 0x80; i++)
        DSP_InitChannelSlot(rec, i);
    for (i = 0; i < 0x10; i++)
        *(((unsigned long)i + 0x4980) + ram_4531c) = DSP1_ImageHeader_UserKit[i];
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);
}
