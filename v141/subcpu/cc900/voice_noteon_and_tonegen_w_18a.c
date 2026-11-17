/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_44fb6[];
extern unsigned char *ram_452f8;
extern unsigned char *ram_452fc;
extern unsigned char *ram_45304;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern void WaveSel_Cache_SetDescPtr();
extern void Voice_DSP_OutputConfig(unsigned int part, unsigned int slot);
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);
extern void Voice_DSP_SimpleCopy(unsigned int part);
extern void Voice_DSP_SimpleCopy2(unsigned int part);
extern void DSP_EffParam_Copy_V0(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V1(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V2(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V3(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V4(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V5(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V6(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V7(unsigned int part, unsigned int d);
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m);
void DSP_EffParam_Apply_By_AlgoType(unsigned char part);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);
void VoiceParam_CustomTone_Select(unsigned char sel);
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel);
void VoiceStruct_BulkInit(unsigned char part);
void Voice_DSPOut_Apply_A(unsigned char part);
void Voice_DSPOut_Apply_B(unsigned char part);
void Voice_DSPOut_Second_A(unsigned char part);

/* cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
/* cc900-module: BlockCopy_Words_BC_to_HL DSP_EffParam_Copy_V0 DSP_EffParam_Copy_V1 DSP_EffParam_Copy_V2 DSP_EffParam_Copy_V3 DSP_EffParam_Copy_V4 DSP_EffParam_Copy_V5 DSP_EffParam_Copy_V6 DSP_EffParam_Copy_V7 */
/* cc900-data: Voice_DSPOut_Apply_A 1 = VOICE_DSPOUT_A_JUMPTABLE */
/* cc900-data: Voice_DSPOut_Apply_B 1 = VOICE_DSPOUT_B_JUMPTABLE */
/* cc900-data: Voice_DSPOut_Second_A 1 = VOICE_DSPOUT_SECOND_A_JUMPTABLE */
/* cc900-data: DSP_EffParam_Apply_By_AlgoType 1 = DSP_EFFPARAM_APPLY_JUMPTABLE */
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;
    p = (unsigned char *)((unsigned int *)&ram_44fb6[(int)(unsigned int)((int)((m[2] & 0xc0) >> 6) * 11 + 426)]);
    p += m[2] & 0x3f;
    *p = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

void DSP_EffParam_Apply_By_AlgoType(unsigned char part)
{
    switch ((*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf) {
    case 0: DSP_EffParam_Copy_V0(part, 0); break;
    case 1: DSP_EffParam_Copy_V0(part, 1); break;
    case 2: DSP_EffParam_Copy_V0(part, 2); break;
    case 3: DSP_EffParam_Copy_V0(part, 3); break;
    case 4: DSP_EffParam_Copy_V1(part, 4); break;
    case 5: DSP_EffParam_Copy_V1(part, 5); break;
    case 6: DSP_EffParam_Copy_V2(part, 6); break;
    case 7: DSP_EffParam_Copy_V3(part, 7); break;
    case 8: DSP_EffParam_Copy_V4(part, 8); break;
    case 9: DSP_EffParam_Copy_V5(part, 9); break;
    case 10: DSP_EffParam_Copy_V6(part, 10); break;
    case 11: DSP_EffParam_Copy_V7(part, 11); break;
    }
}

void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = ram_45304 + ((int)ram_45304[29351] * 80 + (int)slot * 21);
    rec += 19127;
    q = (&ram_44fb6[(int)(unsigned int)((int)slot * 5 + 500)]);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    ram_45304[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = (unsigned long)((unsigned char *)((unsigned long)k * 21) + (int)sel * 80) + ram_45304;
        rec += 19127;
        q = ram_44fb6 + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    tbl = (struct e16 *)((unsigned long)ram_452f8 + *(long *)(ram_452fc + 100));
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    ((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3] = tbl[idx].a;
    *(unsigned char *)((unsigned long)&((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3] + 1) = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}

void VoiceStruct_BulkInit(unsigned char part)
{
    unsigned char k;
    unsigned char *s;
    s = *(unsigned char **)(ram_41356 + part * 0x11f);
    BlockCopy_Words_BC_to_HL(s, (unsigned int *)ram_44fb6, 0x66);
    for (k = 0; k < 4; k++) {
        s = *(unsigned char **)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[k];
        BlockCopy_Words_BC_to_HL(s, ((unsigned int *)&ram_44fb6[(int)(unsigned int)((int)k * 0x51 + 0x66)]), 0x51);
    }
}

void Voice_DSPOut_Apply_A(unsigned char part)
{
    switch ((*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf) {
    case 0: case 1: case 2: case 3:
        Voice_DSP_OutputConfig(part, 0);
        Voice_DSP_OutputConfig(part, 1);
        break;
    case 4: case 5:
        Voice_DSP_OutputConfig(part, 0);
        break;
    case 6:
        Voice_DSP_SimpleCopy(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_4135a + part * 0x11f) & 0x4000)
            Voice_DSP_OutputConfig(part, 0);
        break;
    }
}

void Voice_DSPOut_Apply_B(unsigned char part)
{
    switch ((*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf) {
    case 0: case 1: case 2: case 3:
        Voice_DSP_OutputConfig2(part, 0);
        Voice_DSP_OutputConfig2(part, 1);
        break;
    case 4: case 5:
        Voice_DSP_OutputConfig2(part, 0);
        break;
    case 6:
        Voice_DSP_SimpleCopy2(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_4135a + part * 0x11f) & 0x4000) {
            Voice_DSP_OutputConfig2(part, 0);
            Voice_DSP_SimpleCopy2(part);
        }
        break;
    }
}

void Voice_DSPOut_Second_A(unsigned char part)
{
    switch ((*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf) {
    case 4: case 5:
        Voice_DSP_OutputConfig(part, 1);
        break;
    case 6:
        Voice_DSP_SimpleCopy(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_4135a + part * 0x11f) & 0x4000)
            Voice_DSP_OutputConfig(part, 1);
        break;
    case 10: case 11:
        Voice_DSP_OutputConfig(part, 0);
        break;
    case 8: case 9:
        break;
    }
}
