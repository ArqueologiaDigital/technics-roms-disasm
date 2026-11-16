/* lane_sub probe round 3, helper C, form c: the tone-generator register writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s) as cc900 inline assembly (__ASM, the spelling of Toshiba's own library
   sources), written with a leading space (round 2's "\t" reached asm900 literally; sub_C_3b.c tries a real TAB).
   One write: P6 bit 7 low, the register number to the address latch (0x100000), one nop, P6 bit 7 high, the value
   to the data port (0x100002), then a `jr` to the next instruction and three nops.
   Round 2's listing showed that V4.23 keeps the arguments in WA / XBC across __ASM, where the ROM moves the ones
   still needed after the first nop to IZ / XIZ / the stack, as around a call: only the writers that need nothing
   after it (the *_Mute ones) can match this way.
   Also a third spelling of Audio_Cmd_DSPGlobal_Param_Store: the ROM's trailing `cp a,10 / ret ugt / ret` tests a
   condition with no code in its body; V4.23 deletes an empty `if`, so the body here is an empty __ASM. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

#define TG_WAIT __ASM(" jr $+2"); __ASM(" nop"); __ASM(" nop"); __ASM(" nop")
#define TG_WRITE(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM(" nop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT

void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v)
{
    TG_WRITE(reg, v);
}

void ToneGen_WriteExprReg(unsigned int reg, unsigned int v)
{
    TG_WRITE(reg + 0x180, v);
}

void ToneGen_WriteVoicePitch(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x400, p[7]);
}

/* cc900-name: ToneGen_WriteReg0080_StrobeClr=ToneGen_WriteReg0080_StrobeClear */
void ToneGen_WriteReg0080_StrobeClr(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x80, p[2] & ~0x8000);
}

void ToneGen_WriteExtParam_600(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x600, p[32]);
}

void ToneGen_WriteReg0640(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x640, p[33]);
}

/* cc900-name: TG_WriteExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x1c0, p[28]);
}

void ToneGen_WriteExtParam_600_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x580, 0x8100);
}

void ToneGen_WriteExtParam_540_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x540, 0x8100);
}

void ToneGen_Mute_Reg05C0(unsigned int reg)
{
    TG_WRITE(reg + 0x5c0, 0x8100);
}

void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x840, p[13]);
    TG_WRITE(reg + 0x880, p[14]);
}

void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p)
{
    TG_WRITE(reg + 0x840, p[23]);
    TG_WRITE(reg + 0x880, p[23]);
}

/* cc900-name: TG_WriteExtParam_TypeDisp_One=ToneGen_WriteExtParam_TypeDispatch_Single */
void TG_WriteExtParam_TypeDisp_One(unsigned int reg, unsigned int *p)
{
    if (reg < 0x40) {
        TG_WRITE(reg + 0x1c0, p[28]);
    } else {
        TG_WRITE(reg + 0x600, p[33]);
    }
}

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
void TG_WriteExtParam_Mute_TypeDisp(unsigned int reg)
{
    if (reg < 0x40) {
        TG_WRITE(reg + 0x540, 0x8100);
    } else {
        TG_WRITE(reg + 0x580, 0x8100);
    }
}

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        TG_WRITE(reg + 0x580, p[30]);
    }
    TG_WRITE(reg + 0x580, p[30] & ~0x8000);
}

void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p)
{
    if (p[30] & 0x8000) {
        TG_WRITE(reg + 0x580, p[30]);
    }
    TG_WRITE(reg + 0x600, p[32]);
    TG_WRITE(reg + 0x580, p[30] & ~0x8000);
}

/* cc900-name: TG_Write_ExtParam_05C0_Strobe=ToneGen_Write_ExtParam_05C0_Strobe */
void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p)
{
    if (p[31] & 0x8000) {
        TG_WRITE(reg + 0x5c0, p[31]);
    }
    TG_WRITE(reg + 0x5c0, p[31] & ~0x8000);
}

struct dspglob { unsigned char pad[426]; unsigned char t11[4][11]; };
extern struct dspglob ram_44fce;
struct row11 { unsigned char b[11]; };

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    ((struct row11 *)ram_44fce.t11[(m[2] & 0xc0) >> 6])->b[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
