/* lane_sub helper K, round 16, form b (KN5000 sub-CPU payload v1.42): second spellings of sub_K_16a.c's functions.
   - Audio_Cmd_ToneEdit_Dispatch: the catalog index a block-scope int local of each case, built from int casts;
     VoiceParam_Set_Tone_Option is called through this file's own definition (plain char third parameter).
   - VoiceParam_Set_Tone_Option: sub_H_15c's index (`int o = (unsigned int)idx`), the value parameter a plain char
     compared with `(char)0xf5`.
   - TVF_Emit_Registers: form a with the second offset volatile (to keep it out of IZ: the ROM has it in the frame
     and the record pointer in XIZ).
   - TVF_Emit_Registers_Type2: form a's with the second offset a one-element array.
   - DSP_VoiceCoeffRoute2: the source table's offset read into the table variable, then a separate pointer
     `src = (unsigned char *)(ToneDB_RelBase + tbl)`; the low and high byte as `d % 256` and `d / 256`.

   cc900-data: Audio_Cmd_ToneEdit_Dispatch 1 = AUDIO_CMD_TONEEDIT_JUMPTABLE
   cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE
   cc900-data: TVF_Emit_Registers 1 = TVF_Emit_Registers_CaseOffsets
   cc900-data: TVF_Emit_Registers_Type2 1 = TVF_Emit_Registers_Type2_CaseOffsets
   cc900-name: SubSlot_Apply_Catalog50=VoiceParam_SubSlot_Apply_Catalog50
   cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64
   cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80
   cc900-name: CustomTone_Apply_Catalog8C=VoiceParam_CustomTone_Apply_Catalog8C
   cc900-name: CustomTone_Apply_Catalog94=VoiceParam_CustomTone_Apply_Catalog94
   cc900-name: Artic_SetW2W1_Nibble0=Voice_Artic_SetWord2Word1_Nibble0
   cc900-name: Artic_SetW2W1_Nibble1=Voice_Artic_SetWord2Word1_Nibble1
   cc900-module: Voice_Part_SetStateAndReinit VoiceAlloc_CheckAndInit VoiceParam_Set_Tone_Option
   cc900-module: VoiceParam_SubSlot_Apply_Catalog50 VoiceParam_SubSlot_Apply_Catalog64 VoiceAlloc_CheckAndInit_FromRecord
   cc900-module: VoiceParam_CustomTone_Select VoiceParam_CustomTone_Apply_Catalog80 VoiceParam_CustomTone_Apply_Catalog8C
   cc900-module: VoiceParam_CustomTone_Apply_Catalog94 InterCPU_SendEditBufferToMain
   cc900-module: VoiceAlloc_Apply_Algo_Group0 TVF_Emit_Offset_Reg100 TVF_Emit_Offset_Both TVF_Clamp_Cutoff
*/

#define PART(p) ((unsigned char *)(unsigned long)(ram_41368 + (p) * 0x11f))
#define ROUTE(p, s) (*(unsigned char **)((unsigned long)&PART(p)[(int)(s) * 37 + 110] + 4))

extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char ram_45210[];
extern unsigned char ram_451a4;
extern unsigned char ram_451a5;
extern unsigned char *ram_4531c;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;

extern void Voice_Part_SetStateAndReinit();
extern void VoiceAlloc_CheckAndInit();
extern void Voice_SetArticWord0_LowByte();
extern void Artic_SetW2W1_Nibble0();
extern void Artic_SetW2W1_Nibble1();
extern void Voice_Artic_SetWord0Word2_Nibble2();
extern void Voice_Artic_SetWord1Nibble2_And_Word3();
extern void Voice_Artic_SetDepthPair_A();
extern void Voice_Artic_SetDepthPair_B();
extern void SubSlot_Apply_Catalog50();
extern void SubSlot_Apply_Catalog64();
extern void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m);
extern void VoiceParam_CustomTone_Select();
extern void CustomTone_Apply_Catalog80();
extern void CustomTone_Apply_Catalog8C();
extern void CustomTone_Apply_Catalog94();
extern void InterCPU_SendEditBufferToMain();
extern void DSP_Stub_RetB(void);
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

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, char v)
{
    int o = (unsigned int)idx;
    o += 472;
    ram_44fce[o] = v;
    switch (idx) {
    case 0:
        Voice_ActiveFlag_CheckAndLoad(part);
        break;
    case 1:
        Voice_Part_ResetSlotRouting(part);
        if (v != (char)0xf5) DSP_SlotParam_Write_Slot0(part);
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

void Audio_Cmd_ToneEdit_Dispatch(unsigned char *m)
{
    switch (m[2]) {
    case 0:
        Voice_Part_SetStateAndReinit(m[1], m[4]);
        break;
    case 4:
        VoiceAlloc_CheckAndInit(m[1]);
        Voice_SetArticWord0_LowByte(m[1], m[4]);
        break;
    case 5:
        VoiceAlloc_CheckAndInit(m[1]);
        Artic_SetW2W1_Nibble0(m[1], m[4]);
        break;
    case 6:
        VoiceAlloc_CheckAndInit(m[1]);
        Artic_SetW2W1_Nibble1(m[1], m[4]);
        break;
    case 7:
        VoiceAlloc_CheckAndInit(m[1]);
        Voice_Artic_SetWord0Word2_Nibble2(m[1], m[4]);
        break;
    case 8:
        VoiceAlloc_CheckAndInit(m[1]);
        Voice_Artic_SetWord1Nibble2_And_Word3(m[1], m[4]);
        break;
    case 9: {
        int k;
        VoiceAlloc_CheckAndInit(m[1]);
        k = ((int)m[3] << 8) | (int)m[4];
        SubSlot_Apply_Catalog50(m[1], k, m[5]);
        break;
    }
    case 10: {
        int k;
        VoiceAlloc_CheckAndInit(m[1]);
        k = ((int)m[3] << 8) | (int)m[4];
        SubSlot_Apply_Catalog64(m[1], k, m[5]);
        break;
    }
    case 11:
        if (((*(unsigned char **)(ram_4136e + m[1] * 0x11f))[16] & 0xc0) == 0x40) {
            Voice_Artic_SetDepthPair_A(m[1], m[4]);
        } else {
            VoiceAlloc_CheckAndInit(m[1]);
            VoiceParam_Set_Tone_Option(m[1], m[3], m[4]);
        }
        break;
    case 13:
        ram_451a5 = ram_451a4;
        ram_451a4 = m[1];
        break;
    case 12:
        if (((*(unsigned char **)(ram_4136e + m[1] * 0x11f))[16] & 0xc0) == 0x40)
            Voice_Artic_SetDepthPair_B(m[1], m[4]);
        break;
    case 19:
        VoiceAlloc_CheckAndInit_FromRecord(m);
        VoiceParam_CustomTone_Select(m[4]);
        break;
    case 20: {
        int k;
        k = ((int)m[3] << 8) | (int)m[4];
        CustomTone_Apply_Catalog80(k);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    }
    case 21: {
        int k;
        k = ((int)m[3] << 8) | (int)m[4];
        CustomTone_Apply_Catalog8C(k, m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    }
    case 22: {
        int k;
        k = ((int)m[3] << 8) | (int)m[4];
        CustomTone_Apply_Catalog94(k, m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    }
    case 23:
        DSP_Stub_RetB();
        break;
    case 24:
        break;
    }
}

void TVF_Emit_Registers(unsigned char *v)
{
    int d;
    volatile int e;
    switch ((*(unsigned char **)(v + 23))[54] & 7) {
    default:
    case 0:
        ram_451d4 = *(unsigned int *)(v + 66);
        ram_451d6 = *(unsigned int *)(v + 68);
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
                d = (*(unsigned int *)(v + 66) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
                e = (*(unsigned int *)(v + 68) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
            } else {
                d = (*(unsigned int *)(v + 66) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
                e = (*(unsigned int *)(v + 68) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
            }
            ram_451d4 = (*(unsigned int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(unsigned int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(unsigned int *)(v + 66);
            ram_451d6 = *(unsigned int *)(v + 68);
        }
        break;
    }
}

void TVF_Emit_Registers_Type2(unsigned char *v)
{
    unsigned int d;
    unsigned int e[1];
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
                d = (*(int *)(v + 66) & 0x7f) - (*(char **)(v + 35))[31];
                e[0] = (*(int *)(v + 68) & 0x7f) - (*(char **)(v + 35))[31];
            } else {
                d = (*(int *)(v + 66) & 0x7f) + (*(char **)(v + 35))[31];
                e[0] = (*(int *)(v + 68) & 0x7f) + (*(char **)(v + 35))[31];
            }
            ram_451d4 = (*(int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e[0]);
        } else {
            ram_451d4 = *(int *)(v + 66);
            ram_451d6 = *(int *)(v + 68);
        }
        break;
    }
}

void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned long tbl;
    unsigned int d;
    unsigned char *src;
    unsigned int n;
    unsigned int i;

    s = sel & 15;
    z = (sel & 0xf0) >> 4;
    x = ROUTE(part, s)[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + tbl + ToneDB_RelBase);
    tbl = ToneDB_RootPtr[25];
    src = (unsigned char *)(ToneDB_RelBase + tbl);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = src[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = (src + (unsigned long)d * 16)[13];
    n++;
    ram_45210[n + 6] = d % 256;
    n++;
    ram_45210[n + 6] = d / 256;
    n++;
}
