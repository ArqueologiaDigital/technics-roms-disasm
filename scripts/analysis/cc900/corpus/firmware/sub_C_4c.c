/* lane_sub probe round 4, helper C, form c: four tone-generator register writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s) with the ROM's register save.  The ROM keeps the value or record pointer
   that is still needed after the inline nop in IZ / XIZ (`push xiz; ld xiz,xbc`), and in WriteEnvSegments the second
   one on the stack.  V4.23 does not treat __ASM as clobbering registers, so here the code names the register itself
   through cc900's pseudo-register variables (__IZ, __XIZ; __WA worked for helper D), which should make V4.23 save
   and restore it.  WriteEnvSegments also keeps the record pointer in a volatile local, for the stack slot. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v)
{
    __IZ = v;
    ram_18 &= ~0x80;
    ram_100000 = reg;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
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
    unsigned int * volatile q;
    q = p;
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x880;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
