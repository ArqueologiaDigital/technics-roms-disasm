/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_af_20a.c (2026-11-18-9-sub-r20c-staged)
   sha256 f17539157ea8e7e24498af5ee6fbcc0e679d4b5dec43faa03c2403a9574567d9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
