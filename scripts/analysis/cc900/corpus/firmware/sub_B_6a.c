/* lane_sub helper B, round 6, form a: the tone-generator writers without __XIZ, the calr / jrl callers of
   core/06_voice_envelopes_and_channels.s and core/09 (cc900-module: below), and round 5's refinements that got no
   verdict (KN5000 sub-CPU payload v1.42). */
/* cc900-module: ToneGen_WriteVoice_Short ToneGen_WriteVoice_Long ToneGen_WriteVoice_TvfPair ToneGen_WriteVoice_Reg21_Reg22 Voice_UpdateAllLFO Voice_Step_DelayTimers Voice_Build_OutputLevel Voice_PerVoice_PortamentoPitchUpdate VoiceParam_FullSetup DSP_AdjustVoiceParams Voice_CC_SetSostenutoFlag */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

extern unsigned int ram_41343;
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4137b[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned char ram_413c9[];
extern unsigned char ram_413ce[];
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451cc[];
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;

extern unsigned char Voice_OutputLevel_Table[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];

extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);

extern void Pitch_Emit_Reg400(unsigned char *);
/* cc900-name: Voice_Pitch_WrOutReg_Secondary=Voice_Pitch_WriteOutputReg_Secondary */
extern void Voice_Pitch_WrOutReg_Secondary(unsigned char *);
extern void TVF_Emit_Registers(unsigned char *);
extern void TVF_Emit_Registers_Type2(unsigned char *);
extern void Voice_WriteChPanShift(unsigned char *, int);
extern void Voice_WriteChPanShift2(unsigned char *, int);
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
extern int Voice_Build_OutputLevel(unsigned char *, int);
extern void Voice_Reset_Engine(int);
extern void VoiceSlot_ClearAll(void);
/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
extern void Voice_PerVoice_PortaPitchUpd(int);
extern void VoiceParam_FullSetup(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void DSP_AdjustVoiceParams(unsigned char *);
extern void DSP_WriteAlgoBuffer(int, int);
extern void DSP_VoiceState_Dispatch(int, int);
extern void Voice_CC_SetSostenutoFlag(int, int);
extern void AlgoType_StateWrite(int, int);
extern void VoiceAlloc_WithRoutingFlag(int, int);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);
int Voice_ApplyPortamento(unsigned char *v);
int Voice_ApplyPortamento2(unsigned char *v);

/* ---- tone-generator writers (no __XIZ: it crashed V4.23 in round 5) ---- */

/* the record pointer copied into a `register` local, in the hope that V4.23 gives it XIZ */

void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[7];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x80;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[2] & 0x7fff;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_EnvLevel(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 384;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[6];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[8];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg13(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1216;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[10];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg18(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1536;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[32];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg16(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1408;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[30];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[28];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg15(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1344;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[29];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 448;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[28];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1536;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[33];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, unsigned int *p)
{
    register unsigned int *q;
    q = p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1344;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[29];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1408;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[31];
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

/* the channel in __IZ, the record pointer kept in memory (a one-element array) as the ROM spills it */

void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 256;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 320;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2176;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x940;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][25];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0xa00;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][27];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x900;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][24];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x9c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][26];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* ---- the sounding-voice walkers: the voice-record base on the stack, the channel list in XIZ ---- */

void Pitch_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Pitch_Emit_Reg400(v);
            ToneGen_WriteVoice_Long(*q, ram_451cc);
            break;
        case 0x10:
            Voice_Pitch_WrOutReg_Secondary(v);
            ToneGen_WriteVoice_Long(*q, ram_451cc);
            break;
        }
    }
}

void Voice_AllVoices_WriteAmplitude(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Voice_ApplyPortamento(v);
            break;
        case 0x10:
            Voice_ApplyPortamento2(v);
            break;
        }
        ToneGen_WriteVoice_Short(*q, ram_451cc);
    }
}

void TVF_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            TVF_Emit_Registers(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 0x10:
            TVF_Emit_Registers_Type2(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 8:
            break;
        }
    }
}

/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
void AudioChannel_AllVoices_UpdPan(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            if (v[5] & 0x80) {
                Voice_WriteChPanShift(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 0x10:
            if (!((*(unsigned char **)(v + 19))[13] & 0x20) || (v[5] & 0x80)) {
                Voice_WriteChPanShift2(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 8:
            break;
        }
    }
}

/* the voice record in XIZ, the channel-list cursor on the stack */
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *v;
    Voice_UpdateAllLFO();
    for (q = Voice_Query_AllChannels() + 5; *q < 0x40; q++) {
        v = &ram_4308e[*q][0];
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
            if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
        } else if (*(unsigned int *)(v + 47) & 0x8080L) {
            Voice_Clear_HoldBit(*v);
            Voice_Reload_Levels(*v);
            *(unsigned int *)(v + 47) = 0;
        }
    }
}

/* ---- portamento: the level with detune and ramp, then a tail jump (jrl) to Voice_Build_OutputLevel ---- */

int Voice_ApplyPortamento(unsigned char *v)
{
    int t;
    t = *(int *)(v + 13);
    if ((*(unsigned char **)(v + 23))[23] != 0) t += (int)(*(unsigned char **)(v + 23))[23] - 100;
    else t -= 0x200;
    t += (*(char **)(v + 39))[34];
    if (ram_41343 & 2) {
        if (v[4] <= 1) {
            t -= *(int *)(*(unsigned char **)(v + 35) + 16);
            t -= 8;
        } else t -= 0x10;
    }
    return Voice_Build_OutputLevel(v, t);
}

int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t, u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = -512;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != -512) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}

/* ---- mode / algorithm setters with module-local calls ---- */

void Voice_SetPolyphonyMode(unsigned char m)
{
    unsigned char i;
    if (m == 1) {
        ram_41343 |= 1;
        Voice_Reset_Engine(1);
    } else {
        ram_41343 &= ~1;
        Voice_Reset_Engine(0);
    }
    VoiceSlot_ClearAll();
    for (i = 0; i <= 15; i++) Voice_PerVoice_PortaPitchUpd(i);
}

/* returns 1; *err = 0, or 2 for an algorithm number of 40 or more */
int DSP_AlgoSelect(unsigned char part, unsigned int algo, unsigned char *err)
{
    unsigned char *rec;
    if (algo < 40) {
        rec = &ram_41368[part * 0x11f];
        if (!(*(unsigned int *)rec & 1)) {
            *(unsigned int *)rec |= 1;
            VoiceParam_FullSetup(part);
            WaveSel_Rebuild_PartCaches(part, rec[25], rec[26]);
        }
        if (*(unsigned int *)rec & 1) DSP_AdjustVoiceParams(rec);
        DSP_WriteAlgoBuffer(part, algo);
        DSP_VoiceState_Dispatch(0xff, 0xff);
        *err = 0;
    } else *err = 2;
    return 1;
}

void Voice_Portamento_OnHandler(unsigned char part, unsigned char v)
{
    switch ((*(unsigned char **)&ram_4136e[part * 0x11f])[16] & 0xc0) {
    case 0:
    case 0xc0:
        Voice_CC_SetSostenutoFlag(part, v);
        AlgoType_StateWrite(part, 1);
        VoiceAlloc_WithRoutingFlag(part, v);
        Partial_Build_Present_Word(part);
        EnvTranspose_UpdateLoop(part);
        VoiceNoteParam_UpdateLoop(part);
        Voice_ActiveFlag_CheckAndLoad(part);
        ram_413ce[part * 0x11f] = Voice_SecondaryParam_Epilogue(part);
        break;
    case 0x40:
    case 0x80:
        break;
    }
}

/* ---- round 5 refinements (no verdict: the round-5 file crashed on __XIZ) ---- */

/* ---- modulation scalers (m[1] bit 7 = bipolar, m[2] = depth): round 4's V4.23 kept the depth in DE and the result
   in HL, the ROM the other way round; the depth as an unsigned char here ---- */

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char d;
    int r;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 1;
    r /= 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char d;
    int r;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r /= 127;
    ram_41388[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char d;
    unsigned int r;
    if (m[1] & 0x80) {
        d = m[2];
        r = (unsigned int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char d;
    unsigned int r;
    if (m[1] & 0x80) {
        d = m[2];
        r = (unsigned int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 6;
    ram_41383[part * 0x11f] = r;
}

/* ---- voice init: the slot record as rec[slot][0x2d] (extz + muls, not the byte mul of round 4) ---- */

void Voice_InitVoiceState(unsigned char slot)
{
    int t;
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    t = ram_41364;
    t += t;
    t = *(int *)&Voice_OutputLevel_Table[t];
    t += t;
    ram_451d0 = t;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}

/* ---- depth-scaled loaders: the long operand on the right, so that V4.23 passes it in XWA as the ROM does ---- */

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = (unsigned long)depth * DSP_AlgoType_Dispatch2(ch, 1) >> 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = (unsigned int)v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = (unsigned long)Voice_PitchDepth_Scale[depth] * DSP_AlgoType_Dispatch1(ch, 1) >> 8;
    ram_4520c = (unsigned int)v;
    *(unsigned int *)&ram_413c3[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}

void Voice_LoadFilterTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = (unsigned long)depth * DSP_AlgoType_Dispatch2(ch, 0) >> 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        ram_4520a = (unsigned int)v;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = (unsigned long)Voice_FilterDepth_Scale[depth] * DSP_AlgoType_Dispatch1(ch, 0) >> 8;
    ram_4520e = (unsigned int)v;
    *(unsigned int *)&ram_413bf[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451cc);
}

void Voice_LoadToneTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = (unsigned long)depth * DSP_ChanFreq_WritePacket2(ch) >> 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        ram_45206 = (unsigned int)v;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

/* ---- new: portamento curve.  Bend (BC) scaled by the depth m[2], then by 12 for controls 16-19 / 21-25 or by the
   part's bend range otherwise (a 10-entry jump table on p - 16), shifted, and divided by 16384 / 16383 (long
   divide: the ROM calls Int_SignedDiv_AltEntry for both) into the part record's word at 0x41385 ---- */

void AudioMod_Apply_Porta_Curve(unsigned char p, int bend, unsigned char *m)
{
    long x;
    if (m[1] & 0x80) x = (long)bend - 8192;
    else x = (long)bend >> 1;
    x = (long)m[2] * x;
    x >>= 6;
    switch ((int)p) {
    case 16:
    case 17:
    case 18:
    case 19:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
        x *= 12;
        break;
    default:
        x = (long)ram_4137b[p * 0x11f] * x;
        break;
    }
    x <<= 9;
    if (x > 0) x /= 16384;
    else x /= 16383;
    *(int *)&ram_41385[p * 0x11f] = x;
}

