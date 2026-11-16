/* lane_sub probe round 13, helper C, form a: switch near misses of round 12, KN5000 sub-CPU payload v1.42.
   - Audio_Cmd_ToneEdit_Dispatch (core/08, +11): the case bodies were shorter because V4.23 built the 16-bit catalog
     index `(m[3] << 8) | m[4]` in 8 bits; the ROM extends both bytes first (`extz bc` / `extz wa; ld hl,wa;
     sll hl,8; or hl,bc`), so both are cast to unsigned int here.
   - TVF_Emit_Registers / _Type2 (core/05, helper A's round-12 C, +1): the ROM keeps the record pointer in XIZ and
     one int on the stack (`dec 2,xsp; push xiz`); V4.23 kept the pointer on the stack and an int in IZ.  Here the
     pointer parameter is declared `register`.

   cc900-data: Audio_Cmd_ToneEdit_Dispatch 1 = AUDIO_CMD_TONEEDIT_JUMPTABLE
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
   cc900-module: TVF_Emit_Offset_Reg100 TVF_Emit_Offset_Both TVF_Clamp_Cutoff */

extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_451a4;
extern unsigned char ram_451a5;
extern unsigned char *ram_4531c;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;

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
extern void VoiceParam_Set_Tone_Option(unsigned int part, unsigned int idx, unsigned char v);
extern void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m);
extern void VoiceParam_CustomTone_Select();
extern void CustomTone_Apply_Catalog80();
extern void CustomTone_Apply_Catalog8C();
extern void CustomTone_Apply_Catalog94();
extern void InterCPU_SendEditBufferToMain();
extern void DSP_Stub_RetB(void);
extern void TVF_Emit_Offset_Reg100(unsigned char *v);
extern void TVF_Emit_Offset_Both(unsigned char *v);
extern int TVF_Clamp_Cutoff(int a);

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
    case 9:
        VoiceAlloc_CheckAndInit(m[1]);
        SubSlot_Apply_Catalog50(m[1], ((unsigned int)m[3] << 8) | (unsigned int)m[4], m[5]);
        break;
    case 10:
        VoiceAlloc_CheckAndInit(m[1]);
        SubSlot_Apply_Catalog64(m[1], ((unsigned int)m[3] << 8) | (unsigned int)m[4], m[5]);
        break;
    case 11:
        if (((*(unsigned char **)(ram_4136e + m[1] * 0x11f))[16] & 0xc0) == 0x40) {
            Voice_Artic_SetDepthPair_A(m[1], m[4]);
        } else {
            VoiceAlloc_CheckAndInit(m[1]);
            VoiceParam_Set_Tone_Option(m[1], m[3], m[4]);
        }
        break;
    case 12:
        if (((*(unsigned char **)(ram_4136e + m[1] * 0x11f))[16] & 0xc0) == 0x40)
            Voice_Artic_SetDepthPair_B(m[1], m[4]);
        break;
    case 13:
        ram_451a5 = ram_451a4;
        ram_451a4 = m[1];
        break;
    case 19:
        VoiceAlloc_CheckAndInit_FromRecord(m);
        VoiceParam_CustomTone_Select(m[4]);
        break;
    case 20:
        CustomTone_Apply_Catalog80(((unsigned int)m[3] << 8) | (unsigned int)m[4]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 21:
        CustomTone_Apply_Catalog8C(((unsigned int)m[3] << 8) | (unsigned int)m[4], m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 22:
        CustomTone_Apply_Catalog94(((unsigned int)m[3] << 8) | (unsigned int)m[4], m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 23:
        DSP_Stub_RetB();
        break;
    case 24:
        break;
    }
}

void TVF_Emit_Registers(register unsigned char *v)
{
    int d;
    int e;
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

void TVF_Emit_Registers_Type2(register unsigned char *v)
{
    int d;
    int e;
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
