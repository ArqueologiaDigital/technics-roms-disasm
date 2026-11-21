/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41356[];
extern unsigned char ram_413b6[];
extern unsigned char ram_44fb6[];
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
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot);
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void Voice_AllVoices_WriteAmplitude(unsigned char *list);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot);
void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit);
void Audio_Cmd_EffectParam_Dispatch(unsigned char *m);

/* cc900-module: Audio_Cmd_DSPUnit_Param Audio_Cmd_EffectParam_Dispatch DSP_EffParam_Apply_By_AlgoType DSP_SlotParam_Read_To_Cache DSP_SlotParam_Write_From_Cache VoiceAlloc_Apply_Algo_Group0 VoiceAlloc_Apply_Algo_Group1 VoiceAlloc_Apply_Algo_Group2 Voice_DSPOut_Apply_A Voice_DSPOut_Apply_B Voice_DSPOut_Second_A Voice_DSPOut_Second_B */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 1 = AUDIO_CMD_EFFPARAM_CASEMAP */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 2 = AUDIO_CMD_EFFPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 3 = AUDIO_CMD_EFFECTPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_DSPUnit_Param 1 = AUDIO_CMD_DSPUNIT_CASEMAP */
/* cc900-data: Audio_Cmd_DSPUnit_Param 2 = AUDIO_CMD_DSPUNIT_JUMPTABLE */
void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit)
{
    unsigned int i;
    unsigned char *p;
    p = (unsigned char *)((unsigned int *)&ram_44fb6[(int)(unsigned int)((int)unit * 0x51 + 0x66)]);
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

void Audio_Cmd_EffectParam_Dispatch(unsigned char *m)
{
    unsigned char part;
    unsigned char *p;
    part = m[1];
    switch (m[2]) {
    case 0x15:
        AudioChannel_Dispatch(part, 0, (*(unsigned char **)(ram_41356 + (part) * 287)) + 20);
        break;
    case 0x18:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (23))));
        break;
    case 0x1b:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (26))));
        break;
    case 0x1e:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (29))));
        break;
    case 0x21:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (32))));
        break;
    case 0x24:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (35))));
        break;
    case 0x27:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (38))));
        break;
    }
    p = &ram_44fb6[0];
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
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (29))));
        break;
    case 0x17:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (23))));
        break;
    case 0x1a:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (26))));
        break;
    case 0x1d:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (29))));
        break;
    case 0x20:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (32))));
        break;
    case 0x23:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (35))));
        break;
    case 0x26:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_41356 + (part) * 287) + (38))));
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
            ram_413b6[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
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
        ram_413b6[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
        break;
    }
}
