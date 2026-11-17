/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41322[];
extern unsigned char ram_45158;
extern unsigned char ram_45159;
extern unsigned char *ram_452d0;
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
extern void Set_Tone_Option_CharV(unsigned int part, unsigned int idx, char v);
extern void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m);
extern void VoiceParam_CustomTone_Select();
extern void CustomTone_Apply_Catalog80();
extern void CustomTone_Apply_Catalog8C();
extern void CustomTone_Apply_Catalog94();
extern void InterCPU_SendEditBufferToMain();
extern void DSP_Stub_RetB(void);

/* lane_sub helper K, round 16, form a (KN5000 sub-CPU payload v1.42): the switch near misses of rounds 13-15.
   - Audio_Cmd_ToneEdit_Dispatch (from sub_C_13a): the ROM builds the 16-bit catalog index in HL before the other
     arguments and passes it on (`ld wa,hl` / `ld bc,hl`), so it is a local here (function scope, unsigned int); the
     ROM has case 13's body between case 11's and case 12's, so the cases are in that order; the ROM passes
     VoiceParam_Set_Tone_Option's third argument as an unextended byte (idiom (c)), so the call goes through a
     prototype with a plain char parameter (a second C name for the same label: this file also defines the
     function with unsigned char).
   - VoiceParam_Set_Tone_Option (from sub_H_15c): the widened index through an int temporary into an unsigned local.
   - TVF_Emit_Registers: the record's words read unsigned, the two offsets int (a conversion at the assignment).
   - TVF_Emit_Registers_Type2: the words read as int, the two offsets unsigned int, the patch's byte read through
     a char pointer.
   - DSP_VoiceCoeffRoute2 (from sub_D_13a): the part record's address spelled as in the matched
     Voice_NoteState_Clear (`(unsigned long)(base + part * 287)`); one unsigned long for the table offset and the
     source table (the ROM keeps both in XIX); the last source byte as `(p + d * 16)[13]`; the low and high byte
     through explicit unsigned char casts.

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
   cc900-name: Set_Tone_Option_CharV=VoiceParam_Set_Tone_Option
   cc900-module: Voice_Part_SetStateAndReinit VoiceAlloc_CheckAndInit VoiceParam_Set_Tone_Option
   cc900-module: VoiceParam_SubSlot_Apply_Catalog50 VoiceParam_SubSlot_Apply_Catalog64 VoiceAlloc_CheckAndInit_FromRecord
   cc900-module: VoiceParam_CustomTone_Select VoiceParam_CustomTone_Apply_Catalog80 VoiceParam_CustomTone_Apply_Catalog8C
   cc900-module: VoiceParam_CustomTone_Apply_Catalog94 InterCPU_SendEditBufferToMain
   cc900-module: VoiceAlloc_Apply_Algo_Group0 TVF_Emit_Offset_Reg100 TVF_Emit_Offset_Both TVF_Clamp_Cutoff
*/
/* cc900-module: InterCPU_SendEditBufferToMain VoiceAlloc_CheckAndInit VoiceAlloc_CheckAndInit_FromRecord VoiceParam_CustomTone_Apply_Catalog80 VoiceParam_CustomTone_Apply_Catalog8C VoiceParam_CustomTone_Apply_Catalog94 VoiceParam_CustomTone_Select VoiceParam_Set_Tone_Option VoiceParam_SubSlot_Apply_Catalog50 VoiceParam_SubSlot_Apply_Catalog64 Voice_Part_SetStateAndReinit */
/* cc900-data: Audio_Cmd_ToneEdit_Dispatch 1 = AUDIO_CMD_TONEEDIT_JUMPTABLE */
void Audio_Cmd_ToneEdit_Dispatch(unsigned char *m)
{
    unsigned int k;
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
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        SubSlot_Apply_Catalog50(m[1], k, m[5]);
        break;
    case 10:
        VoiceAlloc_CheckAndInit(m[1]);
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        SubSlot_Apply_Catalog64(m[1], k, m[5]);
        break;
    case 11:
        if (((*(unsigned char **)(ram_41322 + m[1] * 0x11f))[16] & 0xc0) == 0x40) {
            Voice_Artic_SetDepthPair_A(m[1], m[4]);
        } else {
            VoiceAlloc_CheckAndInit(m[1]);
            Set_Tone_Option_CharV(m[1], m[3], m[4]);
        }
        break;
    case 13:
        ram_45159 = ram_45158;
        ram_45158 = m[1];
        break;
    case 12:
        if (((*(unsigned char **)(ram_41322 + m[1] * 0x11f))[16] & 0xc0) == 0x40)
            Voice_Artic_SetDepthPair_B(m[1], m[4]);
        break;
    case 19:
        VoiceAlloc_CheckAndInit_FromRecord(m);
        VoiceParam_CustomTone_Select(m[4]);
        break;
    case 20:
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        CustomTone_Apply_Catalog80(k);
        InterCPU_SendEditBufferToMain(ram_452d0[29351]);
        break;
    case 21:
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        CustomTone_Apply_Catalog8C(k, m[5]);
        InterCPU_SendEditBufferToMain(ram_452d0[29351]);
        break;
    case 22:
        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];
        CustomTone_Apply_Catalog94(k, m[5]);
        InterCPU_SendEditBufferToMain(ram_452d0[29351]);
        break;
    case 23:
        DSP_Stub_RetB();
        break;
    case 24:
        break;
    }
}
