/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_callnames2.c (2026-11-16-89-sub-staged3)
   sha256 931dfbeb5796071ce4e985e55f4b520e88d62d31359aa1a8af9753718372dcab (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
void Level_Build_Reg0C0(unsigned char *v);
extern unsigned char ram_451cc[];
extern unsigned char ram_4308e[];
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Pitch_Emit_Reg400(unsigned char *v);
void Pitch_Apply_Partial_Detune(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Registers(unsigned char *v);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_PortaLevel_Compute(unsigned char *v);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrigger(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);
void Voice_Slot_LoadPitchOffset_A(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Slot_ApplyPortamentoDelta(unsigned char *v);
void WaveSel_StageB_Reg040_Footage(unsigned char *v);
void Voice_Release_Type4(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Reg040_Footage(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    if (v[3] < 3) {
        Voice_Calc_LevelPair_Full(v);
        Voice_ComputePitch(v);
        Voice_Slot_LoadPitchOffset_A(v);
        Voice_ApplyPortamento(v);
    } else {
        Voice_Calc_LevelPair_Mono(v);
        Voice_ComputePitch(v);
        Voice_Slot_ApplyPortamentoDelta(v);
        Voice_ApplyPortamento(v);
    }
    ToneGen_WriteVoiceParams(n, ram_451cc);
}
