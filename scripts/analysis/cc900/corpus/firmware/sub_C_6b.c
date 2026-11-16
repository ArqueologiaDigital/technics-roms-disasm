/* lane_sub probe round 6, helper C, form b: more calr callers and other spellings of sub_C_6a.c's functions (KN5000
   sub-CPU payload v1.42), and the two-value tone-generator writers with the record pointer parameter kept in the stack
   frame by taking its address (sub_C_6c.c has them with a one-element local array).

   cc900-module: VoiceAlloc_CheckAndInit ToneDB_Resolve_NamedToneRecord ToneDB_Find_ToneRecord_CoeffPath
   cc900-module: ToneDB_Find_PatchRecord Voice_SecondaryParam_Fetch2 Voice_NoteState_Clear BlockCopy_Words_BC_to_HL */

extern unsigned int ram_41343;                  /* Voice_GlobalFlags */
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_41372[];
extern unsigned char ram_413cf[];
extern unsigned char ram_451a4;
extern char ram_451a6;
extern unsigned char ram_4502b;
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

extern unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
extern void VoiceAlloc_CheckAndInit();
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern unsigned char *WaveSel_StageA1_FindVelSplit();
extern char Voice_SecondaryParam_Fetch2();
extern void Voice_NoteState_Clear();
extern void NoteState_ClearRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);

unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b)
{
    if (ram_41343 & 1) return ToneDB_Find_ToneRecord_CoeffPath(a, b);
    return ToneDB_Find_PatchRecord(a, b);
}

void VoiceAlloc_WithRoutingFlag(unsigned char part, unsigned char flag)
{
    VoiceAlloc_CheckAndInit(part);
    if (flag != 0) ram_4502b |= 0x80;
    else ram_4502b &= ~0x80;
}

unsigned char *ToneDB_Find_SubToneRecord(unsigned char *p, unsigned char c, unsigned char e)
{
    unsigned int x;
    unsigned int y;
    x = p[(int)c * 2 + 39];
    y = (p + ((int)c * 2 + 39))[1];
    return ToneDB_Resolve_NamedToneRecord(x, y, c, e);
}

void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             (unsigned char *)((unsigned long)(ram_4531c + ((int)d * 80 + (int)a * 11)) + 19169),
                             *(unsigned int *)(ToneDB_RootPtr + 240));
}

void Voice_ActiveFlag_CheckAndLoad(unsigned char part)
{
    char v = 0;
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) v = ram_451a6 * 4;
    if ((unsigned long)*(unsigned int *)(ram_41372 + part * 0x11f) & 0x8000) v = v + Voice_SecondaryParam_Fetch2(part);
    ram_413cf[part * 0x11f] = v;
}

void VoiceSlot_ClearAll(void)
{
    unsigned char p;
    unsigned int j;
    unsigned int i;
    for (p = 0; p < 26; p++) {
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 3; j++) {
                ((unsigned char *)((unsigned long)(ram_41368 + p * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[39] = 0;
                ((unsigned int *)((unsigned long)(ram_41368 + p * 0x11f) + ((unsigned long)i * 37 + (unsigned long)j * 2)))[68] = 0;
            }
        }
        Voice_NoteState_Clear(p);
    }
    for (i = 0; i < 64; i++) {
        for (j = 0; j < 3; j++) NoteState_ClearRecord((unsigned char)i, (unsigned char)j);
    }
    ram_451a4 = 0xff;
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
