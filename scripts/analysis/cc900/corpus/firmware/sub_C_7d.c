/* lane_sub probe round 7, helper C, bisection file d: tone-generator writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s) with ONE suspect spelling for round 6's V4.23 crash (page fault, read at
   0x630, in files holding __IZ plus a record pointer kept in memory): __IZ for the register number and `(void)&p` for the record pointer.
   7d = __IZ + (void)&p, 7e = __IZ + array, 7f = register local, 7g = (void)&p alone, 7h = array alone. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

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
