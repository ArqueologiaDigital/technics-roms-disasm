/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_C_5a.c (2026-11-16-65-sub-r5)
   sha256 1dc45ce41cbbfc77d740f571e433bbd96f6fc1906c2d331551b44786d759b6ab (name+funcs); compiled at -Xr */
/* lane_sub probe round 5, helper C, form a: refinements of round 4's near misses, and the two tone-generator writers
   that keep a data word in IZ (helper B's matched spelling `__IZ = d; ... ram_100002 = __IZ;`), for the KN5000 sub-CPU
   payload v1.42 (core/08_voice_noteon_and_tonegen.s).  Names are the tree's labels; ram_<hex> is a RAM cell
   (sub-CPU address) the tree has not named. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);

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

void ToneGen_WriteExprReg(unsigned int reg, unsigned int v)
{
    __IZ = v;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x180;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

int CheckStatusBits_40(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x40;
}

int CheckStatusBits_80(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x80;
}

int Voice_Part_Mode_Is_C0(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0xc0;
}

void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    unsigned char *mm;
    p = *(unsigned char **)(ram_4136e + m[1] * 0x11f);
    p += (unsigned long)(unsigned int)m[2];
    *p = m[4];
    mm = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(p, 1, (unsigned char *)((unsigned long)mm + 0x4980) + (unsigned long)(unsigned int)m[2]);
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *row;
    row = ram_44fce + ((int)((m[2] & 0xc0) >> 6) * 11 + 426);
    row += m[2] & 0x3f;
    *row = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

void InterCPU_SendEditBufferToMain(unsigned char part)
{
    unsigned int n = 470;
    unsigned char *mainram = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(ram_4531c + ((int)part * 80 + 19111), n, mainram + (long)((int)part * 80 + 19111));
}

void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    ram_4531c[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = (unsigned char *)((unsigned long)((unsigned char *)((unsigned long)k * 21) + (int)sel * 80)
                                + (unsigned long)ram_4531c) + 19127;
        q = ram_44fce + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
