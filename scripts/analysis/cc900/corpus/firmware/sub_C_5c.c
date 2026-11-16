/* lane_sub probe round 5, helper C, form c: the functions of sub_C_5b.c spelt differently: the record word read
   through __XIZ as `((unsigned int *)__XIZ)[n]`, and in the two-value writers the record pointer parameter kept in
   the stack frame by taking its address (`(void)&p;`).  (Round 4's sub_C_4c.c crashed V4.23 with a page fault;
   it had a volatile pointer local, `__IZ + constant` and `((unsigned int *)__XIZ)[n]`.  5b and 5c both use
   `__IZ + constant`; only 5c uses the indexed __XIZ read.) */

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
    ram_100002 = ((unsigned int *)__XIZ)[7];
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
    ram_100002 = ((unsigned int *)__XIZ)[2] & ~0x8000;
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
    ram_100002 = ((unsigned int *)__XIZ)[32];
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
    ram_100002 = ((unsigned int *)__XIZ)[33];
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
    ram_100002 = ((unsigned int *)__XIZ)[28];
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
    ram_100002 = ((unsigned int *)__XIZ)[23];
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
        ram_100002 = ((unsigned int *)__XIZ)[28];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = reg + 0x600;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = ((unsigned int *)__XIZ)[33];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

void ToneGen_WriteEnvSegments(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x880;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteSegRegs_SameLevel(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x880;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x100;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x140;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[30];
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
    ram_100002 = p[31];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)((unsigned long)p + 45);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[30] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x580;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[30];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x580;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[30] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[30] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x580;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[30];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x600;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[32];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x580;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[30] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: TG_Write_ExtParam_05C0_Strobe=ToneGen_Write_ExtParam_05C0_Strobe */
void TG_Write_ExtParam_05C0_Strobe(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[31] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x5c0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[31];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x5c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[31] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x540;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[29];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x540;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[29] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x540;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[29];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x1c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[28];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x540;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[29] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p)
{
    (void)&p;
    __IZ = reg;
    if (p[31] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = __IZ + 0x5c0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[31];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x640;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[33];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x5c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[31] & ~0x8000;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
