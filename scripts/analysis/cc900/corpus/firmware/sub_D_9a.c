/* lane_sub probe round 9, helper D, form a: KN5000 sub-CPU payload v1.42, core/10_dsp_voice_params.s,
   core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s and core/13_audio_process_dsp_and_effects.s.
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   V4.23 aligns struct members to even offsets, so the 39-byte algorithm descriptors are a 2-D char array. */
/* cc900-module: ToneDB_Resolve_NamedToneRecord WaveSel_StageA1_FindVelSplit WaveSel_StageA2_FindSetDesc DSP_GetEffectRouting DSP_VelocityToVolume DSP_RingBuf_Read DSP_RingBuf_Skip */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct tgparams { int w[0x22]; };

extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __near ram_436d;
extern unsigned char __near ram_436e;
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern unsigned char __tiny ram_44;
extern unsigned int Voice_GlobalFlags;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char *ram_45318;
extern unsigned char ram_a0000[];
extern unsigned char ram_41342[];
extern unsigned char ram_41368[][287];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41399[];
extern unsigned char DSP_AlgoDescriptor_Records[][39];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[];
extern int DSP_ChanFreq_CurvePool[][51];

extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];
extern int ToneGen_Octave_Pitch_Table[];

extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void Debug_Print_Word(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
extern unsigned int DSP_GetEffectRouting(void);
extern unsigned int DSP_VelocityToVolume(unsigned int);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
extern int DSP_RingBuf_Read(struct ring2k *);
extern void DSP_RingBuf_Skip(struct ring2k *);
extern struct cfg *DSP_GetConfigBuffer(void);
extern struct slot *EFF_GetSlotBuffer(unsigned int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern void WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern unsigned char *ToneDB_Resolve_NamedToneRecord(int, int, int, int);
extern void DSP_Config_Init(void);
extern void DSP_Reset(void);
extern void Voice_Reset_Engine(int);
extern void DSP_ResetWriteBufferPtr(void);
extern void VoiceSlot_ClearAll(void);
extern void Voice_ResetAllControllers(void);
void EFF_VolumeUpdate_WithDebug(unsigned int, unsigned int, unsigned int, unsigned long);

unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e)
{
    int x;
    int y;

    x = rec[(int)k * 2 + 0x27];
    y = (&rec[(int)k * 2 + 0x27])[1];
    return ToneDB_Resolve_NamedToneRecord(x, y, k, e);
}

void WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s)
{
    int x;
    int y;

    x = p[1];
    y = p[2];
    WaveSel_StageA1_FindVelSplit(a, (unsigned char)x, (unsigned char)y, e, s);
}

void WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p)
{
    int lo;
    int hi;

    lo = p[(int)z * 2 + 3];
    hi = (p + ((int)z * 2 + 3))[1];
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}

void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;

    lo = (*(unsigned char **)(&ram_41368[part][slot * 37 + 0x6e] + 4))[(int)z * 2 + 3];
    hi = (&(*(unsigned char **)(&ram_41368[part][slot * 37 + 0x6e] + 4))[(int)z * 2 + 3])[1];
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}

unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel)
{
    unsigned long base;
    unsigned long off;
    unsigned int m;

    switch (sel) {
    case 0x00:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0x40:
        base = ToneDB_RootPtr[5];
        off = ToneDB_RootPtr[8];
        m = ((unsigned int *)ToneDB_RootPtr)[120];
        break;
    case 0x80:
        base = ToneDB_RootPtr[4];
        off = ToneDB_RootPtr[7];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0xc0:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    }
    return (unsigned char *)((unsigned long)m * (unsigned int)*(unsigned long *)((unsigned long)(((b << 7) + a) * 2) + base + ToneDB_RelBase) + off + ToneDB_RelBase);
}

void DSP_System_Init(void)
{
    unsigned int i;
    unsigned char *q;

    for (i = 0, q = ram_41342; i < 0x26; i++)
        *q++ = 0;
    for (i = 0, q = ram_41368[0]; i < 0x1d26; i++)
        *q++ = 0;
    MIDI_RingBuffer.w = MIDI_RingBuffer.r = MIDI_RingBuffer.n = 0;
    if (ram_44 & 8)
        Voice_GlobalFlags &= ~8;
    else
        Voice_GlobalFlags |= 8;
    ToneDB_RelBase = 0x50000;
    ToneDB_RootPtr = (unsigned long *)0x50000;
    ram_45318 = ram_a0000;
    DSP_Config_Init();
    DSP_Reset();
    Voice_Reset_Engine(0);
    DSP_ResetWriteBufferPtr();
    VoiceSlot_ClearAll();
    ram_41342[0] = 0;
    Voice_ResetAllControllers();
}

/* cc900-name: ToneDB_FindToneRec_CoeffPath=ToneDB_Find_ToneRecord_CoeffPath */
unsigned char *ToneDB_FindToneRec_CoeffPath(unsigned int a, unsigned int b)
{
    unsigned int x;
    unsigned long v;

    x = *(unsigned char *)(ToneDB_RootPtr[27] + (unsigned long)b + ToneDB_RelBase);
    x = *(unsigned int *)(ToneDB_RootPtr[27] + 0x80 + (unsigned long)(((x << 7) + a) * 2) + ToneDB_RelBase);
    v = *(unsigned long *)(ToneDB_RootPtr[2] + (unsigned long)(x * 4) + ToneDB_RelBase);
    return (unsigned char *)(ToneDB_RelBase + v);
}

void DSP_SetCoeff_CopyDirect(unsigned int n)
{
    unsigned char *src;
    unsigned int i;
    unsigned int cnt;
    unsigned long off;

    off = ToneDB_RootPtr[32];
    src = (unsigned char *)(ToneDB_RelBase + off);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = src[(unsigned long)n * 16 + i];
}

void DSP_SetCoeff_CopyDirect2(unsigned int n)
{
    unsigned char *src;
    unsigned int i;
    unsigned int cnt;
    unsigned long off;

    off = ToneDB_RootPtr[35];
    src = (unsigned char *)(ToneDB_RelBase + off);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = src[(unsigned long)n * 16 + i];
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = (&DSP_AlgoDescriptor_Records[t][k * 5 + 0x13])[1];
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
        break;
    }
    return r;
}

unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if (DSP_AlgoDescriptor_Records[t][k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if (DSP_AlgoDescriptor_Records[t][k * 5 + 0x13] & 2)
                    r = 0xc000;
                else
                    r = 0x4000;
            } else
                r = 0x4000;
        }
        break;
    }
    return r;
}

void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char s;
    int r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        s = DSP_AlgoChannel_SelectorByte5[t * 6];
        r = DSP_ChanFreq_CurvePool[s][(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    default:
        r = 0;
        break;
    }
    *(int *)&ram_41399[part * 0x11f] = r;
}

unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;

    r = 0;
    if (!(*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L))
        return r;
    r = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (r) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[r * 0x27];
        else
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[100];
        break;
    default:
        r = (*(unsigned char **)&ram_4136e[part * 0x11f])[100];
        break;
    }
    return r;
}

int DSP_Cmd_LoadEffectPreset(struct ring2k *r)
{
    unsigned int n;
    unsigned int i;
    unsigned int s;
    unsigned char *d;
    unsigned int t;

    t = __WA = ram_436d;
    t <<= 7;
    if (ram_436e + t == 0x122) {
        d = (unsigned char *)DSP_GetConfigBuffer();
        n = 8;
        for (i = 0; i < n; i++)
            *d++ = DSP_RingBuf_Read(r);
        n = 0x38;
        for (s = 0; s < 5; s++) {
            d = (unsigned char *)EFF_GetSlotBuffer(s);
            for (i = 0; i < n; i++)
                *d++ = DSP_RingBuf_Read(r);
        }
        DSP_RingBuf_Read(r);
        DSP_RingBuf_Read(r);
        return 0;
    }
    DSP_RingBuf_Skip(r);
    return -1;
}

void ToneGen_SetupPercussionVoice(unsigned char voice, unsigned char b, unsigned char note, unsigned char vel)
{
    unsigned char s;

    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    s = note % 12;
    note = (note - s) & 0x7f;
    ram_3b2a |= (unsigned int)note << 8;
    ram_3b1c |= ToneGen_Octave_Pitch_Table[s];
    ram_3b22 |= DSP_GetEffectRouting();
    ram_3b20 |= 0xfff;
    {
        int pt;

        pt = ToneGen_Semitone_Pitch_Table[0];
        ram_3b1e = pt;
    }
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}

void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    __A = Audio_DSP_StateTable_Packed[type] + note;
    note = __A;
    note &= 0x7f;
    ram_3b2a = ((unsigned int)note << 8) | 0x80;
    if (ToneGen_VoiceType_Default_Level[type] != 0)
        vel = ToneGen_VoiceType_Default_Level[type];
    ram_3b20 |= DSP_VelocityToVolume(vel);
    ram_3b22 |= DSP_GetEffectRouting();
    ram_3b1e = ToneGen_Semitone_Pitch_Table[note % 12];
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}

void EFF_VolumeLoop(unsigned long p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (ram_4944[i][((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx] == 1) {
            d = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx;
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x3f) {
                ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] - EFF_VolumeReduction_Steps[((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[1]];
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] < 0)
                    ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type, d, p);
        }
    }
}

void EFF_SlotActive_UpdateFlags(unsigned long p)
{
    unsigned int i;
    unsigned int found;

    found = 0;
    if (DSP_AlgoChangedFlag == 1) {
        for (i = 0; i < 5; i++)
            EFF_SlotActiveFlags.active[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (((struct cfg *)p)->f0 == 1 && EFF_SlotActiveFlags.r[i].g[4] == 1) || (EFF_SlotActiveFlags.r[i].g[4] == 1 && found == 1)) {
                EFF_SlotActiveFlags.active[i] = 1;
                ram_4944[i][((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx] = 1;
                EFF_SlotActiveFlags.r[i].g[1] = 1;
                EFF_SlotActiveFlags.r[i].g[2] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->r42[3] != 0x63)
                    EFF_SlotActiveFlags.r[i].g[0] = 1;
            } else
                EFF_SlotActiveFlags.active[i] = 0;
        }
    }
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
        if (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->on)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6];
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = t;
        }
    }
}
