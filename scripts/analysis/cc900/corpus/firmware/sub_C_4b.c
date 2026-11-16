/* lane_sub probe round 4, helper C, form b: other spellings of sub_C_4a.c's functions (KN5000 sub-CPU
   payload v1.42 (core/08_voice_noteon_and_tonegen.s, core/10_dsp_voice_params.s)).  Names are the tree's labels;
   ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   Round 3 (run 2026-11-16-58-sub-r3) showed that V4.23 also aligns array members of a struct to an even offset, so
   the payload's odd field offsets (19111, 0x13, 1) are written as integer addresses, after the HD-AE5000 lane's
   idiom `(T *)((unsigned long)p + offset)`, which keeps V4.23 from folding the offset into the index. */

extern unsigned int ram_41343;                  /* Voice_GlobalFlags */
extern unsigned char ram_41368[];               /* Part_Record_Base: flags word */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413c9[];
extern unsigned char ram_413d3[];
extern unsigned char ram_413d4[];
extern unsigned char ram_451a4;
extern char ram_451ab;
extern char ram_451ac;
extern unsigned char *ram_45310;
extern long *ram_45314;
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrt { unsigned char pad[26]; unsigned int w[128]; };

extern unsigned char DSP_AlgoDescriptor_Records[][0x27];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_CurvePool[];

extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);

void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab * 4;
    else ram_413d3[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) ram_413d4[part * 0x11f] = ram_451ac * 4;
    else ram_413d4[part * 0x11f] = 0;
}

void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[(int)slot] = (unsigned int)ch | 0xc0;
        else p->w[(int)slot] = (unsigned int)ch | 0x40;
    }
}

void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[(int)slot] = ch | 0xc000;
        else p->w[(int)slot] = ch | 0x4000;
    }
}

void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[(int)slot] = ch | 0x3300;
        else p->w[(int)slot] = ch | 0x1100;
    }
}

void DSP_SetCoeff_CopyDirect(unsigned int k)
{
    unsigned int i;
    unsigned char *src;
    unsigned int n;
    src = (unsigned char *)((unsigned long)ram_45310 + ram_45314[32]);
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void DSP_SetCoeff_CopyDirect2(unsigned int k)
{
    unsigned int i;
    unsigned char *src;
    unsigned int n;
    src = (unsigned char *)((unsigned long)ram_45310 + ram_45314[35]);
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    ((unsigned char *)((unsigned long)ram_44fce + ((int)((m[2] & 0xc0) >> 6) * 11 + 426)))[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    unsigned char *mm;
    p = *(unsigned char **)(ram_4136e + m[1] * 0x11f);
    p += (unsigned long)m[2];
    *p = m[4];
    mm = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(p, 1, &mm[0x4980] + (unsigned long)m[2]);
}

void InterCPU_SendEditBufferToMain(unsigned char part)
{
    unsigned char *mainram = (unsigned char *)0x1e0000;
    unsigned int n = 470;
    InterCPU_E1_DMA_Transfer(ram_4531c + ((int)part * 80 + 19111), n, mainram + (unsigned long)((int)part * 80 + 19111));
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    r = ((unsigned char *)((unsigned long)DSP_AlgoDescriptor_Records[t] + ((int)slot * 5 + 0x13)))[1];
    switch (t) {
    case 8:
        if (slot == 1) r = (*(unsigned char **)(ram_4136e + part * 0x11f))[96];
    }
    return r;
}

void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned int r;
    unsigned char sel;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)sel * 0x66))[(*(unsigned char **)(ram_4136e + part * 0x11f))[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *q;
    unsigned char *rec;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = ram_44fce + ((int)slot * 5 + 480);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}

void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = (unsigned char *)((unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)) + 19127);
    q = ram_44fce + ((int)slot * 5 + 500);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    ram_4531c[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = (unsigned char *)((unsigned long)(ram_4531c + ((unsigned long)k * 21 + (int)sel * 80)) + 19127);
        q = ram_44fce + (k * 5L + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

void Voice_NoteState_Clear(unsigned char part)
{
    unsigned int i;
    unsigned int j;
    if (ram_41343 & 1) return;
    *(unsigned int *)(ram_41385 + part * 0x11f) = 0;
    ram_41387[part * 0x11f] = 0;
    ram_41388[part * 0x11f] = 0;
    ram_41383[part * 0x11f] = 0x40;
    ram_41384[part * 0x11f] = 0x40;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 3; j++) {
            *(unsigned char *)((unsigned long)(ram_41368 + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2)) + 41) = 0;
            *(unsigned char *)((unsigned long)(ram_41368 + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2)) + 42) = 0;
        }
    }
}

int CheckStatusBits_40(unsigned int part)
{
    if (((*(unsigned char **)(ram_4136e + (unsigned long)part * 287UL))[16] & 0xc0) == 0x40) return 1;
    return 0;
}

int CheckStatusBits_80(unsigned int part)
{
    if (((*(unsigned char **)(ram_4136e + (unsigned long)part * 287UL))[16] & 0xc0) == 0x80) return 1;
    return 0;
}

int Voice_Part_Mode_Is_C0(unsigned int part)
{
    if (((*(unsigned char **)(ram_4136e + (unsigned long)part * 287UL))[16] & 0xc0) == 0xc0) return 1;
    return 0;
}
