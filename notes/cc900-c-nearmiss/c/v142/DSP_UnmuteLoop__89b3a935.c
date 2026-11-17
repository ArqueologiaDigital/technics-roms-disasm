/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_D_2c.c (2026-11-16-47-sub-r2)
   sha256 89b3a935e3ab975be60286aab4149c1177eec2f8174b154e1a4588340e2db5ab (name+funcs); compiled at -O3 -Xr */
/* lane_sub probe round 2, helper D, form c (form a with a third spelling of some functions; uses V4.23's
   pseudo-register __WA, so it is kept apart from forms a / b): the DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.
   Working guesses behind the spellings:
   - an unsigned int index is zero-extended to 32 bits and added (`extz xwa; ld xbc, T; add xbc, xwa`), an int
     index uses the register-indexed form (`(xhl+wa)`); so loop counters are unsigned int unless a signed test shows;
   - V4.23 evaluates the right operand of a binary operator first (Extract_14Bit_*, DSP_Pack3x7bitFields);
   - a call directly followed by the function's exit (or `return;`) becomes `j` (probe elrd's er_b_iaAG), a call
     followed by a label stays `cal` + `ret`;
   - switch cases are compared in reverse source order (v10 AudioInit_SelectPriority).
   The config record at 0x448e (and its copies at 0x45ca, 0x46ec, 0x480e: 145 words) holds four words and five
   56-byte effect-slot records; the 50-byte records at 0x4940 hold per-slot flags. */

struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct o16 { char pad[16]; unsigned int v; char pad2[32]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct cfgimg { int w[0x91]; };

extern struct cfg __near ram_448e;
extern struct slot __near ram_4496[];
extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d0;
extern unsigned int __near ram_45bc[];
extern unsigned int __near ram_454a;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern unsigned int __near ram_4504;
extern unsigned int __near ram_453c;
extern unsigned int __near ram_4574;
extern unsigned int __near ram_45ac;
extern unsigned int __near ram_45b0;
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near ram_4488;
extern unsigned int __near ram_448a;
extern unsigned int __near ram_448c;
extern unsigned int __near ram_4930[];
extern unsigned int __near ram_493a[];
extern unsigned int __near ram_493e;
extern struct e50 __near ram_4940[];
extern int __near ram_4944[][25];
extern struct o16 __near ram_4958[];
extern struct o16 __near ram_495a[];
extern struct o16 __near ram_495c[];
extern struct o16 __near ram_495e[];
extern struct o16 __near ram_4960[];
extern unsigned int __near ram_3b60;
extern unsigned int __near ram_3b62;
extern unsigned int __near ram_3b64;
extern unsigned char __near ram_3b66[];
extern unsigned int __near ram_2b0d;
extern unsigned int __near ram_2b11;
extern unsigned char __near ram_2b13[];
extern unsigned long __near ram_1040;
extern unsigned char ram_41377;
extern unsigned char ram_4137a;
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char *ram_4531c;
extern unsigned char *ram_45320;
extern unsigned char ram_7800[];
extern int ram_45566;
extern int ram_45444;

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
extern unsigned char DSP_EffectClass_Table[];
extern unsigned char DSP_AlgoInit_NoteOnMsg_Algo1[], DSP_AlgoInit_NoteOnMsg_Algo2[], DSP_AlgoInit_NoteOnMsg_Default[];
extern unsigned char DSP1_ImageHeader_SoundRAM[];

extern void BootROM_DEBUG_OUTPUT_STRING(char *);
extern void BootROM_HEX_BYTE_TO_ASCII(int);
extern void DSP_WriteEFFConfig(unsigned int, unsigned char *);
extern void DSP_WriteGlobalConfig(unsigned int, unsigned char *);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, struct cfg *);
extern void DSP_State_ApplyBuf(struct cfg *);
extern void DSP_ApplyAlgoForVoiceType(unsigned int);
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
extern void MIDI_Dispatch(void);
extern void DSP_FlushAllSlots(int, int);
extern void DSP_AlgorithmChange(void);
extern void DSP1_Deassert_Reset(void);
extern void DSP2_Deassert_Reset(void);
extern void DSP1_Assert_Reset(void);
extern void DSP2_Assert_Reset(void);
extern void DSP_State_ApplyTask(void);
extern void Kernel_SemaWait(int);
extern void Kernel_YieldRotate(int);
extern void DSP_ScheduleDelay(int);

/* ---- debug output through the boot ROM ---- */

void Debug_Print_String(char *s)
{
    BootROM_DEBUG_OUTPUT_STRING(s);
    __WA = 0;
}

void Debug_Print_Byte(unsigned char b)
{
    BootROM_HEX_BYTE_TO_ASCII(b);
    __WA = 0;
}

void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)w);
    __WA = 0;
}

/* ---- leaf routines ---- */

void DSP2_Init(void)
{
    ram_3b64 = 0;
    ram_3b60 = ram_3b62 = 0;
}

int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n) {
        i = r->r++ & 0x7ff;
        c = r->buf[i];
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
        c = r->buf[i];
        r->n--;
    } else
        c = -1;
    return c;
}

unsigned int Extract_14Bit_PayloadSize(unsigned char *p)
{
    unsigned int r;

    r = ((p[5] & 0x7f) << 7) | (p[6] & 0x7f);
    return r;
}

unsigned int Extract_14Bit_VoiceParam(unsigned char *p)
{
    return ((p[2] & 0x7f) << 7) | (p[3] & 0x7f);
}

unsigned long DSP_Pack3x7bitFields(unsigned char *p)
{
    return (unsigned long)(unsigned char)(p[3] & 0x7f)
        | ((unsigned long)(unsigned char)(p[1] & 0x7f) << 14 | (unsigned long)(unsigned char)(p[2] & 0x7f) << 7);
}

unsigned int DSP_State_LookupAlgoIndex(unsigned int i)
{
    return DSP_EffectClass_Table[i];
}

int EFF_ConfigSnapshot_Save(void)
{
    *(struct cfgimg *)0x480e = *(struct cfgimg *)0x46ec;
    return 0;
}

int EFF_ConfigSnapshot_Restore(void)
{
    *(struct cfgimg *)0x46ec = *(struct cfgimg *)0x480e;
    return 0;
}

struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        return &ram_4496[i];
    default:
        return (struct slot *)0xffffffff;
    }
}

unsigned int DSP_SlotMuteState_ReadAndClear(unsigned int i)
{
    unsigned int r;

    r = ram_45bc[i];
    ram_45bc[i] = 0;
    return r;
}

unsigned char *CalcSampleAddr(unsigned char *p)
{
    unsigned int lo;
    unsigned int v;

    lo = p[1] & 0xff;
    v = ((p[0] << 8) & 0xff00) + lo;
    if ((v >> 8) != 240)
        p += v;
    return p;
}

void DSP_AlgoChange_CheckAndFlag(struct cfg *p)
{
    if (p->f6 != ram_45d0 || p->f2 == 1 || p->f4 == 1)
        ram_493e = 1;
    else
        ram_493e = 0;
}

void DSP_SlotParam_DiffAndFlag(struct cfg *p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (p->s[i].type != ram_45d2[i].type)
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
        if (p->s[i].type > 0x63)
            p->s[i].type = 0x63;
}

int DSP_Config_DeadTail_SumWords(void)
{
    return ram_45566 + ram_45444;
}

void EFF_DSPLink_ResetFlags(void)
{
    unsigned int i;

    if (ram_493e == 1) {
        ram_493a[0] = 1;
        for (i = 1; i < 2; i++)
            ram_493a[i] = 0;
    } else {
        for (i = 0; i < 2; i++)
            ram_493a[i] = 0;
    }
}

void EFF_SlotActive_UpdateFlags(struct cfg *p)
{
    unsigned int i;
    unsigned int found;
    unsigned int t;

    found = 0;
    if (ram_493e == 1) {
        for (i = 0; i < 5; i++)
            ram_4930[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            t = p->s[i].type;
            if (t == 0x33 || t == 0x34 || t == 0x45 || t == 0x46)
                found = 1;
            if (ram_4940[i].f0 == 1 || (p->f0 == 1 && ram_4960[i].v == 1) || (ram_4960[i].v == 1 && found == 1)) {
                ram_4930[i] = 1;
                ram_4944[i][p->s[i].param[17]] = 1;
                ram_495a[i].v = 1;
                ram_495c[i].v = 1;
                ram_4960[i].v = 1;
                if (p->s[i].param[22] != 0x63)
                    ram_4958[i].v = 1;
            } else
                ram_4930[i] = 0;
        }
    }
}

unsigned int DSP_GetEffectRouting(void)
{
    unsigned int r;

    r = 0;
    if (ram_41377 != 0)
        r |= ram_41377 << 8;
    if (ram_4137a != 0)
        r |= ram_41377;
    return r;
}

void DSP_ResetAlgoDefaults(void)
{
    unsigned int i;

    for (i = 0; i < 16; i++)
        ram_4531c[i] = DSP1_ImageHeader_SoundRAM[i];
}

void DSP_ResetWriteBufferPtr(void)
{
    ram_45320 = ram_7800;
    ram_4531c = ram_7800;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *base;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    return base + ((unsigned long *)(base + *(unsigned long *)(base + 8)))[n];
}

int __cdecl Audio_CmdHandler_00_1F(int n, unsigned char *p)
{
    while (n != 0) {
        ram_2b13[ram_2b0d++ & 0xfff] = *p;
        ram_2b11++;
        n--;
        p++;
    }
    return 0;
}

int __cdecl Audio_CmdHandler_60_7F(int n, unsigned char *p)
{
    unsigned int i;

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
        ram_4488 = p[6] + ((p[5] & 0x7ff) << 7) + 8;
        ram_448a += 32;
        ram_448c = 1;
    } else {
        ram_448a = 0;
        ram_448c = 0;
    }
    for (i = 0; i < n; i++) {
        ram_3b66[ram_3b60++ & 0x7ff] = *p++;
        ram_3b64++;
    }
    return 0;
}

/* ---- calls ---- */

void DSP_WakeAudioTask(void)
{
    Kernel_SemaWait(1);
}

struct cfg *DSP_GetConfigBuffer(void)
{
    return &ram_448e;
}

void Task3_EnterDspApplyLoop(void)
{
    DSP_State_ApplyTask();
}

void DSP2_InitTask_NullStub(void)
{
    return;
}

void DSP_Stub_RetB(void)
{
}

void DSP_Stub_RetC(void)
{
}

void DSP_ResetTask_NullStub(void)
{
}

void DSP_AlgorithmChangeCheck(void)
{
    if (ram_493e == 1)
        DSP_AlgorithmChange();
}

void DSP_WaitForDelay(unsigned int t)
{
    unsigned long target;

    target = (((unsigned long)t + 1) >> 1) + ram_1040;
    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}

void DSP_Set_DigitalReverbOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_4504 = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_AcousticIllusionOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_453c = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_MicReverbOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_4574 = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_EqualizerOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_45ac = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_RotarySpeed(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_45b0 = v;
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

void DSP_ReconfigAndStatus(void)
{
    DSP_State_ApplyBuf(&ram_448e);
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

int DSP_Set_MixParam_45B2(unsigned char v)
{
    ram_45b2 = v;
    return DSP_MixerCoeff_Compute(v, ram_45b4, ram_45b6);
    return ram_45b2;
}

int DSP_Set_MixParam_45B4(unsigned char v)
{
    ram_45b4 = v;
    return DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b4;
}

int DSP_Set_FadeLevel(unsigned char v)
{
    ram_45b6 = v;
    return DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b6;
}

void DSP_ApplyConfig(unsigned char mode, unsigned char unused, unsigned char flag)
{
    if (flag == 0xff)
        ram_448e.f0 = 1;
    else
        ram_448e.f0 = 0;
    switch (mode) {
    case 0:
        DSP_State_ApplyBuf(&ram_448e);
        DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
        return;
    case 1: case 2: case 4:
        DSP_State_ApplyBuf(&ram_448e);
        return;
    case 3:
        ram_454a = ram_45ba == 0 ? 0 : ram_45b8;
        DSP_State_ApplyBuf(&ram_448e);
        break;
    }
}

void DSP_FlushAllSlots_ForPart(unsigned char part)
{
    DSP_FlushAllSlots(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
}

void DSP_WriteAlgoInitPreset(unsigned int x)
{
    unsigned int a;

    a = DSP_State_LookupAlgoIndex(x);
    if (a == 2)
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Algo2);
    else if (a == 1)
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Algo1);
    else
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Default);
    MIDI_Dispatch();
}

void DSP_SlotState_DisplayRestore(void)
{
    unsigned int s;

    s = DSP_SlotMuteState_ReadAndClear(0);
    if (s == 3) {
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Algo2);
        MIDI_Dispatch();
        return;
    }
    if (s == 2) {
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Algo1);
        MIDI_Dispatch();
        return;
    }
    if (s == 1) {
        Audio_CmdHandler_00_1F(4, DSP_AlgoInit_NoteOnMsg_Default);
        MIDI_Dispatch();
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
    Debug_Print_Word(p->s[slot].param[idx]);
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
        Debug_Print_Word(p->s[slot].param[idx]);
        if (p->s[slot].on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = p->s[slot].param[idx];
            p->s[slot].param[idx] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            p->s[slot].param[idx] = t;
        }
    }
}

/* ---- the per-slot / per-chip loops ---- */

void DSP_ResetLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        DSP_Reset_WithDebug(i);
}

void DSP_MuteLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        if (ram_493a[i] == 1)
            DSP_Mute_WithDebug(i);
}

void DSP_UnmuteLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        if (ram_493a[i] == 1)
            DSP_Unmute_WithDebug(i);
}

void EFF_MuteLoop(void)
{
    unsigned int i;
    unsigned int muted;

    muted = 0;
    for (i = 0; i < 5; i++) {
        if (ram_4930[i] == 1) {
            if (ram_4940[i].f0 == 1 && DSP_EffectClass_Table[ram_45d2[i].type] != 0)
                ram_45bc[i] = 1;
            EFF_Mute_WithDebug(i);
            muted = 1;
        }
    }
    if (muted == 1)
        DSP_ScheduleDelay(20);
}

void EFF_LinkLoop(struct cfg *p)
{
    int i;

    for (i = 4; i > -1; i--)
        if (ram_495e[i].v == 1 && p->s[i].on == 1)
            EFF_Link(i, p->f6);
}

void EFF_DisconnectLoop(struct cfg *p)
{
    int i;

    for (i = 4; i > -1; i--)
        if (i != 3 && i != 2)
            EFF_Disconnect(i, p->f6);
}

void EFF_VolumeLoop(struct cfg *p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (ram_4944[i][p->s[i].param[17]] == 1) {
            d = p->s[i].param[17];
            if (p->s[i].type == 0x3f) {
                p->s[i].param[0] = p->s[i].param[0] - EFF_VolumeReduction_Steps[p->s[i].param[1]];
                if (p->s[i].param[0] < 0)
                    p->s[i].param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, p->s[i].type, d, p);
        }
    }
}
