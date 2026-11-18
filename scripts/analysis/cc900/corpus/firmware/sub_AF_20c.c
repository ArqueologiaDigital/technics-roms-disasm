/* lane_sub helper AF, round 20, form c (KN5000 sub-CPU payload v1.42): form a with one change per function.
   - Voice_CtrlChange: the callees prototyped as the tree's C defines them ((unsigned char, unsigned char) setters,
     Voice_Query_PartVoices (unsigned char) returning a pointer ...).
   - Voice_SystemMsg: every case `break;` instead of `return;` (does V4.23 still tail-jump?).
   - DSP_AlgoType_Dispatch1 / 2: the store through the byte member array m[2][4] cast to unsigned int *
     (Dispatch2: element [1]) instead of a struct of two words.
   - DSP_AlgoType_Dispatch3: the types 10 / 11 arm as early breaks (`if (e != 0) break;`, `if (... == 0) break;`).
   - DSP_SetCoeff_MasterConfig: n is the pseudo-register __IZ, i and p plain (no `(void)&`). */
/* cc900-data: Voice_CtrlChange 1 = Voice_CC_Mode_CaseOffsets */
/* cc900-data: Voice_SystemMsg 1 = Voice_SystemMsg_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch1 1 = DSP_AlgoType_Dispatch1_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch2 1 = DSP_AlgoType_Dispatch2_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch3 1 = DSP_AlgoType_Dispatch3_CaseOffsets */
/* cc900-data: DSP_SetCoeff_MasterConfig 1 = DSP_SETCOEFF_MASTERCONFIG_JUMPTABLE */
/* cc900-name: Voice_AllVoices_PortaUpdate=Voice_AllVoices_PortamentoUpdate */
/* cc900-module: Voice_ModWheel_Apply */
/* cc900-module: Voice_CC_SetVolume */
/* cc900-module: Voice_AllVoices_WriteAmplitude */
/* cc900-module: Voice_CC_SetPan */
/* cc900-module: Voice_CC_SetExpression */
/* cc900-module: Voice_CC_SetSustain */
/* cc900-module: Voice_AllNotes_SustainRetrigger */
/* cc900-module: Voice_CC_SetReverbSend */
/* cc900-module: Voice_CC_SetDspEffectSend */
/* cc900-module: Voice_Portamento_OnHandler */
/* cc900-module: Voice_PortamentoSlots_WriteHW */
/* cc900-module: Voice_CC_SetBendRange */
/* cc900-module: Voice_CC_SetTuning */
/* cc900-module: Pitch_Refresh_Sounding_Voices */
/* cc900-module: Voice_CC_SetKeyShift */
/* cc900-module: Voice_CC_SetVelSwitchConfig */
/* cc900-module: Voice_CC_SetGlidePedal */
/* cc900-module: Voice_CC_SetSustainLength */
/* cc900-module: Voice_CC_SetGateRoutingMode */
/* cc900-module: Voice_CC_SetKeyScaling */
/* cc900-module: Voice_CC_SetTgPanMode */
/* cc900-module: Voice_SetPolyphonyMode */
/* cc900-module: VoiceCC_Stub_Ret1 */
/* cc900-module: VoiceCC_Stub_Ret2 */
/* cc900-module: Voice_SetMasterTuneAndApply */
/* cc900-module: Voice_SetPitchBendRange */
/* cc900-module: Voice_SetKeyShiftEnable */
/* cc900-module: ScaleTune_Set_Global_Mode */
/* cc900-module: Voice_SetRhythmMode */
/* cc900-module: Voice_SetVelSwitchConfig */
/* cc900-module: Voice_AllVoices_PortamentoUpdate */
/* cc900-module: Voice_SetCCMaxFlag */
/* cc900-module: Voice_AllVoices_PortamentoReset */
/* cc900-module: ScaleTune_Set_User_Offset */
/* cc900-module: Voice_AllVoices_UpdateVelocity */
/* cc900-module: ScaleTune_Set_Global_Enabled */
/* cc900-module: DSP_EffectStateQuery */
/* cc900-module: CheckStatusBits_40 */
/* cc900-module: DSP_AlgoSelect */
/* cc900-module: DSP_MixSendConfig */
/* cc900-module: DSP_RouteCoeffs_TypeA */
/* cc900-module: DSP_RouteCoeffs_TypeB */
/* cc900-module: DSP_CopyCoeffs_TypeA */
/* cc900-module: DSP_CopyCoeffs_TypeB */
/* cc900-module: DSP_VoiceCoeffRoute */
/* cc900-module: DSP_VoiceCoeffRoute2 */
/* cc900-module: DSP_AlgoCoeffLookup */
/* cc900-module: DSP_VoiceParamReadWrite */
/* cc900-module: DSP_ReadVoiceParam5D */
/* cc900-module: DSP_VoiceParam_Dispatch */
/* cc900-module: DSP_SetCoeff_CopyDirect */
/* cc900-module: DSP_SetCoeff_RouteComplex */
/* cc900-module: DSP_SetCoeff_CopyDirect2 */
/* cc900-module: DSP_SetCoeff_RouteWithCallback */
/* cc900-module: DSP_SetCoeff_FullPipeline */
/* cc900-module: DSP_SetCoeff_WriteParams */

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_45216[];
extern unsigned char *ram_4531c;
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_Dispatch1_Curves[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern int EGEnv_ModeBits_Table[];

struct sel2 { unsigned char a; unsigned char b; };
struct algorec { unsigned char b[40]; };
struct b3 { unsigned char f0; unsigned char f1; unsigned char f2; };
struct coef { unsigned int c1; unsigned int c2; };
struct prc { unsigned char pad[0x57]; unsigned char m[2][4]; };
#ifdef __GNUC__
extern int __iz;
#endif

/* Voice_CtrlChange's callees */
extern void Voice_ModWheel_Apply(unsigned char part, unsigned char v);
extern void Voice_CC_SetVolume(unsigned char part, unsigned char v);
extern void Voice_AllVoices_WriteAmplitude(unsigned char *list);
extern void Voice_CC_SetPan(unsigned char part, unsigned char v);
extern void Voice_CC_SetExpression(unsigned char part, unsigned char v);
extern void Voice_CC_SetSustain(unsigned char part, unsigned char v);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void Voice_CC_SetReverbSend(unsigned char part, unsigned char v);
extern void Voice_CC_SetDspEffectSend(unsigned char part, unsigned char v);
extern void Voice_Portamento_OnHandler(unsigned char part, unsigned char v);
extern void Voice_PortamentoSlots_WriteHW(unsigned char part);
extern void Voice_CC_SetBendRange(unsigned char part, unsigned char v);
extern void Voice_CC_SetTuning(unsigned char part, unsigned char v);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void Voice_CC_SetKeyShift(unsigned char part, unsigned char v);
extern void Voice_CC_SetVelSwitchConfig(unsigned char part, unsigned char v);
extern void Voice_CC_SetGlidePedal(unsigned char part, unsigned char v);
extern void Voice_CC_SetSustainLength(unsigned char part, unsigned char v);
extern void Voice_CC_SetGateRoutingMode(unsigned char part, unsigned char v);
extern void Voice_CC_SetKeyScaling(unsigned char part, unsigned char v);
extern void Voice_CC_SetTgPanMode(unsigned char part, unsigned char v);
extern unsigned char *Voice_Query_PartVoices(unsigned char part);
extern void EnvTranspose_UpdateLoop(unsigned char part);
extern unsigned char *Voice_AllocateForSustain(unsigned char part);
extern void Voice_NoteState_Clear(unsigned char part);
extern void Voice_SetLFO_ActiveFlag(unsigned char part);
extern unsigned char *Voice_AllocateForRelease(unsigned char part);
extern void Voice_ParamInit(unsigned char *list);

/* Voice_SystemMsg's callees */
extern void Voice_SetPolyphonyMode();
extern void VoiceCC_Stub_Ret1();
extern void VoiceCC_Stub_Ret2();
extern void Voice_SetMasterTuneAndApply(char a);
extern void Voice_SetPitchBendRange(char a);
extern void Voice_SetKeyShiftEnable();
extern void ScaleTune_Set_Global_Mode();
extern void Voice_SetRhythmMode();
extern void Voice_SetVelSwitchConfig();
extern void Voice_AllVoices_PortaUpdate();
extern void Voice_SetCCMaxFlag();
extern void Voice_AllVoices_PortamentoReset();
extern void ScaleTune_Set_User_Offset();
extern void Voice_AllVoices_UpdateVelocity();
extern void ScaleTune_Set_Global_Enabled();

/* DSP_SetCoeff_MasterConfig's callees */
extern int DSP_EffectStateQuery();
extern char CheckStatusBits_40();
extern void Voice_Slot_CalcArticParams();
extern int DSP_AlgoSelect();
extern int DSP_MixSendConfig();
extern int DSP_RouteCoeffs_TypeA();
extern int DSP_RouteCoeffs_TypeB();
extern int DSP_CopyCoeffs_TypeA();
extern int DSP_CopyCoeffs_TypeB();
extern int DSP_VoiceCoeffRoute();
extern int DSP_VoiceCoeffRoute2();
extern int DSP_AlgoCoeffLookup();
extern void DSP_VoiceParamReadWrite();
extern int DSP_ReadVoiceParam5D();
extern int DSP_VoiceParam_Dispatch();
extern int DSP_SetCoeff_CopyDirect();
extern int DSP_SetCoeff_RouteComplex();
extern int DSP_SetCoeff_CopyDirect2();
extern int DSP_SetCoeff_RouteWithCallback();
extern int DSP_SetCoeff_FullPipeline();
extern int DSP_SetCoeff_WriteParams();

void Voice_CtrlChange(unsigned char *m);
void Voice_SystemMsg(unsigned char *m);
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch);
unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch);
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e);
int DSP_SetCoeff_MasterConfig(unsigned char *p);

void Voice_CtrlChange(unsigned char *m)
{
    if (m[1] >= 0x1a)
        return;
    switch (m[2]) {
    case 0x01:
        Voice_ModWheel_Apply(m[1], m[3]);
        break;
    case 0x07:
        Voice_CC_SetVolume(m[1], m[3]);
        Voice_AllVoices_WriteAmplitude(Voice_Query_PartVoices(m[1]));
        break;
    case 0x0a:
        Voice_CC_SetPan(m[1], m[3]);
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 0x0b:
        Voice_CC_SetExpression(m[1], m[3]);
        Voice_AllVoices_WriteAmplitude(Voice_Query_PartVoices(m[1]));
        break;
    case 0x40:
        Voice_CC_SetSustain(m[1], m[3]);
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 0);
        break;
    case 0x5b:
        Voice_CC_SetReverbSend(m[1], m[3]);
        break;
    case 0x5d:
        Voice_CC_SetDspEffectSend(m[1], m[3]);
        break;
    case 0x5e:
        Voice_Portamento_OnHandler(m[1], m[3]);
        break;
    case 0x78:
        Voice_PortamentoSlots_WriteHW(m[1]);
        break;
    case 0x79:
        Voice_NoteState_Clear(m[1]);
        break;
    case 0x7b:
        Voice_SetLFO_ActiveFlag(m[1]);
        Voice_ParamInit(Voice_AllocateForRelease(m[1]));
        break;
    case 0x80:
        Voice_CC_SetBendRange(m[1], m[3]);
        break;
    case 0x81:
        Voice_CC_SetTuning(m[1], m[3]);
        Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(m[1]));
        break;
    case 0x82:
        Voice_CC_SetKeyShift(m[1], m[3]);
        break;
    case 0x91:
        Voice_CC_SetVelSwitchConfig(m[1], m[3]);
        break;
    case 0x95:
        Voice_CC_SetGlidePedal(m[1], m[3]);
        break;
    case 0x97:
        Voice_CC_SetSustainLength(m[1], m[3]);
        break;
    case 0x9b:
        Voice_CC_SetGateRoutingMode(m[1], m[3]);
        break;
    case 0x9c:
        Voice_CC_SetKeyScaling(m[1], m[3]);
        break;
    case 0x9d:
        Voice_CC_SetTgPanMode(m[1], m[3]);
        break;
    }
}

void Voice_SystemMsg(unsigned char *m)
{
    switch (m[2]) {
    case 0x09:
        Voice_SetPolyphonyMode(m[3]);
        break;
    case 0x80:
        VoiceCC_Stub_Ret1(m[3]);
        break;
    case 0x81:
        VoiceCC_Stub_Ret2(m[3]);
        break;
    case 0x82:
        Voice_SetMasterTuneAndApply(m[3]);
        break;
    case 0x83:
        Voice_SetPitchBendRange(m[3]);
        break;
    case 0x85:
        Voice_SetKeyShiftEnable(m[3]);
        break;
    case 0x86:
        ScaleTune_Set_Global_Mode(m[3]);
        break;
    case 0x87:
        Voice_SetRhythmMode(m[3]);
        break;
    case 0x91:
        Voice_SetVelSwitchConfig(m[3]);
        break;
    case 0x92:
        Voice_AllVoices_PortaUpdate();
        break;
    case 0x99:
        Voice_SetCCMaxFlag(m[3]);
        break;
    case 0xa3:
        Voice_AllVoices_PortamentoReset();
        break;
    case 0xa4:
        ScaleTune_Set_User_Offset(0, m[3]);
        break;
    case 0xa5:
        ScaleTune_Set_User_Offset(1, m[3]);
        break;
    case 0xa6:
        ScaleTune_Set_User_Offset(2, m[3]);
        break;
    case 0xa7:
        ScaleTune_Set_User_Offset(3, m[3]);
        break;
    case 0xa8:
        ScaleTune_Set_User_Offset(4, m[3]);
        break;
    case 0xa9:
        ScaleTune_Set_User_Offset(5, m[3]);
        break;
    case 0xaa:
        ScaleTune_Set_User_Offset(6, m[3]);
        break;
    case 0xab:
        ScaleTune_Set_User_Offset(7, m[3]);
        break;
    case 0xac:
        ScaleTune_Set_User_Offset(8, m[3]);
        break;
    case 0xad:
        ScaleTune_Set_User_Offset(9, m[3]);
        break;
    case 0xae:
        ScaleTune_Set_User_Offset(10, m[3]);
        break;
    case 0xaf:
        ScaleTune_Set_User_Offset(11, m[3]);
        break;
    case 0xb0:
        Voice_AllVoices_UpdateVelocity(m[3]);
        break;
    case 0xb1:
        ScaleTune_Set_Global_Enabled(m[3]);
        break;
    }
}

unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        r |= EGEnv_ModeBits_Table[(((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f2 & 0xc0) >> 6];
        break;
    }
    *(unsigned int *)((struct prc *)(ram_41368 + (int)part * 0x11f))->m[ch] = r;
    return r;
}

unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[95]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[95]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[97]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f1];
        break;
    }
    ((unsigned int *)((struct prc *)(ram_41368 + (int)part * 0x11f))->m[ch])[1] = r;
    return r;
}

unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e)
{
    unsigned int r;
    unsigned char t;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3: case 4: case 5: case 7:
        if (e == 0) {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x80) {
                if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        } else {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x40) {
                if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 4)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        }
        break;
    case 10: case 11:
        if (e != 0)
            break;
        if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[94] == 0)
            break;
        if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
            r = 0xc0;
        else
            r = 0x40;
        break;
    }
    return r;
}

int DSP_SetCoeff_MasterConfig(unsigned char *p)
{
    unsigned int i;
    i = 0;
    __IZ = 0;
    switch (p[2] & 0x7f) {
    case 0:
        __IZ =DSP_EffectStateQuery(p[1], ram_45216);
        break;
    case 1:
        if (CheckStatusBits_40(p[1]))
            Voice_Slot_CalcArticParams(p[1]);
        __IZ =DSP_AlgoSelect(p[1], p[3], ram_45216);
        break;
    case 4:
        __IZ =DSP_MixSendConfig(p[3], p[1], ram_45216);
        break;
    case 5:
        __IZ =DSP_RouteCoeffs_TypeA(p[3], p[1]);
        break;
    case 6:
        __IZ =DSP_RouteCoeffs_TypeB(p[3], p[1]);
        break;
    case 7:
        __IZ =DSP_CopyCoeffs_TypeA(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 8:
        __IZ =DSP_CopyCoeffs_TypeB(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 9:
        __IZ =DSP_VoiceCoeffRoute(p[1], p[3]);
        break;
    case 10:
        __IZ =DSP_VoiceCoeffRoute2(p[1], p[3]);
        break;
    case 11:
        __IZ =DSP_AlgoCoeffLookup(p[3]);
        break;
    case 12:
        for (__IZ = 8; i < __IZ; i++)
            DSP_VoiceParamReadWrite(p[1], i, (unsigned char *)0x45210 + (i + 6));
        break;
    case 13:
        __IZ =DSP_ReadVoiceParam5D(p[3], p[1], ram_45216);
        break;
    case 14:
        __IZ =DSP_VoiceParam_Dispatch(p[3], p[1], ram_45216);
        break;
    case 15:
        __IZ =DSP_SetCoeff_CopyDirect(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 16:
        __IZ =DSP_SetCoeff_RouteComplex(p[1], p[3]);
        break;
    case 17:
        __IZ =DSP_SetCoeff_CopyDirect2(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 18:
        __IZ =DSP_SetCoeff_RouteWithCallback(p[1], ram_4531c[29351], p[3]);
        break;
    case 19:
        __IZ =DSP_SetCoeff_FullPipeline(p[1], ram_4531c[29351], p[3]);
        break;
    case 23:
        __IZ =DSP_SetCoeff_WriteParams(p[1]);
        break;
    }
    return __IZ;
}
