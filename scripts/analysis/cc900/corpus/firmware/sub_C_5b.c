/* lane_sub probe round 5, helper C, form b: the tone-generator register writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s) with V4.23's pseudo-registers holding what the ROM keeps across the inline
   nops (helper B's ToneGen_WriteVoice_Direct matched with `__IZ = d; ... = __IZ;`).
   - one record pointer (ROM `push xiz; ld xiz,xbc`, then `ld wa,(xiz+N)`): `__XIZ = (unsigned long)p;` and the word
     read as `*(unsigned int *)(__XIZ + N)`, since B's `((struct *)__XIZ)->w[n]` copied XIZ to XWA first;
   - register number and record pointer (ROM `dec 4,xsp; pushw iz; ld (xsp+2),xbc; ld iz,wa`, the pointer reloaded
     from (xsp+2) for every read): the number in __IZ, the pointer in a one-element local array, which V4.23 must
     keep in the stack frame.
   sub_C_5c.c has the same functions spelt `((unsigned int *)__XIZ)[n]` and with the parameter's address taken. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

void ToneGen_WriteVoicePitch(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x400;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 14);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: ToneGen_WriteReg0080_StrobeClr=ToneGen_WriteReg0080_StrobeClear */
void ToneGen_WriteReg0080_StrobeClr(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x80;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 4) & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParam_600(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x600;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 64);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteReg0640(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x640;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 66);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: TG_WriteExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x1c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 56);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 46);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: TG_WriteExtParam_TypeDisp_One=ToneGen_WriteExtParam_TypeDispatch_Single */
void TG_WriteExtParam_TypeDisp_One(unsigned int reg, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    if (reg < 0x40) {
        ram_18 &= ~0x80;
        ram_100000 = reg + 0x1c0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 56);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = reg + 0x600;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 66);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x880;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x880;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x100;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x140;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][30];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x8100;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][31];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)((unsigned long)q[0] + 45);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][30] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x580;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][30];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x580;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][30] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][30] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x580;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][30];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x600;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][32];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x580;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][30] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: TG_Write_ExtParam_05C0_Strobe=ToneGen_Write_ExtParam_05C0_Strobe */
void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][31] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x5c0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][31];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x5c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][31] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][29] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x540;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][29];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x540;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][29] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][29] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x540;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][29];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x1c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][28];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x540;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][29] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = reg;
    if (q[0][31] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x5c0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][31];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x640;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][33];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x5c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][31] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
