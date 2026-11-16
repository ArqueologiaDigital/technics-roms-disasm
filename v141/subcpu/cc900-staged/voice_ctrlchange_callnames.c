/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): they call a callee by a short cc900-name (Voice_Pitch_WriteOutReg_Sec ...), which the build's call lookup does not map yet.
*/

void Level_Build_Reg0C0(unsigned char *v);



#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_41356[];
extern unsigned char ram_41369[];
extern unsigned char ram_4136a[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
extern struct pkt __near ram_2a5e;
void NoteOn_RoutePacket(struct pkt *q);
void Voice_NoteState_Clear(int n);
void Voice_SetLFO_ActiveFlag(int n);
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);
#define PKW(q, o) (*(unsigned int *)((unsigned char *)(q) + (o)))





















#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char ram_451b4[];
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
extern unsigned char ram_43076[];
void Voice_Calc_LevelPair_Silence(unsigned char *v);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_ComputeVolume_CappedLFO(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
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
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_WriteChPanShift(unsigned char *v, int s);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);











extern int ram_451b6;
extern unsigned char ram_41350[];
extern unsigned char ram_4145a[];
extern unsigned char ram_4145b[];
extern unsigned char ram_4145c[];
extern unsigned char ram_4145d[];
extern unsigned char ram_4307c[];
void ToneGen_WriteSegRegs_SameLevel(int n, unsigned char *blk);
void ToneGen_WriteEnvSegments(int n, unsigned char *blk);
void ToneGen_WriteSingleReg(int n, int v);
void Voice_Clear_HoldBit(int n);
void Voice_Stage_EnvSegments(unsigned char *v);
void WaveSel_AddRandomEntryOffset(int *p);
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
void Voice_Slot_LoadPitchOffset_A(unsigned char *v);
void Voice_Slot_LoadPitchOffset_B(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Slot_ApplyPortamentoDelta(unsigned char *v);
void Voice_ComputePitchBend2(unsigned char *v);
void WaveSel_StageB_Reg040_Footage(unsigned char *v);

/* cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
/* cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */




void Voice_Init_Type1(unsigned char n)
{
    unsigned char *v;
    v = &ram_43076[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    WaveSel_AddRandomEntryOffset(&ram_451b6);
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
    Voice_Slot_LoadPitchOffset_B(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451b4);
}

void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_43076[(int)n * 71];
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
    ToneGen_WriteVoiceParams(n, ram_451b4);
}










