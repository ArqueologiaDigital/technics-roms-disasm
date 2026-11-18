/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AF_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 4c71bfc153aa3f5c7eecd686fa34b80bcc6d759f588a4a2527d8051eea475a43 (tar-sha256); compiled at -Xr
   cc900-name: Voice_AllVoices_PortaUpdate=Voice_AllVoices_PortamentoUpdate */
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
