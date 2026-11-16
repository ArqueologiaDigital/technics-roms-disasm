/* lane_sub probe round 12, helper C, form b: VoiceParam_Set_Tone_Option (switch over VOICEPARAM_TONE_OPTION_JUMPTABLE;
   index 4 has no case) and VoiceParam_CustomTone_Apply_Catalog94 (byte locals the ROM keeps in B and QA), KN5000
   sub-CPU payload v1.42, core/08_voice_noteon_and_tonegen.s.  The option byte array at 0x44fce + 472 is a struct
   member here, in case V4.23 then keeps the 472 in the index register as the ROM does (`add de,472; lda xhl,(sym)`)
   instead of folding it into the symbol (round 8's plain-array spelling folded).

   cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE
   cc900-module: VoiceAlloc_Apply_Algo_Group0 */

struct glob { unsigned char pad[472]; unsigned char opt[8]; };
extern struct glob ram_44fce;
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

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

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    ram_44fce.opt[idx] = v;
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

/* cc900-name: CustomTone_Apply_Catalog94=VoiceParam_CustomTone_Apply_Catalog94 */
void CustomTone_Apply_Catalog94(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char *rec;
    unsigned char hi;
    e = ram_4531c[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 148));
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 80 + (int)(c & 15) * 11)))[19169];
    hi = (c & 0xf0) >> 4;
    rec[(int)hi * 2 + 3] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(rec + ((int)hi * 2 + 3)))[1] = tbl[idx].b;
}
