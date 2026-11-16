/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_callnames.c (2026-11-16-89-sub-staged3)
   sha256 ea53322c9470441dfe6873ee3ba16bc614ac9b0d1a74cd38dbbd3a5fa7dea8c9 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial
   cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
extern unsigned char ram_451cc[];
extern unsigned char ram_4308e[];
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
void Pitch_Apply_Zone_Trim(unsigned char *v);
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);
void Voice_Build_GateCmd_NoPartial(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);
void Voice_ApplyPortamento2(unsigned char *v);
void Voice_ComputePitchBend2(unsigned char *v);
void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutReg_Sec(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCmd_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}
