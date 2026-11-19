/* lane_sub, round 23: sub_B_3c.c respelled by notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23w.py, form b: inline assembly as `__asm` (V4.23 then keeps values live across it in XIZ, as the ROM does), and no `register` storage class.  The original file follows unchanged otherwise.
   cc900-options: -Xr */

/* lane_sub helper B, round 3, form c: the tone-generator writers of core/06_voice_envelopes_and_channels.s
   (KN5000 sub-CPU payload v1.42).  One write: P6 bit 7 low (`res 7,(P6)`), the address to
   ToneGen_RegAddrLatch (0x100000), one nop, P6 bit 7 high, the data word to ToneGen_RegDataPort (0x100002), then a
   `jr` to the next instruction and three nops: the settling gap.
   Round 2 (listing of sub_B_2c): V4.23 drops a goto to the next statement and the end of a do { } while (0), so the
   `jr` is inline here (`jr $+2`); and it keeps an argument in its own across inline assembly, where the
   ROM holds it in XIZ / IZ (one argument) or spills it to the stack (6Words, 2ch, TvfPair, Reg21_Reg22).  So the
   argument the ROM keeps in XIZ / IZ is declared `register`, and the one it spills is `volatile`. */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

struct tgv { unsigned int w[36]; };

#define TG_WRITE(a, d) \
    ram_18 &= ~0x80; \
    ram_100000 = (a); \
    __asm(" nop"); \
    ram_18 |= 0x80; \
    ram_100002 = (d); \
    __asm(" jr $+2"); \
    __asm(" nop"); \
    __asm(" nop"); \
    __asm(" nop")

void ToneGen_WriteVoice_Long(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 0x400, p->w[7]);
}

void ToneGen_WriteVoice_Short(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 0x80, p->w[2] & 0x7fff);
}

void ToneGen_WriteVoice_EnvLevel(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 384, p->w[6]);
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 1088, p->w[8]);
}

void ToneGen_WriteVoice_Reg13(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 1216, p->w[10]);
}

void ToneGen_WriteVoice_Reg18(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 1536, p->w[32]);
}

void ToneGen_WriteVoice_Reg16(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 1408, p->w[30]);
}

void ToneGen_WriteVoice_Reg07(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 448, p->w[28]);
}

void ToneGen_WriteVoice_Reg15(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 1344, p->w[29]);
}

/* 0x21 (address 0x840): proposed name ToneGen_WriteVoice_Reg21 */
void VoiceCC_DataTable_0280FE(unsigned int ch, struct tgv *p)
{
    TG_WRITE(ch + 2112, p->w[23]);
}

void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d)
{
    TG_WRITE(a, d);
}

void ToneGen_WriteVoice_TvfPair(unsigned int ch, struct tgv *volatile p)
{
    TG_WRITE(ch + 256, p->w[4]);
    TG_WRITE(ch + 320, p->w[5]);
}

void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, struct tgv *volatile p)
{
    TG_WRITE(ch + 2112, p->w[13]);
    TG_WRITE(ch + 2176, p->w[14]);
}

void ToneGen_WriteNote2ch(unsigned int ch, struct tgv *volatile p)
{
    TG_WRITE(ch + 0x840, p->w[23]);
    TG_WRITE(ch + 0x800, p->w[22]);
}

void ToneGen_WriteVoice_6Words(unsigned int ch, struct tgv *volatile p)
{
    TG_WRITE(ch + 0x840, p->w[23]);
    TG_WRITE(ch + 0x940, p->w[25]);
    TG_WRITE(ch + 0xa00, p->w[27]);
    TG_WRITE(ch + 0x800, p->w[22]);
    TG_WRITE(ch + 0x900, p->w[24]);
    TG_WRITE(ch + 0x9c0, p->w[26]);
}

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, struct tgv *p)
{
    if (ch < 64) {
        TG_WRITE(ch + 448, p->w[28]);
    } else {
        TG_WRITE(ch + 1536, p->w[33]);
    }
}

/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, struct tgv *p)
{
    if (ch < 64) {
        TG_WRITE(ch + 1344, p->w[29]);
    } else {
        TG_WRITE(ch + 1408, p->w[31]);
    }
}
