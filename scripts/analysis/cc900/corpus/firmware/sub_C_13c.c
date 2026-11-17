/* lane_sub probe round 13, helper C, form c (KN5000 sub-CPU payload v1.42): VoiceParam_Set_Tone_Option with the
   option index `(unsigned int)((int)idx + 472)`, and TVF_Emit_Registers / _Type2 with the ints declared in the
   other order (V4.23 gives the first-declared local the highest frame offset).

   cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE
   cc900-data: TVF_Emit_Registers 1 = TVF_Emit_Registers_CaseOffsets
   cc900-data: TVF_Emit_Registers_Type2 1 = TVF_Emit_Registers_Type2_CaseOffsets
   cc900-module: VoiceAlloc_Apply_Algo_Group0 TVF_Emit_Offset_Reg100 TVF_Emit_Offset_Both TVF_Clamp_Cutoff */

extern unsigned char ram_44fce[];
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;

extern void Voice_ActiveFlag_CheckAndLoad();
extern void Voice_Part_ResetSlotRouting();
extern void DSP_SlotParam_Write_Slot0();
extern void DSP_SlotParam_Write_Slot1();
extern void DSP_SlotParam_Write_Slot2();
extern void DSP_SlotParam_Write_Slot3();
extern void DSP_SlotParam_Write_Slot4();
extern void VoiceAlloc_Apply_Algo_Group0();
extern unsigned char *Voice_AllocateForSustain();
extern void Voice_AllNotes_SustainRetrigger(unsigned char *v, unsigned int n);
extern void TVF_Emit_Offset_Reg100(unsigned char *v);
extern void TVF_Emit_Offset_Both(unsigned char *v);
extern int TVF_Clamp_Cutoff(int a);

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    ram_44fce[(unsigned int)((int)idx + 472)] = v;
    switch (idx) {
    case 0:
        Voice_ActiveFlag_CheckAndLoad(part);
        break;
    case 1:
        Voice_Part_ResetSlotRouting(part);
        if (v != 0xf5) DSP_SlotParam_Write_Slot0(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 2:
        DSP_SlotParam_Write_Slot1(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 3:
        DSP_SlotParam_Write_Slot2(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 5:
        DSP_SlotParam_Write_Slot3(part);
        break;
    case 6:
        DSP_SlotParam_Write_Slot4(part);
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(part), 1);
        break;
    }
}

void TVF_Emit_Registers(unsigned char *v)
{
    int e;
    int d;
    switch ((*(unsigned char **)(v + 23))[54] & 7) {
    default:
    case 0:
        ram_451d4 = *(int *)(v + 66);
        ram_451d6 = *(int *)(v + 68);
        break;
    case 1:
    case 2:
        TVF_Emit_Offset_Reg100(v);
        break;
    case 3:
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 2) & 0x200) TVF_Emit_Offset_Reg100(v);
        else TVF_Emit_Offset_Both(v);
        break;
    case 4:
        TVF_Emit_Offset_Both(v);
        break;
    case 5:
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x40) {
            if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x80) {
                d = (*(int *)(v + 66) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
            } else {
                d = (*(int *)(v + 66) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
            }
            ram_451d4 = (*(int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(int *)(v + 66);
            ram_451d6 = *(int *)(v + 68);
        }
        break;
    }
}

void TVF_Emit_Registers_Type2(unsigned char *v)
{
    int e;
    int d;
    switch ((*(unsigned char **)(v + 23))[15] & 7) {
    default:
    case 0:
        ram_451d4 = *(int *)(v + 66);
        ram_451d6 = *(int *)(v + 68);
        break;
    case 1:
    case 2:
        TVF_Emit_Offset_Reg100(v);
        break;
    case 3:
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 2) & 0x200) TVF_Emit_Offset_Reg100(v);
        else TVF_Emit_Offset_Both(v);
        break;
    case 4:
        TVF_Emit_Offset_Both(v);
        break;
    case 5:
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x40) {
            if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x80) {
                d = (*(int *)(v + 66) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
            } else {
                d = (*(int *)(v + 66) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
            }
            ram_451d4 = (*(int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(int *)(v + 66);
            ram_451d6 = *(int *)(v + 68);
        }
        break;
    }
}
