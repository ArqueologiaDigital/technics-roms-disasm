/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
struct tgv { unsigned int w[36]; };
void ToneGen_WriteNote2ch(register unsigned int ch, struct tgv *volatile p);
void ToneGen_WriteVoice_6Words(register unsigned int ch, struct tgv *volatile p);
void ToneGen_WriteVoice_EnvLevel(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Long(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg07(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg11(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg13(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg15(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg16(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg18(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_Reg21_Reg22(register unsigned int ch, struct tgv *volatile p);
void ToneGen_WriteVoice_Short(unsigned int ch, register struct tgv *p);
void ToneGen_WriteVoice_TvfPair(register unsigned int ch, struct tgv *volatile p);

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
void ToneGen_WriteNote2ch(register unsigned int ch, struct tgv *volatile p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_6Words(register unsigned int ch, struct tgv *volatile p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[25]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[27]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[24]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[26]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_EnvLevel(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 384); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Long(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg07(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, register struct tgv *p)
{
    if (ch < 64) {
        ram_18 &= ~0x80; ram_100000 = (ch + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        ram_18 &= ~0x80; ram_100000 = (ch + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg13(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 1216); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg15(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 1344); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, register struct tgv *p)
{
    if (ch < 64) {
        ram_18 &= ~0x80; ram_100000 = (ch + 1344); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        ram_18 &= ~0x80; ram_100000 = (ch + 1408); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteVoice_Reg16(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 1408); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg18(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[32]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Reg21_Reg22(register unsigned int ch, struct tgv *volatile p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 2112); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 2176); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_Short(unsigned int ch, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2] & 0x7fff); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoice_TvfPair(register unsigned int ch, struct tgv *volatile p)
{
    ram_18 &= ~0x80; ram_100000 = (ch + 256); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (ch + 320); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
