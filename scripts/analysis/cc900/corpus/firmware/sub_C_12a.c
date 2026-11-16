/* lane_sub probe round 12, helper C, form a: Audio_Cmd_ToneEdit_Dispatch (core/08_voice_noteon_and_tonegen.s, KN5000
   sub-CPU payload v1.42) with its switch: the ROM's AUDIO_CMD_TONEEDIT_JUMPTABLE holds 20 entries for two case ranges
   (0..13 and, after `dec 5`, 19..24; 1..3 and 24 go to the end), and the case bodies are the Audio_Cmd_ToneEdit_Op*
   labels.  The record pointer stays in XIZ across the calls.  Callees reached with zero-extended bytes have no
   prototype; VoiceParam_Set_Tone_Option gets its first two arguments extended and the third as a raw byte, so it has
   a prototype (unsigned int, unsigned int, unsigned char).  Names cc900 would cut to a shared 31-character prefix
   have short C names.

   cc900-data: Audio_Cmd_ToneEdit_Dispatch 1 = AUDIO_CMD_TONEEDIT_JUMPTABLE
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
   cc900-module: VoiceParam_CustomTone_Apply_Catalog94 InterCPU_SendEditBufferToMain */

extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_451a4;
extern unsigned char ram_451a5;
extern unsigned char *ram_4531c;

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
        SubSlot_Apply_Catalog50(m[1], (m[3] << 8) | m[4], m[5]);
        break;
    case 10:
        VoiceAlloc_CheckAndInit(m[1]);
        SubSlot_Apply_Catalog64(m[1], (m[3] << 8) | m[4], m[5]);
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
        CustomTone_Apply_Catalog80((m[3] << 8) | m[4]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 21:
        CustomTone_Apply_Catalog8C((m[3] << 8) | m[4], m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 22:
        CustomTone_Apply_Catalog94((m[3] << 8) | m[4], m[5]);
        InterCPU_SendEditBufferToMain(ram_4531c[29351]);
        break;
    case 23:
        DSP_Stub_RetB();
        break;
    case 24:
        break;
    }
}
