/* lane_sub helper B, round 10, form b (other spellings of sub_B_10a.c: the slot pointer assigned inside the first
   read, which the ROM does not reload; the operands of the clamped sums swapped; plain if instead of ?:; -x for the
   negated depth): level-pair and pitch routines of core/06_voice_envelopes_and_channels.s that
   reach their helpers with calr (KN5000 sub-CPU payload v1.42).  v is a voice record: v + 19 / v + 23 point at its
   tone / slot data, v + 35 at its part data.  Round 9's listings: a curve byte assigned to the int level went in
   through IZL + extz IZ, where the ROM extends in WA and copies (`extz wa; ld iz,wa`), so every such load now goes
   through the int temporary t (which round 9 showed in WA).
   cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity Voice_Clamp_Byte_HL PitchBend_Scale Detune_ScaleSymmetric
   cc900-module: Voice_Colour_LookupIndex */

extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned int ram_451e4;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned char *ToneDB_RootPtr;

extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Colour_LookupIndex(int a, int b);

void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((int)(*(char **)(v + 35))[108] + (int)s[45], 100, 0);
    t = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    lv = t;
    if ((*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) && !(*(unsigned int *)(v + 1) & 0x100)) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}

void Voice_ComputeVolume_CappedLFO(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        lv = t;
        if ((unsigned int)lv > (unsigned int)Voice_EnvelopeLevel_Curve[s[45]]) {
            t = Voice_EnvelopeLevel_Curve[s[45]];
            lv = t;
        }
    } else {
        lv = Int_ClampSignedToRange((int)(*(char **)(v + 35))[269] + (int)s[45], 100, 0);
        t = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
        lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}

void Voice_Calc_LevelPair_EGB(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    t = Voice_EnvelopeLevel_Curve[(s = *(unsigned char **)(v + 23))[15]];
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
    if ((char)s[7] < 0) d = Detune_ScaleSymmetric(~(int)(char)s[16] + 1);
    else d = Detune_ScaleSymmetric((char)s[16]);
    t = (lv << 8) | (d & 0xff);
    ram_451fc = t;
    ram_451fe = t;
}

void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    t = Voice_EnvelopeLevel_Curve[(s = *(unsigned char **)(v + 23))[69]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[76] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[76]);
        if (s[71] != 0) {
            lv += PitchBend_Scale((char)s[71], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[71] != 0) {
        lv += PitchBend_Scale((char)s[71], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[61] + (int)(char)s[70], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}

/* new: the fixed-attack level pair.  Sets bit 15 of v's word 1; the attack level (slot byte 8 through the attack
   curve, plus key tracking from byte 14, clamped 0..255) goes to 0x451e4 and v + 60 with 0x7f below it; the sustain /
   decay levels (bytes 9, 11) and rates (bytes 10, 12; the first at least 4) to v + 62 / v + 64; v[70] is the release
   level of byte 13 when the tone's byte 13 bit 5 is set, else 0 */
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v)
{
    unsigned char *f, *s;
    int lv, t, a, b, r;
    f = *(unsigned char **)(v + 19);
    s = *(unsigned char **)(v + 23);
    *(unsigned int *)(v + 1) |= 0x8000;
    t = Voice_LevelPair_AttackCurve[s[8]];
    lv = t;
    if (s[14] != 0) {
        lv += PitchBend_Scale((char)s[14], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    *(unsigned int *)(v + 60) = ram_451e4 = (lv << 8) | 0x7f;
    a = Voice_EnvelopeLevel_Curve[s[9]];
    b = Voice_EnvelopeLevel_Curve[s[11]];
    r = Voice_EnvelopeRate_Table[s[10]];
    if (r < 4) r = 4;
    *(unsigned int *)(v + 62) = (a << 8) | (r & 0xff);
    if (f[13] & 0x20) {
        *(unsigned int *)(v + 64) = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* new: the mono pitch.  n = the note (v[12] & 0x7f); the alternative note map when the global flag 0 is set or the
   slot's byte 7 is 0xe0, else the colour lookup scaled by the slot's signed byte 6, >> 5, + 0xd8; then fine tune
   (v's word 43), the tone's signed byte 3, the root table's word 224 and the master tune at 0x2940 */
void Voice_ComputePitch_Mono(unsigned char *v)
{
    unsigned char *s;
    unsigned int n;
    int p;
    s = *(unsigned char **)(v + 23);
    n = (unsigned int)v[12] & 0x7f;
    if ((ram_41343 & 1) || s[7] == 0xe0) {
        p = (int)Voice_AltNoteMap_Curve[n] - 12;
    } else {
        if (ram_41343 & 2) p = (int)Voice_AltNoteMap_Curve[n] - 12;
        if ((char)s[6] < 0) {
            p = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], s[7]) - 0xd0;
            p *= -(int)(char)s[6];
        } else {
            p = Voice_Colour_LookupIndex(n, s[7]) - 0xd0;
            p *= (char)s[6];
        }
        p = (p >> 5) + 0xd8;
    }
    p += Voice_FineTune_Curve[*(unsigned int *)(v + 43) & 0x7f];
    p += (*(char **)(v + 15))[3];
    p += *(int *)(ToneDB_RootPtr + 224);
    p += ram_2940;
    *(int *)(v + 13) = p;
    *(unsigned int *)(v + 51) = 0;
}
