/* Functions of core/08_voice_noteon_and_tonegen.s.
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
void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p);
void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParam_600(unsigned int reg, unsigned int *p);
void TG_WriteExtParam_TypeDisp_One(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0080_StrobeClr(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0640(unsigned int reg, unsigned int *p);
void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p);
void ToneGen_WriteVoicePitch(unsigned int reg, unsigned int *p);
void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p);

/* cc900-name: ToneGen_WriteReg0080_StrobeClr=ToneGen_WriteReg0080_StrobeClear */
/* cc900-name: TG_WriteExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
/* cc900-name: TG_WriteExtParam_TypeDisp_One=ToneGen_WriteExtParam_TypeDispatch_Single */
/* cc900-name: TG_Write_ExtParam_05C0_Strobe=ToneGen_Write_ExtParam_05C0_Strobe */
void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParam_600(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x600); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[32]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParam_TypeDisp_One(unsigned int reg, unsigned int *p)
{
    if (reg < 0x40) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x600); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x600); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[32]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[30] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[30] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0080_StrobeClr(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0640(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x640); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoicePitch(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p)
{
    if (p[31] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
