/* lane_sub probe round 2, helper C, form c: the tone-generator register writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s), whose `nop` runs are taken as cc900 inline assembly (__ASM, the spelling of
   Toshiba's own library sources).  One write: P6 bit 7 low, the register number to the address latch (0x100000),
   one nop, P6 bit 7 high, the value to the data port (0x100002), then a `jr` to the next instruction and three nops.
   The `jr` is spelt two ways, one per function group: TG_WAIT_J as the assembler's `jr $+2`, TG_WAIT_D as its two
   bytes (68 00), so that a listing check does not depend on the `$` spelling.  Values held across the inline
   assembly move to IZ / the stack in the ROM, which suggests V4.23 treats __ASM as clobbering the scratch registers. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

#define TG_WAIT_J __ASM("\tjr\t$+2"); __ASM("\tnop"); __ASM("\tnop"); __ASM("\tnop")
#define TG_WAIT_D __ASM("\tdb\t0x68,0x00"); __ASM("\tnop"); __ASM("\tnop"); __ASM("\tnop")
#define TG_WRITE_J(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("\tnop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT_J
#define TG_WRITE_D(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("\tnop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT_D

void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v)
{
    TG_WRITE_J(reg, v);
}

void ToneGen_WriteExprReg(unsigned int reg, unsigned int v)
{
    TG_WRITE_D(reg + 0x180, v);
}

void ToneGen_WriteVoicePitch(unsigned int reg, unsigned int *p)
{
    TG_WRITE_D(reg + 0x400, p[7]);
}

/* cc900-name: ToneGen_WriteReg0080_StrobeClr=ToneGen_WriteReg0080_StrobeClear */
void ToneGen_WriteReg0080_StrobeClr(unsigned int reg, unsigned int *p)
{
    TG_WRITE_D(reg + 0x80, p[2] & ~0x8000);
}

void ToneGen_WriteExtParam_600(unsigned int reg, unsigned int *p)
{
    TG_WRITE_J(reg + 0x600, p[32]);
}

void ToneGen_WriteReg0640(unsigned int reg, unsigned int *p)
{
    TG_WRITE_D(reg + 0x640, p[33]);
}

/* cc900-name: TG_WriteExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p)
{
    TG_WRITE_D(reg + 0x1c0, p[28]);
}

void ToneGen_WriteExtParam_600_Mute(unsigned int reg)
{
    TG_WRITE_D(reg + 0x580, 0x8100);
}

void ToneGen_WriteExtParam_540_Mute(unsigned int reg)
{
    TG_WRITE_J(reg + 0x540, 0x8100);
}

void ToneGen_Mute_Reg05C0(unsigned int reg)
{
    TG_WRITE_D(reg + 0x5c0, 0x8100);
}

void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p)
{
    TG_WRITE_J(reg + 0x840, p[13]);
    TG_WRITE_J(reg + 0x880, p[14]);
}

void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p)
{
    TG_WRITE_D(reg + 0x840, p[23]);
    TG_WRITE_D(reg + 0x880, p[23]);
}

/* cc900-name: TG_WriteExtParam_TypeDisp_One=ToneGen_WriteExtParam_TypeDispatch_Single */
void TG_WriteExtParam_TypeDisp_One(unsigned int reg, unsigned int *p)
{
    if (reg < 0x40) {
        TG_WRITE_D(reg + 0x1c0, p[28]);
    } else {
        TG_WRITE_D(reg + 0x600, p[33]);
    }
}

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
void TG_WriteExtParam_Mute_TypeDisp(unsigned int reg)
{
    if (reg < 0x40) {
        TG_WRITE_D(reg + 0x540, 0x8100);
    } else {
        TG_WRITE_D(reg + 0x580, 0x8100);
    }
}

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        TG_WRITE_D(reg + 0x580, p[30]);
    }
    TG_WRITE_D(reg + 0x580, p[30] & ~0x8000);
}

void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        TG_WRITE_J(reg + 0x580, p[30]);
    }
    TG_WRITE_J(reg + 0x600, p[32]);
    TG_WRITE_J(reg + 0x580, p[30] & ~0x8000);
}

/* cc900-name: TG_Write_ExtParam_05C0_Strobe=ToneGen_Write_ExtParam_05C0_Strobe */
void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p)
{
    if (p[31] & 0x8000) {
        TG_WRITE_D(reg + 0x5c0, p[31]);
    }
    TG_WRITE_D(reg + 0x5c0, p[31] & ~0x8000);
}
