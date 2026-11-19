/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AL_23c.c (2026-11-19-11-sub-r23h-helpers)
   sha256 9bd6d36ae82571e904011848bff5760eda9759417c1e5fea031f9a3cc7feb553 (name+funcs); compiled at -Xr */
/* sub_AL_23c.c, form c.  Changes from form a:
   - Audio_Cmd_EffectParam_Dispatch: every AudioChannel_Dispatch case spelled like Grp0, `P + K` (is the ROM's
     XWA -> XBC -> XDE copy of the later cases a register-state effect rather than a spelling?); the shadow
     store on the bare array, `ram_44fce[m[2]]`.
   - Audio_Cmd_ToneEdit_Write_And_Reply: `(int)m[1] * 287` in the patch row, `buf[m[2]]` plain, the DMA
     destination as `(unsigned char *)0x1e0000 + (long)(...)`.
   - Audio_Cmd_DSPUnit_Param: the head's index and the switch value both `(unsigned char)(m[2] & 0x7f)`.
   - Voice_Part_SetStateAndReinit: `if (!c)`, and the first test through `(unsigned int *)(ram_41368 + ...)`.
   - WaveSel_Cache_VelSplitPtr: both paths in the matched WaveSel_Cache_SetDescPtr's spelling, path 1 with the
     slot offset as `(int)(unsigned int)(...)`.
   Form a's head follows.

   sub_AL_23a.c -- lane_sub helper AL, round 23, form a (KN5000 sub-CPU payload v1.42; core/08_voice_noteon_and_tonegen.s
   and core/10_dsp_voice_params.s).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).
   No __IZ / __XIZ anywhere (bug candidate 12).

   Functions (all never compiled before):
   - Audio_Cmd_EffectParam_Dispatch: ONE function from its label to Audio_Cmd_EffParam_Return (span_refs.py: all
     42 inner labels, Audio_Cmd_EffParam_Grp0 and Audio_Cmd_EffParam_TableJump_CaseBase included, are inner-only).
     Two switches on m[2]: a one-level table (AUDIO_CMD_EFFECTPARAM_JUMPTABLE, base = the first case body) and a
     two-level one (byte map AUDIO_CMD_EFFPARAM_CASEMAP + AUDIO_CMD_EFFPARAM_JUMPTABLE, as the built
     HDAE5000_FDFileSelectProc: map = object 1, table = object 2 of its switch).  The ROM tests 0..16 apart
     (`cp a,16; ugt -> table; cp a,0; nc -> return`) and keeps a dead `jrl t, Return` at the table base: read as
     a FIRST case group 0..16 whose body is only `break` (round 21's lesson: such a case loses its compare and its
     table entries go to the exit).  The part byte lives in QIZH: `register unsigned char part`.
     Grp0's argument is `P + 20` (the ROM loads it straight into XDE); the other AudioChannel_Dispatch cases build
     theirs in XWA and copy it (XBC, then XDE): `&P[23]` here (b and c try other spellings).
   - Audio_Cmd_ToneEdit_Write_And_Reply (one function to Audio_Cmd_ToneEdit_Reply_Send's end; Case_Pan and the
     other 7 inner labels are inner-only): m kept in XIZ (`register`), the reply buffer on the stack; two-level
     switch (AUDIO_CMD_TONEEDIT_REPLY_CASEMAP / _JUMPTABLE), cases from the map: Pan 0x19 0x1b 0x2e 0x30,
     Sustain 0x1d 0x32, Slot0 0x1f, Slot1 0x34, ReadBack 0x21..0x24 (falls into) ReadBack1 0x36..0x39.
   - Audio_Cmd_DSPUnit_Param (one function to Audio_Cmd_DSPUnit_Return; 21 inner labels inner-only): unit and m on
     the stack, the slot counter i in IZ (unsigned int, passed as `(unsigned char)i`); two-level switch
     (AUDIO_CMD_DSPUNIT_CASEMAP / _JUMPTABLE): cases 1, 2+3, 5, 6, 0x17, 0x26, 0x2d, 0x36, 0x38, 0x4d..0x50.
     The shadow row is the matched `&ram_44fce[(int)(unsigned int)((int)k * 0x51 + 0x66)]` (w_18a.c).
   - Voice_Part_SetStateAndReinit: sibling of the built Voice_PerVoice_PortamentoPitchUpdate (voice_ctrlchange.c),
     same mode switch; record words through `*(unsigned int *)&ram_41368[part * 0x11f] |= ...` (ad_20a.c).
   - WaveSel_Cache_VelSplitPtr: path 1 adds the slot offset with exts (long add), path 0 through (xwa+de):
     `(int)(unsigned int)` index vs a plain int index.
   Skipped:
   - VoiceParam_Action_ToneEdit: an inner case label (the table base) of Voice_ParamFinalize (span_refs.py over
     Voice_ParamFinalize .. DSP_WriteVoiceParam: all 33 inner labels inner-only; not built, not in this batch).
   - VoiceParam_Set_Tone_Option_CutoffOffset: inner case label of VoiceParam_Set_Tone_Option (open, +21).
   - WaveSel_StageA1_FindVelSplit, EnvTranspose_UpdateLoop, DSP_SetCoeff_FullPipeline: not reached this round.

   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_413ce[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void AlgoType_StateWrite(int, int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);
void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot);
void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot);
void VoiceAlloc_Apply_Algo_Group2(unsigned char part, unsigned char slot);
void DSP_EffParam_Apply_By_AlgoType(unsigned char part);
void Voice_DSPOut_Apply_A(unsigned char part);
void Voice_DSPOut_Apply_B(unsigned char part);
void Voice_DSPOut_Second_A(unsigned char part);
void Voice_DSPOut_Second_B(unsigned char part);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void AudioChannel_AllVoices_UpdVar3(unsigned char *list);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot);
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void Voice_AllVoices_WriteAmplitude(unsigned char *list);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e);
extern void Voice_NoteState_Clear(int);
extern void Voice_SetLFO_ActiveFlag(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void VoiceSlot_FullInit(int);
extern void VoiceSlot_AltInit(int);
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot);

#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 287))

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 VoiceAlloc_Apply_Algo_Group1 VoiceAlloc_Apply_Algo_Group2 DSP_EffParam_Apply_By_AlgoType Voice_DSPOut_Apply_A Voice_DSPOut_Apply_B Voice_DSPOut_Second_A Voice_DSPOut_Second_B */
/* cc900-module: DSP_SlotParam_Write_From_Cache_B DSP_SlotParam_Read_To_Cache_B DSP_SlotParam_Write_From_Cache DSP_SlotParam_Read_To_Cache */
/* cc900-module: WaveSel_StageA1_FromPatchBlock */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 1 = AUDIO_CMD_EFFECTPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 2 = AUDIO_CMD_EFFPARAM_CASEMAP */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 3 = AUDIO_CMD_EFFPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 1 = AUDIO_CMD_TONEEDIT_REPLY_CASEMAP */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 2 = AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE */
/* cc900-data: Audio_Cmd_DSPUnit_Param 1 = AUDIO_CMD_DSPUNIT_CASEMAP */
/* cc900-data: Audio_Cmd_DSPUnit_Param 2 = AUDIO_CMD_DSPUNIT_JUMPTABLE */

void Audio_Cmd_EffectParam_Dispatch(unsigned char *m)
{
    register unsigned char part;

    part = m[1];
    switch (m[2]) {
    case 0x15:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 20);
        break;
    case 0x18:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 23);
        break;
    case 0x1b:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 26);
        break;
    case 0x1e:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 29);
        break;
    case 0x21:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 32);
        break;
    case 0x24:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 35);
        break;
    case 0x27:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 38);
        break;
    }
    ram_44fce[m[2]] = m[4];
    switch (m[2]) {
    case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
    case 9: case 10: case 11: case 12: case 13: case 14: case 15: case 16:
        break;
    case 0x11:
        Partial_Build_Present_Word(m[1]);
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 0x12:
        Partial_Build_Present_Word(m[1]);
        break;
    case 0x14:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 29);
        break;
    case 0x17:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 23);
        break;
    case 0x1a:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 26);
        break;
    case 0x1d:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 29);
        break;
    case 0x20:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 32);
        break;
    case 0x23:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 35);
        break;
    case 0x26:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 38);
        break;
    case 0x2b: case 0x2c: case 0x2d: case 0x2e:
        VoiceAlloc_Apply_Algo_Group0(m[1], 0);
        break;
    case 0x2f: case 0x30: case 0x31: case 0x32:
        VoiceAlloc_Apply_Algo_Group0(m[1], 1);
        break;
    case 0x33: case 0x34: case 0x35: case 0x36:
        VoiceAlloc_Apply_Algo_Group0(m[1], 2);
        break;
    case 0x37: case 0x38: case 0x39: case 0x3a:
        VoiceAlloc_Apply_Algo_Group0(m[1], 3);
        break;
    case 0x3b: case 0x3c: case 0x3d: case 0x3e:
        VoiceAlloc_Apply_Algo_Group1(m[1], 0);
        break;
    case 0x3f: case 0x40: case 0x41: case 0x42:
        VoiceAlloc_Apply_Algo_Group1(m[1], 1);
        break;
    case 0x43: case 0x44: case 0x45: case 0x46:
        VoiceAlloc_Apply_Algo_Group1(m[1], 2);
        break;
    case 0x47: case 0x48: case 0x49: case 0x4a:
        VoiceAlloc_Apply_Algo_Group1(m[1], 3);
        break;
    case 0x4b: case 0x4c: case 0x4d: case 0x4e:
        VoiceAlloc_Apply_Algo_Group2(m[1], 0);
        break;
    case 0x4f: case 0x50: case 0x51: case 0x52:
        VoiceAlloc_Apply_Algo_Group2(m[1], 1);
        break;
    case 0x53: case 0x54: case 0x55: case 0x56:
        VoiceAlloc_Apply_Algo_Group2(m[1], 2);
        break;
    case 0x57: case 0x58: case 0x59: case 0x5a:
        VoiceAlloc_Apply_Algo_Group2(m[1], 3);
        break;
    case 0x5d:
        if (m[5] == 15) {
            DSP_EffParam_Apply_By_AlgoType(m[1]);
            AlgoType_StateWrite(m[1], 0);
            Partial_Build_Present_Word(m[1]);
            EnvTranspose_UpdateLoop(m[1]);
            VoiceNoteParam_UpdateLoop(m[1]);
            Voice_DSPOut_Apply_A(m[1]);
            Voice_DSPOut_Apply_B(m[1]);
            Voice_DSPOut_Second_A(m[1]);
            Voice_DSPOut_Second_B(m[1]);
            Voice_ActiveFlag_CheckAndLoad(m[1]);
            ram_413ce[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
        } else {
            Partial_Build_Present_Word(m[1]);
            EnvTranspose_UpdateLoop(m[1]);
        }
        break;
    case 0x5e:
        Voice_DSPOut_Apply_A(m[1]);
        break;
    case 0x5f:
        Voice_DSPOut_Apply_B(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x60:
        Voice_DSPOut_Second_A(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x61:
        Voice_DSPOut_Second_B(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x62:
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x63:
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x64:
        Voice_ActiveFlag_CheckAndLoad(m[1]);
        break;
    case 0x65:
        ram_413ce[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
        break;
    }
}

void Audio_Cmd_ToneEdit_Write_And_Reply(register unsigned char *m)
{
    unsigned char *buf;

    buf = ToneDB_Find_SubToneRecord(*(unsigned char **)(ram_4136e + (int)m[1] * 287), ram_4531c[29351], m[1]);
    buf[m[2]] = m[4];
    switch (m[2]) {
    case 0x19: case 0x1b: case 0x2e: case 0x30:
        AudioChannel_AllVoices_UpdVar3(Voice_Query_PartVoices(m[1]));
        break;
    case 0x1d: case 0x32:
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 1);
        break;
    case 0x1f:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(0);
        break;
    case 0x34:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(1);
        break;
    case 0x21: case 0x22: case 0x23: case 0x24:
        DSP_SlotParam_Read_To_Cache_B(m[1], 0);
    case 0x36: case 0x37: case 0x38: case 0x39:
        DSP_SlotParam_Read_To_Cache_B(m[1], 1);
        break;
    }
    InterCPU_E1_DMA_Transfer(buf, 58, (unsigned char *)0x1e0000 + (long)((int)ram_4531c[29351] * 80 + 19111));
}

void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit)
{
    unsigned int i;

    (&ram_44fce[(int)(unsigned int)((int)unit * 0x51 + 0x66)])[(unsigned char)(m[2] & 0x7f)] = m[4];
    switch ((unsigned char)(m[2] & 0x7f)) {
    case 1:
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 2: case 3:
        WaveSel_Cache_VelSplitPtr(m[1], unit);
        for (i = 0; i < 4; i++)
            WaveSel_Cache_SetDescPtr(m[1], unit, (unsigned char)i);
        break;
    case 5:
        Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(m[1]));
        break;
    case 6:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 0, (unsigned char)i);
            AlgoFlag_Write(m[1], 0, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 0);
        break;
    case 0x17:
        Voice_AllVoices_WriteAmplitude(Voice_Query_PartVoices(m[1]));
        break;
    case 0x26:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 1, (unsigned char)i);
            AlgoFlag_Write(m[1], 1, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 1);
        break;
    case 0x2d:
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 1);
        break;
    case 0x36:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache(m[1], unit);
        break;
    case 0x38:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 2, (unsigned char)i);
            AlgoFlag_Write(m[1], 2, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 2);
        break;
    case 0x4d: case 0x4e: case 0x4f: case 0x50:
        DSP_SlotParam_Read_To_Cache(m[1], unit);
        break;
    }
}

void Voice_Part_SetStateAndReinit(unsigned char part, unsigned char c)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 3) == 0)
        return;
    if (!c) {
        *(unsigned int *)&ram_41368[part * 0x11f] &= 0xfffe;
        *(unsigned int *)&ram_41368[part * 0x11f] |= 2;
    } else {
        *(unsigned int *)&ram_41368[part * 0x11f] &= 0xfffd;
        *(unsigned int *)&ram_41368[part * 0x11f] |= 1;
    }
    *(unsigned int *)&ram_41368[part * 0x11f] |= 4;
    Voice_NoteState_Clear(part);
    Voice_SetLFO_ActiveFlag(part);
    WaveSel_Rebuild_PartCaches(part, ram_41381[part * 287], ram_41382[part * 287]);
    if ((*(unsigned char **)&ram_4136e[part * 287])[93] & 0x80)
        *(unsigned int *)&ram_41372[part * 0x11f] |= 0x4000;
    else
        *(unsigned int *)&ram_41372[part * 0x11f] &= 0xbfff;
    switch ((*(unsigned char **)&ram_4136e[part * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(part);
        break;
    case 0x40:
        VoiceSlot_AltInit(part);
        break;
    case 0x80:
        break;
    }
}

void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + (int)(unsigned int)((int)slot * 37 + 0x6e)))[4] =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
