/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void Voice_ModWheel_Apply();
extern void Voice_CC_SetVolume();
extern void Voice_AllVoices_WriteAmplitude();
extern void Voice_CC_SetPan();
extern void Voice_CC_SetExpression();
extern void Voice_CC_SetSustain();
extern void Voice_AllNotes_SustainRetrigger();
extern void Voice_CC_SetReverbSend();
extern void Voice_CC_SetDspEffectSend();
extern void Voice_Portamento_OnHandler();
extern void Voice_PortamentoSlots_WriteHW();
extern void Voice_CC_SetBendRange();
extern void Voice_CC_SetTuning();
extern void Pitch_Refresh_Sounding_Voices();
extern void Voice_CC_SetKeyShift();
extern void Voice_CC_SetVelSwitchConfig();
extern void Voice_CC_SetGlidePedal();
extern void Voice_CC_SetSustainLength();
extern void Voice_CC_SetGateRoutingMode();
extern void Voice_CC_SetKeyScaling();
extern void Voice_CC_SetTgPanMode();
extern unsigned char *Voice_Query_PartVoices();
extern void EnvTranspose_UpdateLoop();
extern unsigned char *Voice_AllocateForSustain();
extern void Voice_NoteState_Clear();
extern void Voice_SetLFO_ActiveFlag();
extern unsigned char *Voice_AllocateForRelease();
extern void Voice_ParamInit();
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
void Voice_CtrlChange(unsigned char *m);
void Voice_SystemMsg(unsigned char *m);
void Voice_CtrlChange(unsigned char *m);
void Voice_SystemMsg(unsigned char *m);

/* cc900-name: Voice_AllVoices_PortaUpdate=Voice_AllVoices_PortamentoUpdate */
/* cc900-module: Pitch_Refresh_Sounding_Voices ScaleTune_Set_Global_Enabled ScaleTune_Set_Global_Mode ScaleTune_Set_User_Offset VoiceCC_Stub_Ret1 VoiceCC_Stub_Ret2 Voice_AllNotes_SustainRetrigger Voice_AllVoices_PortamentoReset Voice_AllVoices_PortamentoUpdate Voice_AllVoices_UpdateVelocity Voice_AllVoices_WriteAmplitude Voice_CC_SetBendRange Voice_CC_SetDspEffectSend Voice_CC_SetExpression Voice_CC_SetGateRoutingMode Voice_CC_SetGlidePedal Voice_CC_SetKeyScaling Voice_CC_SetKeyShift Voice_CC_SetPan Voice_CC_SetReverbSend Voice_CC_SetSustain Voice_CC_SetSustainLength Voice_CC_SetTgPanMode Voice_CC_SetTuning Voice_CC_SetVelSwitchConfig Voice_CC_SetVolume Voice_ModWheel_Apply Voice_PortamentoSlots_WriteHW Voice_Portamento_OnHandler Voice_SetCCMaxFlag Voice_SetKeyShiftEnable Voice_SetMasterTuneAndApply Voice_SetPitchBendRange Voice_SetPolyphonyMode Voice_SetRhythmMode Voice_SetVelSwitchConfig */
/* cc900-data: Voice_CtrlChange 1 = Voice_CC_Mode_CaseOffsets */
/* cc900-data: Voice_SystemMsg 1 = Voice_SystemMsg_CaseOffsets */
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
        return;
    case 0x80:
        VoiceCC_Stub_Ret1(m[3]);
        return;
    case 0x81:
        VoiceCC_Stub_Ret2(m[3]);
        return;
    case 0x82:
        Voice_SetMasterTuneAndApply(m[3]);
        return;
    case 0x83:
        Voice_SetPitchBendRange(m[3]);
        return;
    case 0x85:
        Voice_SetKeyShiftEnable(m[3]);
        return;
    case 0x86:
        ScaleTune_Set_Global_Mode(m[3]);
        return;
    case 0x87:
        Voice_SetRhythmMode(m[3]);
        return;
    case 0x91:
        Voice_SetVelSwitchConfig(m[3]);
        return;
    case 0x92:
        Voice_AllVoices_PortaUpdate();
        return;
    case 0x99:
        Voice_SetCCMaxFlag(m[3]);
        return;
    case 0xa3:
        Voice_AllVoices_PortamentoReset();
        return;
    case 0xa4:
        ScaleTune_Set_User_Offset(0, m[3]);
        return;
    case 0xa5:
        ScaleTune_Set_User_Offset(1, m[3]);
        return;
    case 0xa6:
        ScaleTune_Set_User_Offset(2, m[3]);
        return;
    case 0xa7:
        ScaleTune_Set_User_Offset(3, m[3]);
        return;
    case 0xa8:
        ScaleTune_Set_User_Offset(4, m[3]);
        return;
    case 0xa9:
        ScaleTune_Set_User_Offset(5, m[3]);
        return;
    case 0xaa:
        ScaleTune_Set_User_Offset(6, m[3]);
        return;
    case 0xab:
        ScaleTune_Set_User_Offset(7, m[3]);
        return;
    case 0xac:
        ScaleTune_Set_User_Offset(8, m[3]);
        return;
    case 0xad:
        ScaleTune_Set_User_Offset(9, m[3]);
        return;
    case 0xae:
        ScaleTune_Set_User_Offset(10, m[3]);
        return;
    case 0xaf:
        ScaleTune_Set_User_Offset(11, m[3]);
        return;
    case 0xb0:
        Voice_AllVoices_UpdateVelocity(m[3]);
        return;
    case 0xb1:
        ScaleTune_Set_Global_Enabled(m[3]);
        return;
    }
}
