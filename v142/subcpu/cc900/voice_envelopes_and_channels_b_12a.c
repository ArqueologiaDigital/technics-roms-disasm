/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Colour_LookupIndex(int a, int b);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);

/* cc900-module: Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Voice_Colour_LookupIndex */
void Voice_Calc_LevelPair_EGB(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    unsigned char *p;
    p = *(unsigned char **)(v + 23);
    s = p;
    t = Voice_EnvelopeLevel_Curve[p[15]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[22] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[19], 0, 0x7f, (char)s[22]);
        if (s[17] != 0) {
            lv += PitchBend_Scale((char)s[17], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[17] != 0) {
        lv += PitchBend_Scale((char)s[17], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    if (((char *)s)[7] < 0) d = Detune_ScaleSymmetric(~(int)(char)s[16] + 1);
    else d = Detune_ScaleSymmetric((char)s[16]);
    t = (lv << 8) | (d & 0xff);
    ram_451fc = t;
    ram_451fe = t;
}

void Voice_ComputePitch_Mono(unsigned char *v)
{
    unsigned char *s;
    unsigned int n;
    int p, t;
    s = *(unsigned char **)(v + 23);
    n = (unsigned int)v[12] & 0x7f;
    if ((ram_41343 & 1) || s[7] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (ram_41343 & 2) {
            t = Voice_AltNoteMap_Curve[n];
            p = t - 12;
        }
        if (((char *)s)[6] < 0) {
            p = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], s[7]) - 0xd0;
            p *= ~(int)(char)s[6] + 1;
        } else {
            p = Voice_Colour_LookupIndex(n, s[7]) - 0xd0;
            p *= (char)s[6];
        }
        p >>= 5;
        p += 0xd8;
    }
    p += Voice_FineTune_Curve[*(unsigned int *)(v + 43) & 0x7f];
    p += (*(char **)(v + 15))[3];
    p += *(int *)(ToneDB_RootPtr + 224);
    p += ram_2940;
    *(int *)(v + 13) = p;
    *(unsigned int *)(v + 51) = 0;
}
