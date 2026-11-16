/* lane_sub helper K, round 16, form c (KN5000 sub-CPU payload v1.42): third spellings of sub_K_16a.c's functions.
   - Audio_Cmd_ToneEdit_Dispatch: the catalog index a block-scope unsigned int local of each case;
     VoiceParam_Set_Tone_Option is called through this file's own definition (plain char third parameter).
   - VoiceParam_Set_Tone_Option: form b's with an int return type and no return statement (a probe: does a
     function that returns a value keep its locals out of HL?  The ROM has the index in DE), the value compared
     as `(unsigned char)v != 0xf5`.
   - TVF_Emit_Registers: form a with a reference to the second offset that makes no code after the switch (a probe
     of the register choice: does a longer span keep it out of IZ?).
   - TVF_Emit_Registers_Type2: form a's with such a reference at the end of case 5.
   - DSP_VoiceCoeffRoute2: the table variable a char pointer used for both tables, the count and the entry index
     declared first; the low and high byte through int expressions.

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

int VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, char v)
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
        if ((unsigned char)v != 0xf5) DSP_SlotParam_Write_Slot0(part);
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
        unsigned int k;
        VoiceAlloc_CheckAndInit(m[1]);
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        SubSlot_Apply_Catalog50(m[1], k, m[5]);
        break;
    }
    case 10: {
        unsigned int k;
        VoiceAlloc_CheckAndInit(m[1]);
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
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
        unsigned int k;
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        CustomTone_Apply_Catalog80(k);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    }
    case 21: {
        unsigned int k;
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        CustomTone_Apply_Catalog8C(k, m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    }
    case 22: {
        unsigned int k;
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
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
    int e;
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
    (void)e;
}

void TVF_Emit_Registers_Type2(unsigned char *v)
{
    unsigned int d;
    unsigned int e;
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
                e = (*(int *)(v + 68) & 0x7f) - (*(char **)(v + 35))[31];
            } else {
                d = (*(int *)(v + 66) & 0x7f) + (*(char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) + (*(char **)(v + 35))[31];
            }
            ram_451d4 = (*(int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(int *)(v + 66);
            ram_451d6 = *(int *)(v + 68);
        }
        (void)e;
        break;
    }
}

void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned int i;

    s = sel & 15;
    z = (sel & 0xf0) >> 4;
    x = ROUTE(part, s)[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = (unsigned char *)ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = (unsigned char *)ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[25];
    tbl = (unsigned char *)(ToneDB_RelBase + (unsigned long)tbl);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = (tbl + (unsigned long)d * 16)[13];
    n++;
    ram_45210[n + 6] = (int)d & 0xff;
    n++;
    ram_45210[n + 6] = (int)(d >> 8);
    n++;
}
