/* lane_sub helper B, round 4, form c: two tone-generator writers (core/06_voice_envelopes_and_channels.s, KN5000
   sub-CPU payload v1.42) with the register the ROM keeps across the inline nops named through V4.23's
   pseudo-registers: the record pointer in __XIZ (ToneGen_WriteVoice_Long, ROM `push xiz; ld xiz,xbc`) and the data
   word in __IZ (ToneGen_WriteVoice_Direct, ROM `pushw iz; ld iz,bc`).  Round 3's `register` did not do it. */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

struct tgv { unsigned int w[36]; };

void ToneGen_WriteVoice_Long(unsigned int ch, struct tgv *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = ((struct tgv *)__XIZ)->w[7];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d)
{
    __IZ = d;
    ram_18 &= ~0x80;
    ram_100000 = a;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
