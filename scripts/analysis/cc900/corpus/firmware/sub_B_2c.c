/* lane_sub helper B, round 2, form c: the tone-generator register writers of core/06_voice_envelopes_and_channels.s
   (KN5000 sub-CPU payload v1.42), kept apart because they need inline assembly for their `nop`s.
   One write: P6 bit 7 low (`res 7,(P6)`), the register address to ToneGen_RegAddrLatch (0x100000), one nop, P6 bit 7
   high, the data word to ToneGen_RegDataPort (0x100002), then a `jr` to the next instruction and three nops.
   The `jr` is tried two ways: a goto to the next statement (functions marked G) and the end of a do { } while (0)
   around the write (marked D). */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

struct tgv { unsigned int w[36]; };

/* G */
void ToneGen_WriteVoice_Long(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[7];
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_Short(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x80;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[2] & ~0x8000;
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_EnvLevel(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 384;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[6];
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_Reg11(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[8];
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_Reg13(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 1216;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[10];
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D */
void ToneGen_WriteVoice_Reg18(unsigned int ch, struct tgv *p)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1536;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[32];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D */
void ToneGen_WriteVoice_Reg16(unsigned int ch, struct tgv *p)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1408;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[30];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D */
void ToneGen_WriteVoice_Reg07(unsigned int ch, struct tgv *p)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 448;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[28];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D */
void ToneGen_WriteVoice_Reg15(unsigned int ch, struct tgv *p)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1344;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[29];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G; the 2112 register (0x840 = register 0x21): proposed name ToneGen_WriteVoice_Reg21 */
void VoiceCC_DataTable_0280FE(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 2112;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[23];
    goto gap;
gap:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D: the address and the data both arguments */
void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = a;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = d;
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_TvfPair(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 256;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[4];
    goto gap1;
gap1:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 320;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[5];
    goto gap2;
gap2:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* D */
void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, struct tgv *p)
{
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 2112;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[13];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    do {
        ram_18 &= ~0x80;
        ram_100000 = ch + 2176;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[14];
    } while (0);
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteNote2ch(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x840;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[23];
    goto gap1;
gap1:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x800;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[22];
    goto gap2;
gap2:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* G */
void ToneGen_WriteVoice_6Words(unsigned int ch, struct tgv *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x840;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[23];
    goto gap1;
gap1:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x940;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[25];
    goto gap2;
gap2:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0xa00;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[27];
    goto gap3;
gap3:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x800;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[22];
    goto gap4;
gap4:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x900;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[24];
    goto gap5;
gap5:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x9c0;
    __ASM("\tnop");
    ram_18 |= 0x80;
    ram_100002 = p->w[26];
    goto gap6;
gap6:
    __ASM("\tnop");
    __ASM("\tnop");
    __ASM("\tnop");
}

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
/* G */
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, struct tgv *p)
{
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 448;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[28];
        goto gap1;
gap1:
        __ASM("\tnop");
        __ASM("\tnop");
        __ASM("\tnop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1536;
        __ASM("\tnop");
        ram_18 |= 0x80;
        ram_100002 = p->w[33];
        goto gap2;
gap2:
        __ASM("\tnop");
        __ASM("\tnop");
        __ASM("\tnop");
    }
}

/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
/* D */
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, struct tgv *p)
{
    if (ch < 64) {
        do {
            ram_18 &= ~0x80;
            ram_100000 = ch + 1344;
            __ASM("\tnop");
            ram_18 |= 0x80;
            ram_100002 = p->w[29];
        } while (0);
        __ASM("\tnop");
        __ASM("\tnop");
        __ASM("\tnop");
    } else {
        do {
            ram_18 &= ~0x80;
            ram_100000 = ch + 1408;
            __ASM("\tnop");
            ram_18 |= 0x80;
            ram_100002 = p->w[31];
        } while (0);
        __ASM("\tnop");
        __ASM("\tnop");
        __ASM("\tnop");
    }
}
