/* lane_sub probe round 3, helper D, form b (other spellings of form a, see VARIANTS): DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.
   Refinements of round 2's misses (run 2026-11-16-47-sub-r2) and new functions.  The spellings that differ between
   forms a / b / c are the macros of the VARIANTS block.
   Layout guesses:
   - 0x448e / 0x45ca / 0x46ec / 0x480e: config record, four words then five 56-byte slot records (type, a[1],
     param[17], idx, q[1], r42[6], on).  An access with a variable second index (param[j]) reads in the ROM as a 2-D
     array: column * 2 + row * 56 + base, one displacement (8 + member) -- hence the union views A / P / Q;
   - 0x4930: the effect flag block: active[5], chip[2], algo-changed word, then five 50-byte records (f0, a[1],
     flags[17], q[1], g[5]); the ROM reaches g[k] as lda (block + 40 + 2k) plus 16 + row * 50. */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg {
    unsigned int f0, f2, f4, f6;
    union {
        struct slot s[5];
        struct { int pad; unsigned int a[5][28]; } A;
        struct { int pad[2]; int param[5][28]; } P;
        struct { int pad[20]; int q[5][28]; } Q;
    } u;
};
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct part { unsigned char *patch; char pad[283]; };

/* ---- VARIANTS ---- */
#define SX(i)           ((unsigned long)(i))
#define S(p, i)         (*(struct slot *)((char *)(p) + SX(i) * 56 + 8))
#define SS(p, i)        ((p)->u.s[i])
#define PRM(p, i, j)    ((p)->u.s[SX(i)].param[j])
#define PA(p, i, j)     ((p)->u.s[SX(i)].a[j])
#define PQ(p, i, j)     ((p)->u.s[SX(i)].q[j])
#define G(i, k)         (G_##k[i][8])
#define NON(i)          (ram_4600[i][4])
#define MSGQ
#define MSG(x)          (x)
#define CMDH_PROTO      int Audio_CmdHandler_00_1F(int n, unsigned char *p, ...)
#define PATCH(i)        (ram_4136e[i].patch)
#define PATCHDECL       extern struct part ram_4136e[]
#define GDECL(x)        extern unsigned int __near x[][25]
#define G_0             ram_4958
#define G_1             ram_495a
#define G_2             ram_495c
#define G_3             ram_495e
#define G_4             ram_4960
#define NONDECL         extern int __near ram_4600[][28]
/* ---- end of VARIANTS ---- */

extern struct cfg __near ram_45ca;
extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern struct slot __near ram_4496[];
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near ram_4488;
extern unsigned int __near ram_448a;
extern unsigned int __near ram_448c;
extern struct fxflags __near ram_4930;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
GDECL(ram_4958);
GDECL(ram_495a);
GDECL(ram_495c);
GDECL(ram_495e);
GDECL(ram_4960);
NONDECL;
extern unsigned int __near ram_493e;
extern struct ring2k __near ram_3b60;
extern struct ring4k __near ram_2b0d;
extern unsigned long __near ram_1040;
extern unsigned char ram_41377;
extern unsigned char ram_4137a;
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
PATCHDECL;

extern char Str_EffMute_Prefix[], Str_EffMute_Suffix[];
extern char Str_DspMute_Prefix[], Str_DspMute_Suffix[];
extern char Str_DspUnmute_Prefix[], Str_DspUnmute_Suffix[];
extern char Str_DspReset_Prefix[], Str_DspReset_Suffix[];
extern char Str_DspAntiReset_Prefix[], Str_DspAntiReset_Suffix[];
extern char Str_EffHeader_Prefix[], Str_EffHeader_Suffix[];
extern char Str_EffDisconnect_Prefix[], Str_EffDisconnect_Suffix[];
extern char Str_EffLink_Prefix[], Str_EffLink_Suffix[];
extern char Str_EffDataChange_Prefix[], Str_EffDataChange_Suffix[];
extern char Str_EffParamEdit_Prefix[], Str_EffParamEdit_Mid[], Str_EffParamEdit_Suffix[];
extern char Str_EffChange_Prefix[], Str_EffChange_Suffix[];
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char *EFF_Mute_Program_PtrTable[];
extern unsigned char *DSP_Mute_Program_PtrTable[];
extern unsigned char *DSP_Unmute_Program_PtrTable[];
extern unsigned char *EFF_Disconnect_Program_PtrTable[][3];
extern unsigned char *EFF_Link_Program_PtrTable[][3];
extern unsigned char *EFF_CoefProgram_PtrTable[];
extern unsigned char *EFF_AlgoProgram_PtrTable[];
extern unsigned char EFF_SlotToChip_Table[];
extern unsigned char EFF_Header_Program[];
extern unsigned char DSP_Eff09_Slot1_Algo_Bytecode[], DSP_Eff09_Slot1_Coef_Bytecode[];
extern unsigned char DSP_Eff10_Slot1_Algo_Bytecode[], DSP_Eff10_Slot1_Coef_Bytecode[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];
extern MSGQ unsigned char DSP_AlgoInit_NoteOnMsg_Algo1[];
extern MSGQ unsigned char DSP_AlgoInit_NoteOnMsg_Algo2[];
extern MSGQ unsigned char DSP_AlgoInit_NoteOnMsg_Default[];

/* staged or outside this file */
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern unsigned int DSP_State_LookupAlgoIndex(unsigned int);
extern unsigned int DSP_SlotMuteState_ReadAndClear(unsigned int);
extern void BootROM_HEX_BYTE_TO_ASCII(int);
extern void DSP_WriteEFFConfig(unsigned int, unsigned char *);
extern void DSP_WriteGlobalConfig(unsigned int, unsigned char *);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, struct cfg *);
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
extern void MIDI_Dispatch(void);
extern void DSP1_Deassert_Reset(void);
extern void DSP2_Deassert_Reset(void);
extern void DSP1_Assert_Reset(void);
extern void DSP2_Assert_Reset(void);
extern void Kernel_YieldRotate(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void VoiceSlot_FullInit(int);
extern void Voice_PortamentoTargets_SetAll(int);
extern void VoiceSlot_AltInit(int);

/* ---- leaf routines ---- */

void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII(w & 0xff);
    __WA = 0;
}

void DSP2_Init(void)
{
    unsigned int z;

    ram_3b60.n = 0;
    z = 0;
    ram_3b60.r = z;
    ram_3b60.w = z;
}

int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        c = *(r->buf + (unsigned long)i);
        r->n--;
    } else
        c = -1;
    return c;
}

int RingBuf_ReadByte(struct ring4k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0xfff;
        c = *(r->buf + (unsigned long)i);
        r->n--;
    } else
        c = -1;
    return c;
}

unsigned int Extract_14Bit_PayloadSize(unsigned char *p)
{
    unsigned int lo;
    unsigned int hi;

    lo = p[6];
    lo &= 0x7f;
    hi = p[5];
    hi &= 0x7f;
    return (hi << 7) | lo;
}

unsigned int Extract_14Bit_VoiceParam(unsigned char *p)
{
    unsigned int lo;
    unsigned int hi;

    lo = p[3];
    lo &= 0x7f;
    hi = p[2];
    hi &= 0x7f;
    return (hi << 7) | lo;
}

unsigned char *CalcSampleAddr(unsigned char *p)
{
    unsigned int v;
    unsigned char lo;

    lo = p[1] & 0xff;
    v = (((unsigned int)p[0] << 8) & 0xff00) + lo;
    if ((v >> 8) != 240)
        p += v;
    return p;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *base;
    unsigned long *tbl;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    tbl = (unsigned long *)(base + *(unsigned long *)(base + 8)) + n;
    return base + *tbl;
}

void DSP_SlotParam_DiffAndFlag(struct cfg *p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (S(p, i).type != ram_45d2[i].type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}

void DSP_Config_ClampLimits(struct cfg *p)
{
    unsigned int i;

    if (p->f6 > 1)
        p->f6 = 0;
    for (i = 0; i < 5; i++)
        if (S(p, i).type > 0x63)
            S(p, i).type = 0x63;
}

void DSP_EFFParam_DiffAllAndFlag(struct cfg *p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        G(i, 4) = 0;
        for (j = 0; j < 1; j++) {
            if (PA(p, i, j) != ram_45d4[i][j]) {
                ram_4942[i][j] = 1;
                G(i, 4) = 1;
            } else
                ram_4942[i][j] = 0;
        }
        for (j = 0; j < 17; j++) {
            if (PRM(p, i, j) != ram_45d6[i][j]) {
                ram_4944[i][j] = 1;
                G(i, 4) = 1;
            } else
                ram_4944[i][j] = 0;
        }
        for (j = 0; j < 1; j++) {
            if (PQ(p, i, j) != ram_45fa[i][j]) {
                ram_4966[i][j] = 1;
                G(i, 4) = 1;
            } else
                ram_4966[i][j] = 0;
        }
        if (S(p, i).on != NON(i)) {
            G(i, 3) = 1;
            G(i, 4) = 1;
        } else
            G(i, 3) = 0;
        G(i, 0) = 0;
        G(i, 1) = 0;
        G(i, 2) = 0;
    }
}

void EFF_SlotActive_UpdateFlags(struct cfg *p)
{
    unsigned int i;
    unsigned int found;

    found = 0;
    if (ram_493e == 1) {
        for (i = 0; i < 5; i++)
            ram_4930.active[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (S(p, i).type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (p->f0 == 1 && G(i, 4) == 1) || (G(i, 4) == 1 && found == 1)) {
                ram_4930.active[i] = 1;
                ram_4944[i][S(p, i).idx] = 1;
                G(i, 1) = 1;
                G(i, 2) = 1;
                G(i, 4) = 1;
                if (S(p, i).r42[3] != 0x63)
                    G(i, 0) = 1;
            } else
                ram_4930.active[i] = 0;
        }
    }
}

unsigned int DSP_GetEffectRouting(void)
{
    unsigned int r;

    r = 0;
    if (ram_41377 != 0)
        r |= (unsigned int)ram_41377 << 8;
    if (ram_4137a != 0)
        r |= ram_41377;
    return r;
}

CMDH_PROTO
{
    while (n != 0) {
        ram_2b0d.buf[ram_2b0d.w++ & 0xfff] = *p;
        ram_2b0d.n++;
        n--;
        p++;
    }
    return 0;
}

int __cdecl Audio_CmdHandler_60_7F(unsigned int n, unsigned char *p)
{
    unsigned int i;
    unsigned int size;

    if (ram_448c != 0) {
        if (ram_448c > 1)
            i = 0;
        if (ram_448a + n < ram_4488) {
            ram_448a += n;
            ram_448c++;
        } else {
            ram_448a = 0;
            ram_448c = 0;
        }
    } else if (n == 0x20) {
        ram_4488 = ((unsigned int)(p[5] & 0x7ff) << 7) + p[6] + 8;
        ram_448a += 32;
        ram_448c = 1;
    } else {
        ram_448a = 0;
        ram_448c = 0;
    }
    for (i = 0; i < n; i++) {
        ram_3b60.buf[ram_3b60.w++ & 0x7ff] = *p++;
        ram_3b60.n++;
    }
    return 0;
}

/* ---- calls ---- */

void DSP_WaitForDelay(unsigned int t)
{
    unsigned long target;

    target = ((unsigned long)t + 1) / 2 + ram_1040;

    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}

int DSP_Set_MixParam_45B2(unsigned char v)
{
    return DSP_MixerCoeff_Compute(ram_45b2 = v, ram_45b4, ram_45b6);
    return ram_45b2;
}

void DSP_WriteAlgoInitPreset(unsigned int x)
{
    x = DSP_State_LookupAlgoIndex(x);
    if (x == 2)
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Algo2));
    else if (x == 1)
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Algo1));
    else
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Default));
    MIDI_Dispatch();
}

void DSP_SlotState_DisplayRestore(void)
{
    unsigned int s;

    s = DSP_SlotMuteState_ReadAndClear(0);
    /* form b: the messages go to a variadic Audio_CmdHandler_00_1F */
    if (s == 3) {
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Algo2));
        MIDI_Dispatch();
        return;
    }
    if (s == 2) {
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Algo1));
        MIDI_Dispatch();
        return;
    }
    if (s == 1) {
        Audio_CmdHandler_00_1F(4, MSG(DSP_AlgoInit_NoteOnMsg_Default));
        MIDI_Dispatch();
    }
}

void DSP_VoiceState_Dispatch(void)
{
    unsigned char i;

    for (i = 0; i < 26; i++) {
        if (ram_41382[i * 0x11f] == 0x10 || ram_41382[i * 0x11f] == 0x50) {
            WaveSel_Rebuild_PartCaches(i, ram_41381[i * 0x11f], ram_41382[i * 0x11f]);
            switch (PATCH(i)[16] & 0xc0) {
            case 0x00: case 0xc0:
                VoiceSlot_FullInit(i);
                break;
            case 0x40:
                Voice_PortamentoTargets_SetAll(i);
                VoiceSlot_AltInit(i);
                break;
            case 0x80:
                break;
            }
        }
    }
}

/* ---- the debug-traced DSP / effect commands ---- */

void EFF_Mute_WithDebug(unsigned int slot)
{
    Debug_Print_String(Str_EffMute_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffMute_Suffix);
    DSP_WriteEFFConfig(slot, EFF_Mute_Program_PtrTable[slot]);
}

void DSP_Mute_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspMute_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspMute_Suffix);
    DSP_WriteGlobalConfig(chip, DSP_Mute_Program_PtrTable[chip]);
}

void DSP_Unmute_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspUnmute_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspUnmute_Suffix);
    DSP_WriteGlobalConfig(chip, DSP_Unmute_Program_PtrTable[chip]);
}

void DSP_Reset_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspReset_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspReset_Suffix);
    DSP1_Deassert_Reset();
    DSP2_Deassert_Reset();
    DSP1_Assert_Reset();
    DSP2_Assert_Reset();
    DSP1_Deassert_Reset();
}

void DSP_AntiReset_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspAntiReset_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspAntiReset_Suffix);
    DSP2_Deassert_Reset();
}

void EFF_WriteHeader(unsigned int slot)
{
    unsigned int chip;

    Debug_Print_String(Str_EffHeader_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffHeader_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    if (chip == 0)
        DSP_WriteGlobalConfig(chip, EFF_Header_Program);
}

void EFF_Disconnect(unsigned int slot, unsigned int n)
{
    unsigned int chip;

    Debug_Print_String(Str_EffDisconnect_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffDisconnect_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    DSP_WriteGlobalConfig(chip, EFF_Disconnect_Program_PtrTable[n][slot]);
}

void EFF_Link(unsigned int slot, unsigned int n)
{
    unsigned int chip;

    Debug_Print_String(Str_EffLink_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffLink_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    DSP_WriteGlobalConfig(chip, EFF_Link_Program_PtrTable[n][slot]);
}

void EFF_DataChange_WithDebug(unsigned int slot, unsigned int prog)
{
    Debug_Print_String(Str_EffDataChange_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffDataChange_Suffix);
    Debug_Print_Byte(prog);
    DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[prog]);
}

void EFF_ParamEdit_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, struct cfg *p)
{
    Debug_Print_String(Str_EffParamEdit_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffParamEdit_Mid);
    Debug_Print_Byte(idx);
    Debug_Print_String(Str_EffParamEdit_Suffix);
    Debug_Print_Word(PRM(p, slot, idx));
    DSP_WriteParameter(slot, b, idx, p);
}

void EFF_Change_WithDebug(unsigned int slot, unsigned int eff)
{
    Debug_Print_String(Str_EffChange_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffChange_Suffix);
    Debug_Print_Byte(eff);
    switch (slot) {
    case 1:
        switch (eff) {
        case 9:
            DSP_WriteEFFConfig(slot, DSP_Eff09_Slot1_Algo_Bytecode);
            DSP_WriteEFFConfig(slot, DSP_Eff09_Slot1_Coef_Bytecode);
            break;
        case 10:
            DSP_WriteEFFConfig(slot, DSP_Eff10_Slot1_Algo_Bytecode);
            DSP_WriteEFFConfig(slot, DSP_Eff10_Slot1_Coef_Bytecode);
            break;
        default:
            DSP_WriteEFFConfig(slot, EFF_AlgoProgram_PtrTable[eff]);
            DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[eff]);
            break;
        }
        break;
    default:
        DSP_WriteEFFConfig(slot, EFF_AlgoProgram_PtrTable[eff]);
        DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[eff]);
        break;
    }
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, struct cfg *p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(PRM(p, slot, idx));
        if (S(p, slot).on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = PRM(p, slot, idx);
            PRM(p, slot, idx) = 0;
            DSP_WriteParameter(slot, b, idx, p);
            PRM(p, slot, idx) = t;
        }
    }
}

void EFF_ParamIterator_Process(unsigned int slot, struct cfg *p)
{
    unsigned int n;
    unsigned int i;
    unsigned char *q;

    switch (S(p, slot).type) {
    default:
        n = S(p, slot).r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if (ram_4944[slot][i] == 1 && i != S(p, slot).idx)
                EFF_ParamEdit_WithDebug(slot, S(p, slot).type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(S(p, slot).param[13] & 1) * 11];
        while (*q != 12) {
            if (ram_4944[slot][*q] == 1)
                EFF_ParamEdit_WithDebug(slot, S(p, slot).type, *q, p);
            q++;
        }
        break;
    }
}

/* ---- the per-slot loops ---- */

void EFF_LinkLoop(struct cfg *p)
{
    int i;

    for (i = 4; i > -1; i--)
        if (G(i, 3) == 1 && SS(p, i).on == 1)
            EFF_Link(i, p->f6);
}

void EFF_VolumeLoop(struct cfg *p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (ram_4944[i][S(p, i).idx] == 1) {
            d = S(p, i).idx;
            if (S(p, i).type == 0x3f) {
                S(p, i).param[0] = S(p, i).param[0] - EFF_VolumeReduction_Steps[S(p, i).param[1]];
                if (S(p, i).param[0] < 0)
                    S(p, i).param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, S(p, i).type, d, p);
        }
    }
}
