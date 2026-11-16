/* lane_sub probe round 2, helper C, form a: functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu,
   core/08_voice_noteon_and_tonegen.s and core/10_dsp_voice_params.s).  Names are the tree's labels; ram_<hex> is a
   RAM cell (sub-CPU address) the tree has not named.  The 287-byte part records (0x41368 + part * 0x11f) are
   indexed as char arrays, one array per field. */

extern unsigned char ram_41368[];               /* Part_Record_Base: flags word */
extern unsigned char ram_4136a[];               /* Part_PresentWord */
extern unsigned char ram_4136c[];
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr: the part's patch record */
extern unsigned char ram_41372[];
extern unsigned char ram_413d0[];
extern unsigned char ram_413d1[];
extern unsigned char ram_413d2[];
extern unsigned char ram_413d3[];
extern unsigned char ram_413d4[];
extern unsigned char ram_451a4;
extern unsigned char ram_451a7;
extern unsigned char ram_451a8;
extern unsigned char ram_451a9;
extern unsigned char ram_451ab;
extern unsigned char ram_451ac;
extern unsigned char ram_45216;
extern unsigned char ram_45217;
extern unsigned char *ram_45310;
extern long *ram_45314;
extern unsigned char *ram_4531c;

struct dspglob { char pad[426]; unsigned char t[4][11]; };
extern struct dspglob ram_44fce;

struct algsub { unsigned char a; unsigned char b; unsigned char c; unsigned char d; unsigned char e; };
struct algrec { char pad[0x13]; struct algsub s[4]; };
extern struct algrec DSP_AlgoDescriptor_Records[];
extern unsigned char Voice_SecondaryParam_Curve[];

extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);

#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
#define PART_PRESENT(p) (*(unsigned int *)(ram_4136a + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41372 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))

int DSP_ReadVoiceParam5D(unsigned int a, unsigned int b, unsigned char *out)
{
    *out = ToneDB_Find_ToneRecord(a, b)[93];
    return 1;
}

int DSP_ReadVoiceParam11(unsigned int a, unsigned int b, unsigned char *out)
{
    *out = ToneDB_Find_ToneRecord(a, b)[17];
    return 1;
}

int DSP_EffectStateQuery(unsigned char part, unsigned char *out)
{
    if (PART_FLAGS(part) & 1) *out = 1;
    else *out = 0;
    return 1;
}

unsigned char Voice_SecondaryParam_Epilogue(unsigned char part)
{
    unsigned char r = 0;
    if (PART_W72(part) & 0x8000L) r = PART_PATCH(part)[101];
    return r;
}

unsigned char Voice_SecondaryParam_Fetch(unsigned char part)
{
    if (PART_W72(part) & 0x8000L) {
        if ((PART_PATCH(part)[93] & 0xf) == 9) return Voice_SecondaryParam_Curve[PART_PATCH(part)[94]];
        else return 0xff;
    }
    return 0xff;
}

/* cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
char Algo_PanTrim_From_PartFlags(unsigned char part, unsigned char side)
{
    if (PART_PRESENT(part) & 0xc000L) {
        switch (side) {
        case 0: return -4;
        case 1: return -16;
        default: return 0;
        }
    }
    return 0;
}

void Voice_ActiveFlag_Set(unsigned char part)
{
    PART_FLAGS(part) &= ~3;
    PART_FLAGS(part) |= 4;
    ram_4136c[part * 0x11f] = 0;
}

unsigned int AlgoType_AB_Checker(unsigned char part)
{
    unsigned int r = 0;
    switch (PART_PATCH(part)[93] & 0xf) {
    case 10:
    case 11:
        r = PART_PATCH(part)[95] & 0x3f;
    }
    return r;
}

int DSP_SetCoeff_WriteParams(unsigned char part)
{
    int r = 2;
    ram_45216 = PART_PATCH(part)[16];
    if ((PART_PATCH(part)[93] & 0xf) == 12) ram_45217 = PART_PATCH(part)[95];
    else ram_45217 = 0;
    return r;
}

void DSP_SlotParam_Write_Slot0(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d0[part * 0x11f] = ram_451a7 << 1;
    else ram_413d0[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot1(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d1[part * 0x11f] = ram_451a8 << 1;
    else ram_413d1[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot2(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d2[part * 0x11f] = ram_451a9 << 1;
    else ram_413d2[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab << 1;
    else ram_413d3[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d4[part * 0x11f] = ram_451ac << 1;
    else ram_413d4[part * 0x11f] = 0;
}

void SlotRouting_WriteSingle(unsigned int *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if (f & 0x20) {
        if (((f & 0xc0) >> 6) == ch) {
            if (f & 0x10) p[slot + 13] = ch | 0xc0;
            else p[slot + 13] = ch | 0x40;
        }
    }
}

void SlotRouting_Chan1(unsigned int *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if (f & 0x20) {
        if (((f & 0xc0) >> 6) == ch) {
            if (f & 0x10) p[slot + 13] = ch | 0xc000;
            else p[slot + 13] = ch | 0x4000;
        }
    }
}

void SlotRouting_Chan3(unsigned int *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if (f & 0x20) {
        if (((f & 0xc0) >> 6) == ch) {
            if (f & 0x10) p[slot + 13] = ch | 0x3300;
            else p[slot + 13] = ch | 0x1100;
        }
    }
}

void DSP_SetCoeff_CopyDirect(unsigned int k)
{
    unsigned char *src;
    unsigned int n;
    unsigned int i;
    src = ram_45310 + ram_45314[32];
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void DSP_SetCoeff_CopyDirect2(unsigned int k)
{
    unsigned char *src;
    unsigned int n;
    unsigned int i;
    src = ram_45310 + ram_45314[35];
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    ram_44fce.t[(m[2] & 0xc0) >> 6][m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) > 10) return;
}

void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    p = PART_PATCH(m[1]) + m[2];
    *p = m[4];
    InterCPU_E1_DMA_Transfer(p, 1, (unsigned char *)0x1e0000 + 0x4980 + m[2]);
}

void InterCPU_SendEditBufferToMain(unsigned char part)
{
    unsigned char *mainram = (unsigned char *)0x1e0000;
    unsigned int n = 470;
    InterCPU_E1_DMA_Transfer(ram_4531c + (part * 80 + 19111), n, mainram + (part * 80 + 19111));
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = PART_PATCH(part)[93] & 0xf;
    r = DSP_AlgoDescriptor_Records[t].s[slot].b;
    if (t == 8) {
        if (slot == 1) r = PART_PATCH(part)[96];
    }
    return r;
}

void Voice_DSPOut_Second_B(unsigned char part)
{
    switch (PART_PATCH(part)[93] & 0xf) {
    case 4:
    case 5:
        Voice_DSP_OutputConfig2(part, 1);
        break;
    case 7:
        if (PART_W72(part) & 0x4000) Voice_DSP_OutputConfig2(part, 1);
        break;
    }
}
