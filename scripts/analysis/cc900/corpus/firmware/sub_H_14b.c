/* lane_sub helper H, round 14, form b (KN5000 sub-CPU payload v1.42): second spellings of sub_H_14a.c's functions
   (see that file's header for what each first difference was):
   - ScaleTune_*_User_Offset: the int index initialised from the whole sum `(int)n + 12`.
   - VoiceParam_Set_Tone_Option: assignment form `o = idx; o += 472;`.
   - CustomTone_CopyToneRecord: unsigned long ram_4531c, offset without the (int) cast.
   - Voice_Build_OutputLevel: table index `b + b`; the result OR-ed in place, the 0x8000 in the store.
   - TVF_Calc_Cutoff_NoKeyFollow: initializers as in form a, plus `c += d >> 5` (the ROM moves the shifted
     product from HL to WA before adding it to c).
   - DSP_TableWalk_SearchWithState: as form a with the locals declared in the other order.
   - VoiceState_SwapSlot_Guarded: char k, index `(int)(unsigned char)k * 5`.

   cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE
   cc900-module: VoiceAlloc_Apply_Algo_Group0 BlockCopy_Words_BC_to_HL Voice_Clamp_Byte_WA TVF_Clamp_Cutoff
   cc900-module: VoiceState_SwapSlot_DE_BC VoiceState_SwapSlot_HL_IY */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern unsigned char ram_41342[];
extern unsigned char ram_44fce[];
extern unsigned long ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_24e6[];

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
void VoiceState_SwapSlot_DE_BC(int a, int c);
void VoiceState_SwapSlot_HL_IY(int a, int c, int e);

unsigned char ScaleTune_Get_User_Offset(unsigned char n)
{
    int i = (int)n + 12;
    return ram_41342[i];
}

void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v)
{
    int i = (int)n + 12;
    ram_41342[i] = v - 0x80;
}

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    int o;
    o = idx;
    o += 472;
    ram_44fce[o] = v;
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
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255),
                             (unsigned char *)(ram_4531c + (e * 80 + 19111)),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}

void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += SW(P(v, 35), 12);
    b += SW(P(v, 35), 16);
    b += SW(v, 51);
    b = Voice_Clamp_Byte_WA(b);
    b = SW(Voice_OutputLevel_Table, b + b) * 2;
    if (P(v, 15)[2] & 0x80) w = ((unsigned int)P(v, 15)[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[W(v, 6) >> 8];
    b |= w;
    ram_451d0 = b | 0x8000;
}

int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t = P(v, 23);
    int d = (char)t[16];
    int k;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        c += d >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;
    int r;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
            p = p + 2;
            goto done;
        }
        p += w;
        n--;
    }
    r = 2;
done:
    *st = r;
    return p;
}

void VoiceState_SwapSlot_Guarded(unsigned char a, unsigned char c, unsigned char e)
{
    char k;
    unsigned char *r;
    unsigned char *s;
    r = ram_24e6 + (int)a * 12;
    k = r[(int)c + 8];
    if ((unsigned char)k < 0xc0) {
        s = &ram_2126[(int)(unsigned char)k * 5];
        if (s[4] == a) {
            if (r[c] != a) s[4] = r[c];
            else s[4] = 0xff;
        }
    }
    s = &ram_2126[(int)e * 5];
    if (s[4] > 0x40) {
        s[4] = a;
        VoiceState_SwapSlot_DE_BC(a, c);
    } else VoiceState_SwapSlot_HL_IY(a, c, s[4]);
    r[(int)c + 8] = e;
}
