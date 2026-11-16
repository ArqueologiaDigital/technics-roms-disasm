/* lane_sub helper H, round 15, form a (KN5000 sub-CPU payload v1.42): the four round-14 misses.  Working idea from
   round 14: V4.23 copies a value to another register (`ld c,e`, `ld de,wa`, `ld wa,hl`) when it converts it to
   another type or computes it for a different variable, and the ROM shows such copies where our C had none.
   - VoiceParam_Set_Tone_Option (+8 in 14c): the ROM promotes idx in WA and then copies it to DE before the +472.
     Here: unsigned index initialised from `(int)idx` (int, then unsigned).
   - CustomTone_CopyToneRecord (+34 in 14c): the ROM copies the e*80 product from WA to BC, adds 19111 there and
     adds BC to the pointer with `lda xwa,xwa+bc`.  That looks like the compiler's own array-member address: the
     80-byte records as a member array of a struct at offset 19111.
   - Voice_Build_OutputLevel (+36 in 14c): the index part now matches; the ROM loads the table word into WA, doubles
     it with an add and copies it to BC.  Here: a new int local takes the level.
   - TVF_Calc_Cutoff_NoKeyFollow (+2): the ROM loads the depth byte into E and converts it into L; then adds the
     shifted product to c through WA.  Here: an unsigned char local s, `d = (char)s`, c an unsigned parameter.

   cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE
   cc900-module: VoiceAlloc_Apply_Algo_Group0 BlockCopy_Words_BC_to_HL Voice_Clamp_Byte_WA TVF_Clamp_Cutoff */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

struct ctone { unsigned char pad[19111]; unsigned char rec[1][80]; };

extern unsigned char ram_44fce[];
extern struct ctone *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
extern char TVF_KeyFollow_Curves[][128];

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
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
int Voice_Clamp_Byte_WA(int a);
int TVF_Clamp_Cutoff(int a);

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    unsigned int o = (int)idx;
    o += 472;
    ram_44fce[(int)o] = v;
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

void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), ram_4531c->rec[e],
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}

void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    int x;
    b += SW(P(v, 35), 12);
    b += SW(P(v, 35), 16);
    b += SW(v, 51);
    b = Voice_Clamp_Byte_WA(b);
    x = SW(Voice_OutputLevel_Table, b * 2) * 2;
    if (P(v, 15)[2] & 0x80) w = ((unsigned int)P(v, 15)[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[W(v, 6) >> 8];
    x |= w;
    x |= 0x8000;
    ram_451d0 = x;
}

int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, unsigned int c)
{
    unsigned char *t;
    unsigned char s;
    int d, k;
    t = P(v, 23);
    s = t[16];
    d = (char)s;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
