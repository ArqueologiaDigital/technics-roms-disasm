/* lane_sub probe round 7, helper D, form b: DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s).
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   A config pointer that the ROM adds directly (add xR,xwa / add xR,(xsp+N)) is an unsigned long parameter here:
   a pointer parameter made V4.23 copy it first (rounds 4-6).
*/
/* cc900-module: DSP_GetEffectRouting DSP_VelocityToVolume DSP_RingBuf_Read DSP_RingBuf_Skip Unsigned_Max_Select EFF_VolumeChange_Check RingBuf_ReadByte RingBuf_SkipToEnd */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct tgparams { int w[0x22]; };

extern struct slot __near ram_4496[];
extern struct slot __near ram_45d2[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __near ram_2ae8[];
extern unsigned char __near ram_2aee[];
extern unsigned char __near ram_2af4[];
extern unsigned char __near ram_2af8[];
extern unsigned char __near ram_2afc[];
extern unsigned char __near ram_2b01[];
extern unsigned char __near ram_2b05[];
extern unsigned char __near ram_2b09[];
extern struct e50 __near ram_4940[];
extern unsigned char __near ram_436d;
extern unsigned char __near ram_436e;
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;

extern unsigned char EFF_SlotSettleTime_Table[];
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];
extern int ToneGen_Octave_Pitch_Table[];

extern unsigned int DSP_GetEffectRouting(void);
extern unsigned int DSP_VelocityToVolume(unsigned int);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
extern int DSP_RingBuf_Read(struct ring2k *);
extern void DSP_RingBuf_Skip(struct ring2k *);
extern struct cfg *DSP_GetConfigBuffer(void);
extern void DSP_ScheduleDelay(int);
extern unsigned int Unsigned_Max_Select(unsigned int, unsigned int);
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void EFF_Change_WithDebug(unsigned int, unsigned int);
extern void EFF_DataChange_WithDebug(unsigned int, unsigned int);
extern void EFF_VolumeChange_Check(unsigned int, struct cfg *);
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

void DSP_RingBuf_Write2K(unsigned long r, unsigned char c)
{
    *(unsigned char *)(((unsigned long)(((struct ring2k *)r)->w++ & 2047) + 6) + r) = c;
    ((struct ring2k *)r)->n++;
}

void RingBuf_Write4K(unsigned long r, unsigned char c)
{
    *(unsigned char *)(((unsigned long)(((struct ring4k *)r)->w++ & 4095) + 6) + r) = c;
    ((struct ring4k *)r)->n++;
}

struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        __XWA = (unsigned long)&ram_4496[i];
        __XHL = __XWA;
        break;
    default:
        __XHL = 0xffffffff;
        break;
    }
    return (struct slot *)__XHL;
}

void DSP_Config_ClampLimits(unsigned long p)
{
    unsigned int i;

    if (((struct cfg *)p)->f6 > 1)
        ((struct cfg *)p)->f6 = 0;
    for (i = 0; i < 5; i++)
        if (((struct slot *)((unsigned long)i * 56 + 8 + p))->type > 0x63)
            ((struct slot *)((unsigned long)i * 56 + 8 + p))->type = 0x63;
}

void DSP_SlotParam_DiffAndFlag(unsigned long p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != ((struct slot *)((unsigned long)i * 56 + 8 + p))->type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
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
            EFF_Change_WithDebug(slot, ((struct slot *)((unsigned long)slot * 56 + 8 + p))->type);
            break;
        case 2: case 3: case 4:
            if (((struct cfg *)p)->f4 == 1)
                EFF_Change_WithDebug(slot, ((struct slot *)((unsigned long)slot * 56 + 8 + p))->type);
            else
                EFF_DataChange_WithDebug(slot, ((struct slot *)((unsigned long)slot * 56 + 8 + p))->type);
            break;
        }
    }
    EFF_VolumeChange_Check(slot, (struct cfg *)p);
}

void EFF_SecondaryLinkPath(struct cfg *p)
{
    register unsigned int m;
    int i;

    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0)
            m = Unsigned_Max_Select(m, 20);
    if (m != 0)
        DSP_ScheduleDelay(m);
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0) {
            if (i != 3 && i != 2)
                EFF_Disconnect(i, p->f6);
            m = Unsigned_Max_Select(m, EFF_SlotSettleTime_Table[i]);
        }
    if (m != 0)
        DSP_ScheduleDelay(m);
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
    ram_3b1e = ToneGen_Semitone_Pitch_Table[0];
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}

void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    note += Audio_DSP_StateTable_Packed[type];
    note &= 0x7f;
    ram_3b2a = ((unsigned int)note << 8) + 0x80;
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
    unsigned char *d;
    unsigned int n;
    unsigned int i;
    unsigned int s;
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

void MIDI_Dispatch(void)
{
    struct ring4k *r;
    int c;

    r = &MIDI_RingBuffer;
    MIDI_Backlog_Publish(r->n);
    while ((c = RingBuf_ReadByte(r)) >= 0) {
        switch (c & 0xf0) {
        case 0x80:
            if (r->n < 5) {
                RingBuf_SkipToEnd(r);
                continue;
            }
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
        case 0x90:
            if (r->n < 3) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2af4[0] = c;
            ram_2af4[1] = RingBuf_ReadByte(r);
            ram_2af4[2] = RingBuf_ReadByte(r);
            ram_2af4[3] = RingBuf_ReadByte(r);
            if (ram_2af4[1] < 0xf0)
                Voice_NoteOn(ram_2af4);
            else
                Voice_Poly_NoteOn(ram_2af4);
            return;
        case 0xb0:
            if (r->n < 3) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2af8[0] = c;
            ram_2af8[1] = RingBuf_ReadByte(r);
            ram_2af8[2] = RingBuf_ReadByte(r);
            ram_2af8[3] = RingBuf_ReadByte(r);
            Voice_CtrlChange(ram_2af8);
            return;
        case 0xc0:
            if (r->n < 4) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2afc[0] = c;
            ram_2afc[1] = RingBuf_ReadByte(r);
            ram_2afc[2] = RingBuf_ReadByte(r);
            ram_2afc[3] = RingBuf_ReadByte(r);
            ram_2afc[4] = RingBuf_ReadByte(r);
            Voice_ProgChange(ram_2afc);
            return;
        case 0xd0:
            if (r->n < 3) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2b01[0] = c;
            ram_2b01[1] = RingBuf_ReadByte(r);
            ram_2b01[2] = RingBuf_ReadByte(r);
            ram_2b01[3] = RingBuf_ReadByte(r);
            Voice_ChanPressure(ram_2b01);
            return;
        case 0xe0:
            if (r->n < 3) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2b05[0] = c;
            ram_2b05[1] = RingBuf_ReadByte(r);
            ram_2b05[2] = RingBuf_ReadByte(r);
            ram_2b05[3] = RingBuf_ReadByte(r);
            Voice_PitchBend(ram_2b05);
            return;
        case 0xf0:
            if (r->n < 3) {
                RingBuf_SkipToEnd(r);
                continue;
            }
            ram_2b09[0] = c;
            ram_2b09[1] = RingBuf_ReadByte(r);
            ram_2b09[2] = RingBuf_ReadByte(r);
            ram_2b09[3] = RingBuf_ReadByte(r);
            Voice_SystemMsg(ram_2b09);
            return;
        default:
            RingBuf_SkipToEnd(r);
            break;
        }
    }
}
