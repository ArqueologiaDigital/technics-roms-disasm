/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_D_8b.c (2026-11-16-82-sub-r8)
   sha256 e4643d333cc84b5363239a62ec397d2578b34ce950ddd7fbbf8f40659745ce7a (name+funcs); compiled at -Xr */
/* lane_sub probe round 8, helper D, form b: KN5000 sub-CPU payload v1.42, core/10_dsp_voice_params.s,
   core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s and core/13_audio_process_dsp_and_effects.s.
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.  A config pointer
   that the ROM adds directly is an unsigned long parameter (rounds 5 and 7). */
/* cc900-module: RingBuf_ReadByte RingBuf_SkipToEnd DSP_GetEffectRouting DSP_VelocityToVolume DSP_RingBuf_Read DSP_RingBuf_Skip EFF_VolumeChange_Check WaveSel_StageA2_FindSetDesc WaveSel_StageA1_FindVelSplit ToneDB_Resolve_NamedToneRecord */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct tgparams { int w[0x22]; };
struct algodesc { char pad[0x13]; struct { unsigned char b0, b1, b2, b3, b4; } e[4]; };

extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern int __near ram_4600;
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __near ram_2ae8[];
extern unsigned char __near ram_2aee[];
extern unsigned char __near ram_2af4[];
extern unsigned char __near ram_2af8[];
extern unsigned char __near ram_2afc[];
extern unsigned char __near ram_2b01[];
extern unsigned char __near ram_2b05[];
extern unsigned char __near ram_2b09[];
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
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern struct algodesc DSP_AlgoDescriptor_Records[];

extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];
extern int ToneGen_Octave_Pitch_Table[];

extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void Debug_Print_Word(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_ParamEdit_WithDebug(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void EFF_Change_WithDebug(unsigned int, unsigned int);
extern void EFF_DataChange_WithDebug(unsigned int, unsigned int);
extern void EFF_VolumeChange_Check(unsigned int, unsigned long);
extern int RingBuf_ReadByte(struct ring4k *);
extern void RingBuf_SkipToEnd(struct ring4k *);
extern void MIDI_Backlog_Publish(unsigned int);
extern void Voice_ParamFinalize(unsigned char *);
extern void Voice_NoteOn(unsigned char *);
extern void Voice_Poly_NoteOn(unsigned char *);
extern void Voice_CtrlChange(unsigned char *);
extern void Voice_ProgChange(unsigned char *);
extern void Voice_ChanPressure(unsigned char *);
extern void Voice_PitchBend(unsigned char *);
extern void Voice_SystemMsg(unsigned char *);
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

void MIDI_Dispatch(void)
{
    struct ring4k *r;
    int c;

    r = &MIDI_RingBuffer;
    MIDI_Backlog_Publish(r->n);
    while ((c = RingBuf_ReadByte(r)) >= 0) {
        switch (c & 0xf0) {
        case 0x80:
            if (r->n >= 5) {
                if ((c & 8) == 0) {
                    ram_2ae8[0] = c;
                    ram_2ae8[1] = RingBuf_ReadByte(r);
                    ram_2ae8[2] = RingBuf_ReadByte(r);
                    ram_2ae8[3] = RingBuf_ReadByte(r);
                    ram_2ae8[4] = RingBuf_ReadByte(r);
                    ram_2ae8[5] = RingBuf_ReadByte(r);
                    Voice_ParamFinalize(ram_2ae8);
                } else {
                    ram_2aee[0] = c;
                    ram_2aee[1] = RingBuf_ReadByte(r);
                    ram_2aee[2] = RingBuf_ReadByte(r);
                    ram_2aee[3] = RingBuf_ReadByte(r);
                    ram_2aee[4] = RingBuf_ReadByte(r);
                    ram_2aee[5] = RingBuf_ReadByte(r);
                    Voice_ParamFinalize(ram_2aee);
                }
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0x90:
            if (r->n >= 3) {
                ram_2af4[0] = c;
                ram_2af4[1] = RingBuf_ReadByte(r);
                ram_2af4[2] = RingBuf_ReadByte(r);
                ram_2af4[3] = RingBuf_ReadByte(r);
                if ((int)ram_2af4[1] < 0xf0)
                    Voice_NoteOn(ram_2af4);
                else
                    Voice_Poly_NoteOn(ram_2af4);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xb0:
            if (r->n >= 3) {
                ram_2af8[0] = c;
                ram_2af8[1] = RingBuf_ReadByte(r);
                ram_2af8[2] = RingBuf_ReadByte(r);
                ram_2af8[3] = RingBuf_ReadByte(r);
                Voice_CtrlChange(ram_2af8);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xc0:
            if (r->n >= 4) {
                ram_2afc[0] = c;
                ram_2afc[1] = RingBuf_ReadByte(r);
                ram_2afc[2] = RingBuf_ReadByte(r);
                ram_2afc[3] = RingBuf_ReadByte(r);
                ram_2afc[4] = RingBuf_ReadByte(r);
                Voice_ProgChange(ram_2afc);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xd0:
            if (r->n >= 3) {
                ram_2b01[0] = c;
                ram_2b01[1] = RingBuf_ReadByte(r);
                ram_2b01[2] = RingBuf_ReadByte(r);
                ram_2b01[3] = RingBuf_ReadByte(r);
                Voice_ChanPressure(ram_2b01);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xe0:
            if (r->n >= 3) {
                ram_2b05[0] = c;
                ram_2b05[1] = RingBuf_ReadByte(r);
                ram_2b05[2] = RingBuf_ReadByte(r);
                ram_2b05[3] = RingBuf_ReadByte(r);
                Voice_PitchBend(ram_2b05);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xf0:
            if (r->n >= 3) {
                ram_2b09[0] = c;
                ram_2b09[1] = RingBuf_ReadByte(r);
                ram_2b09[2] = RingBuf_ReadByte(r);
                ram_2b09[3] = RingBuf_ReadByte(r);
                Voice_SystemMsg(ram_2b09);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        default:
            RingBuf_SkipToEnd(r);
            break;
        }
    }
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
    s = ToneGen_Semitone_Pitch_Table[0];
    ram_3b1e = s;
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}

void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    note = note + Audio_DSP_StateTable_Packed[type];
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

int DSP_Cmd_LoadEffectPreset(struct ring2k *r)
{
    unsigned int i;
    unsigned int s;
    unsigned int n;
    unsigned char *d;
    unsigned int t;

    t = ram_436d;
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

void EFF_Change_Handler(unsigned int slot, unsigned long p)
{
    if (ram_4940[slot].f0 == 1) {
        switch (slot) {
        case 2:
            if (((struct cfg *)p)->f4 == 1)
                EFF_Disconnect(slot, ((struct cfg *)p)->f6);
            break;
        default:
            EFF_Disconnect(slot, ((struct cfg *)p)->f6);
            break;
        }
        switch (slot) {
        default:
            EFF_Change_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        case 2: case 3: case 4:
            if (((struct cfg *)p)->f4 == 1)
                EFF_Change_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            else
                EFF_DataChange_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        }
    }
    EFF_VolumeChange_Check(slot, p);
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(p + ((unsigned long)slot * 56 + (unsigned long)idx * 2)))[6]);
        if (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)(p + ((unsigned long)slot * 56 + (unsigned long)idx * 2)))[6];
            ((int *)(p + ((unsigned long)slot * 56 + (unsigned long)idx * 2)))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(p + ((unsigned long)slot * 56 + (unsigned long)idx * 2)))[6] = t;
        }
    }
}

void EFF_ParamIterator_Process(unsigned int slot, unsigned long p)
{
    unsigned int i;
    unsigned int n;
    unsigned char *q;

    switch (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type) {
    default:
        n = ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if (ram_4944[slot][i] == 1 && i != ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->idx)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->param[13] & 1) * 11];
        while (*q != 12) {
            if (ram_4944[slot][*q] == 1)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, *q, p);
            q++;
        }
        break;
    }
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

void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (ram_45d4[i][j] != ((unsigned int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[5]) {
                ram_4942[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4942[i][j] = 0;
        }
        for (j = 0; j < 17; j++) {
            if (ram_45d6[i][j] != ((int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[6]) {
                ram_4944[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4944[i][j] = 0;
        }
        for (j = 0; j < 1; j++) {
            if (ram_45fa[i][j] != ((int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[24]) {
                ram_4966[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4966[i][j] = 0;
        }
        if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}

void EFF_DspChannel_InitFlags(unsigned long p)
{
    unsigned int i;
    unsigned int j;
    unsigned int k;

    for (i = 0; i < 5; i++) {
        if (DSP_AlgoChangedFlag == 1)
            ram_4940[i].f0 = 1;
        if (ram_4940[i].f0 == 1) {
            for (j = 0; j < 17; j++)
                ram_4944[i][j] = 1;
            for (j = 0; j < 1; j++)
                ram_4942[i][j] = 1;
            for (j = 0; j < 1; j++)
                ram_4966[i][j] = 1;
            EFF_SlotActiveFlags.r[i].g[0] = 1;
            EFF_SlotActiveFlags.r[i].g[1] = 1;
            EFF_SlotActiveFlags.r[i].g[2] = 1;
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
            if (i == 1) {
                k = ((struct cfg *)p)->s[0].idx + 1;
                switch (((struct cfg *)p)->s[0].type) {
                default:
                    *(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;
                    break;
                case 0x0f: case 0x35:
                    k++;
                    *(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;
                    break;
                }
            }
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x27) {
            if (EFF_SlotActiveFlags.r[i].flags[0] == 1 || EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1) {
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
                EFF_SlotActiveFlags.r[i].flags[1] = 0;
                EFF_SlotActiveFlags.r[i].flags[2] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[3] == 1 || EFF_SlotActiveFlags.r[i].flags[4] == 1 || EFF_SlotActiveFlags.r[i].flags[5] == 1) {
                EFF_SlotActiveFlags.r[i].flags[3] = 1;
                EFF_SlotActiveFlags.r[i].flags[4] = 0;
                EFF_SlotActiveFlags.r[i].flags[5] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[6] == 1 || EFF_SlotActiveFlags.r[i].flags[7] == 1 || EFF_SlotActiveFlags.r[i].flags[8] == 1) {
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[7] = 0;
                EFF_SlotActiveFlags.r[i].flags[8] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[9] == 1 || EFF_SlotActiveFlags.r[i].flags[10] == 1 || EFF_SlotActiveFlags.r[i].flags[11] == 1) {
                EFF_SlotActiveFlags.r[i].flags[9] = 1;
                EFF_SlotActiveFlags.r[i].flags[10] = 0;
                EFF_SlotActiveFlags.r[i].flags[11] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[12] == 1 || EFF_SlotActiveFlags.r[i].flags[13] == 1 || EFF_SlotActiveFlags.r[i].flags[14] == 1) {
                EFF_SlotActiveFlags.r[i].flags[12] = 1;
                EFF_SlotActiveFlags.r[i].flags[13] = 0;
                EFF_SlotActiveFlags.r[i].flags[14] = 0;
            }
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x4f) {
            if (EFF_SlotActiveFlags.r[i].flags[1] == 1) {
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
                EFF_SlotActiveFlags.r[i].flags[1] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[3] == 1) {
                EFF_SlotActiveFlags.r[i].flags[2] = 1;
                EFF_SlotActiveFlags.r[i].flags[3] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[5] == 1) {
                EFF_SlotActiveFlags.r[i].flags[4] = 1;
                EFF_SlotActiveFlags.r[i].flags[5] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[7] == 1) {
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[7] = 0;
            }
        }
        if ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x35 || ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x0f) && EFF_SlotActiveFlags.r[i].flags[13] == 1) {
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[13] == 1) {
                EFF_SlotActiveFlags.r[i].flags[3] = 1;
                EFF_SlotActiveFlags.r[i].flags[8] = 1;
                EFF_SlotActiveFlags.r[i].flags[5] = 1;
                EFF_SlotActiveFlags.r[i].flags[10] = 1;
            } else {
                EFF_SlotActiveFlags.r[i].flags[4] = 1;
                EFF_SlotActiveFlags.r[i].flags[9] = 1;
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[11] = 1;
            }
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else {
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x3f && (EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1))
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        }
        if (EFF_SlotActiveFlags.r[i].g[3] == 1)
            ram_4944[i][((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx] = 1;
    }
}

void DSP_InitHandler_NullStub(void)
{
}

void WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p)
{
    unsigned char lo;
    unsigned char hi;

    lo = p[z * 2 + 3];
    hi = (p + z * 2 + 3)[1];
    WaveSel_StageA2_FindSetDesc(lo, hi);
}

void WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s)
{
    WaveSel_StageA1_FindVelSplit(a, p[1], p[2], e, s);
}

unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e)
{
    unsigned char *q;

    q = &rec[k * 2 + 0x27];
    return ToneDB_Resolve_NamedToneRecord(q[0], q[1], k, e);
}

void DSP_SetCoeff_CopyDirect(unsigned int n)
{
    unsigned char *src;
    unsigned int cnt;
    unsigned int i;

    src = (unsigned char *)(ToneDB_RelBase + ToneDB_RootPtr[32]);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = *(src + ((unsigned long)n * 16 + i));
}

void DSP_SetCoeff_CopyDirect2(unsigned int n)
{
    unsigned char *src;
    unsigned int cnt;
    unsigned int i;

    src = (unsigned char *)(ToneDB_RelBase + ToneDB_RootPtr[35]);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = *(src + ((unsigned long)n * 16 + i));
}

void DSP_System_Init(void)
{
    unsigned int i;
    unsigned char *q;

    q = ram_41342;
    for (i = 0; i < 0x26; i++)
        *q++ = 0;
    q = ram_41368;
    for (i = 0; i < 0x1d26; i++)
        *q++ = 0;
    MIDI_RingBuffer.w = MIDI_RingBuffer.r = MIDI_RingBuffer.n = 0;
    if ((ram_44 & 8) != 0)
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

unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b)
{
    unsigned int x;
    unsigned long v;

    x = *(unsigned char *)(ToneDB_RootPtr[27] + (unsigned long)b + ToneDB_RelBase);
    x = *(unsigned int *)(ToneDB_RootPtr[27] + 0x80 + (unsigned long)(((x << 7) + a) * 2) + ToneDB_RelBase);
    v = *(unsigned long *)(ToneDB_RootPtr[2] + (unsigned long)(x * 4) + ToneDB_RelBase);
    return (unsigned char *)(ToneDB_RelBase + v);
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = DSP_AlgoDescriptor_Records[t].e[k].b1;
    if (t == 8 && k == 1)
        r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
    return r;
}
