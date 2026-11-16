/* lane_sub helper B, round 7, file a: round 5's refinements, form a (no inline assembly, no pseudo-register)
   (KN5000 sub-CPU payload v1.42; round 6's sub_B_6a / 6b crashed V4.23, read at 0x630, so each suspect
   spelling now has a file of its own). */

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
void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);

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
