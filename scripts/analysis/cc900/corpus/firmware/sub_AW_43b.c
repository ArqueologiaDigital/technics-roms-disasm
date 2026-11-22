/* sub_AW_43b.c, form b.  Changes from form a: EffectParam's row as the sibling's conversion,
   `(unsigned char *)((unsigned int *)ram_44fce)`; DSPUnit's row without the conversion,
   `&ram_44fce[(int)(unsigned int)(...)]`, and p declared before i; ToneEdit's n declared before d.
   Form a's head follows.

   sub_AW_43a.c -- lane_sub helper AW, round 43, form a (KN5000 sub-CPU payload v1.42, core/08).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.

   Three switch dispatchers, each ONE function from its first label to the end of its last case body
   (span_refs.py with the case tables: every inner label is inner-only):
   - Audio_Cmd_EffectParam_Dispatch .. Audio_Cmd_EffParam_Return (tables AUDIO_CMD_EFFECTPARAM_JUMPTABLE,
     AUDIO_CMD_EFFPARAM_CASEMAP, AUDIO_CMD_EFFPARAM_JUMPTABLE);
   - Audio_Cmd_DSPUnit_Param .. Audio_Cmd_DSPUnit_Return (AUDIO_CMD_DSPUNIT_CASEMAP / _JUMPTABLE);
   - Audio_Cmd_ToneEdit_Write_And_Reply .. Audio_Cmd_ToneEdit_Reply_Send (AUDIO_CMD_TONEEDIT_REPLY_CASEMAP /
     _JUMPTABLE).
   Base: helper AL's sub_AL_27b.c (run 2026-11-19-35-sub-r27a), whose switches, case bodies and table numbering
   already reproduce the ROM (idiff_full.py: in each function one statement differs, the rest only by its shift).

   What changes (one statement per function):
   - The two shadow stores (EffectParam's, DSPUnit's).  The ROM builds the row address, copies it to XBC, adds the
     index with `lda xbc,(xbc+wa)` and stores through (XBC); every spelling of rounds 23-27 gave an indexed store
     with the index loaded first.  The built sibling Audio_Cmd_DSPGlobal_Param_Store (w_18a.c) has exactly the
     ROM's shape and is written as a pointer LOCAL: `p = row; p += idx; *p = v;` (V4.23 keeps p in a scratch
     register, the `+=` of an int is the lda).  Here: DSPUnit spelled as that sibling (row through
     `(unsigned char *)((unsigned int *)&ram_44fce[...])`), EffectParam's row `&ram_44fce[0]` (the ROM builds it
     in XWA and copies it, the address-expression pattern).
   - ToneEdit's reply: the ROM loads 0x1e0000 into XDE and 58 into BC FIRST, then computes the offset, adds XDE
     into XWA and moves the sum to XDE; V4.23 loads constant arguments last, so they are LOCALS assigned before
     the call (d in XDE, n in BC), the third argument `d + off`.  Form a: d declared before n.

   cc900-options: -Xr
*/

extern unsigned char ram_4136e[];
extern unsigned char ram_413ce[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern void Partial_Build_Present_Word(int);
void EnvTranspose_UpdateLoop(unsigned char part);
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
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot);

#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 287))
#define PCONV(p, k)     ((unsigned char *)(*(char **)(ram_4136e + (p) * 287) + (k)))

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: Audio_Cmd_EffectParam_Dispatch VoiceAlloc_Apply_Algo_Group0 VoiceAlloc_Apply_Algo_Group1 VoiceAlloc_Apply_Algo_Group2 DSP_EffParam_Apply_By_AlgoType Voice_DSPOut_Apply_A Voice_DSPOut_Apply_B Voice_DSPOut_Second_A Voice_DSPOut_Second_B */
/* cc900-module: Audio_Cmd_ToneEdit_Write_And_Reply DSP_SlotParam_Write_From_Cache_B DSP_SlotParam_Read_To_Cache_B */
/* cc900-module: Audio_Cmd_DSPUnit_Param DSP_SlotParam_Write_From_Cache DSP_SlotParam_Read_To_Cache */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 1 = AUDIO_CMD_EFFPARAM_CASEMAP */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 2 = AUDIO_CMD_EFFPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 3 = AUDIO_CMD_EFFECTPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 1 = AUDIO_CMD_TONEEDIT_REPLY_CASEMAP */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 2 = AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE */
/* cc900-data: Audio_Cmd_DSPUnit_Param 1 = AUDIO_CMD_DSPUNIT_CASEMAP */
/* cc900-data: Audio_Cmd_DSPUnit_Param 2 = AUDIO_CMD_DSPUNIT_JUMPTABLE */

void Audio_Cmd_EffectParam_Dispatch(unsigned char *m)
{
    unsigned char part;
    unsigned char *p;

    part = m[1];
    switch (m[2]) {
    case 0x15:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 20);
        break;
    case 0x18:
        AudioChannel_Dispatch(part, 0, PCONV(part, 23));
        break;
    case 0x1b:
        AudioChannel_Dispatch(part, 0, PCONV(part, 26));
        break;
    case 0x1e:
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x21:
        AudioChannel_Dispatch(part, 0, PCONV(part, 32));
        break;
    case 0x24:
        AudioChannel_Dispatch(part, 0, PCONV(part, 35));
        break;
    case 0x27:
        AudioChannel_Dispatch(part, 0, PCONV(part, 38));
        break;
    }
    p = (unsigned char *)((unsigned int *)ram_44fce);
    p += m[2];
    *p = m[4];
    switch (m[2]) {
    default:
        break;
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
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x17:
        AudioChannel_Dispatch(part, 0, PCONV(part, 23));
        break;
    case 0x1a:
        AudioChannel_Dispatch(part, 0, PCONV(part, 26));
        break;
    case 0x1d:
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x20:
        AudioChannel_Dispatch(part, 0, PCONV(part, 32));
        break;
    case 0x23:
        AudioChannel_Dispatch(part, 0, PCONV(part, 35));
        break;
    case 0x26:
        AudioChannel_Dispatch(part, 0, PCONV(part, 38));
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
    unsigned int n;
    unsigned char *d;

    buf = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)m[1] * 287),
                                    ram_4531c[29351], m[1]);
    buf[(unsigned long)(unsigned int)m[2]] = m[4];
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
    d = (unsigned char *)0x1e0000;
    n = 58;
    InterCPU_E1_DMA_Transfer(buf, n, d + ((int)ram_4531c[29351] * 80 + 19111));
}

void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit)
{
    unsigned char *p;
    unsigned int i;

    p = &ram_44fce[(int)(unsigned int)((int)unit * 0x51 + 0x66)];
    p += m[2] & 0x7f;
    *p = m[4];
    switch (m[2] & 0x7f) {
    case 0x00: case 0x04: case 0x07: case 0x08: case 0x09: case 0x0a: case 0x0b: case 0x0c:
    case 0x0d: case 0x0e: case 0x0f: case 0x10: case 0x11: case 0x12: case 0x13: case 0x14:
    case 0x15: case 0x16: case 0x18: case 0x19: case 0x1a: case 0x1b: case 0x1c: case 0x1d:
    case 0x1e: case 0x1f: case 0x20: case 0x21: case 0x22: case 0x23: case 0x24: case 0x25:
    case 0x27: case 0x28: case 0x29: case 0x2a: case 0x2b: case 0x2c: case 0x2e: case 0x2f:
    case 0x30: case 0x31: case 0x32: case 0x33: case 0x34: case 0x35: case 0x37: case 0x39:
    case 0x3a: case 0x3b: case 0x3c: case 0x3d: case 0x3e: case 0x3f: case 0x40: case 0x41:
    case 0x42: case 0x43: case 0x44: case 0x45: case 0x46: case 0x47: case 0x48: case 0x49:
    case 0x4a: case 0x4b: case 0x4c:
        break;
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
    case 0x50: case 0x4f: case 0x4e: case 0x4d:
        DSP_SlotParam_Read_To_Cache(m[1], unit);
        break;
    default:
        break;
    }
}
