/* lane_sub helper AP, round 28, form c: form a with one change per function --
   EGA no temporary, the byte converted, `lv = (unsigned int)Curve[(unsigned char)lv];`;  FixedAtk the table byte
   converted instead of b, `(b << 8) | ((unsigned int)Table[s[12]] & 0xff)`;  Mono lv int again and d
   `register unsigned int`;  FullReset the sum spelled with integers,
   `*(unsigned char *)((unsigned long)((unsigned int)j + 8) + (unsigned long)ram_24e6[(int)i]) = 0xff;`.
   Form a's notes follow.
   Round 28, form a (KN5000 sub-CPU payload v1.42, core/05 and core/06).
   Correction to round 27: in idiff's output `-` lines are OURS and `+` lines the ROM's.  Round 27 read two of
   them backwards (EGA, FixedAtk); the spellings below follow the correct reading.
   Voice2_UpdatePitch is dropped: +210 in rounds 26 and 27 (the ROM loads v before e at `e[6] = v[12]`; volatile e
   gives that order but loses the `lda` of the base, address-taken e keeps `lda` but loads e first).
   - Voice_Calc_LevelPair_EGA (sub_B_9a / 27, +63): the ROM gives the curve byte to lv through WA
     (`extz wa; ld iz,wa`); assigning it directly gives `ld izl,a; extz iz`.  README's idiom: an int temporary,
     `k = Curve[(unsigned char)lv]; lv = k;`.  Form a: k an int.
   - Voice_Calc_LevelPair_FixedAtk (sub_Q_17b, +225, 27b the same): at the word stored to v+64 the ROM COPIES b
     to BC before the shift (`ld bc,de; sla 8,bc; or bc,wa`); 17b shifted DE in place.  Form a: from 17b, the
     shift on a converted copy, `((unsigned int)b << 8) | (..)`.
   - Voice_Calc_LevelPair_Mono (sub_AG_22c, +65; no change from declaration order or `register` in round 27):
     the ROM keeps lv in QIZ and d in IZ, V4.23 the reverse.  Form a: lv declared `unsigned int` (a type
     difference may change the order V4.23 hands out the XIZ halves).
   - VoiceState_FullReset (sub_AH_20c, +9; new for this helper): phases 2 and 4 match; in phases 1 and 3 the ROM
     builds the column offset first ((unsigned int)j + K into HL), then the row address base + (int)i * 12 with a
     signed multiply, and adds the zero-extended offset to it in the offset's register; 20c folded row and column
     into one index and multiplied unsigned.  Form a: the offset on the left of a pointer sum,
     `*((unsigned int)j + 8 + ram_24e6[(int)i]) = 0xff;`.
   cc900-options: -Xr
*/

extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char __near ram_24e6[][12];
extern unsigned char __near ram_1e4d[][27];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Voice_Clamp_Byte_HL(int a);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void VoiceState_FullReset(void);

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Voice_Calc_LevelPair_Mono */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    unsigned char *p;
    int lv;
    int t;
    register unsigned int d;
    int l1, l2;
    int w, r, y;
    int k;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    k = Voice_LevelPair_AttackCurve[p[39]];
    lv = k;
    if (p[51] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[48], p[49], p[50], (char)p[51]);
        if (p[46] != 0) {
            d = PitchBend_Scale((char)p[46], v[12], 4);
            lv = Int_ClampSignedToRange(lv + t + d, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv + t, 0xff, 0);
    } else if (p[46] != 0) {
        d = PitchBend_Scale((char)p[46], v[12], 4);
        lv = Int_ClampSignedToRange(lv + d, 0xff, 0);
    }
    if (**(unsigned char **)(v + 31) & 1) {
        k = lv;
        if (k == 0xff) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451e4 = w;
    *(unsigned int *)(v + 60) = w;
    l1 = Int_ClampSignedToRange((int)p[41] + (int)(*(char **)(v + 35))[267], 100, 0);
    l1 = Voice_EnvelopeLevel_Curve[(unsigned char)l1];
    l2 = Int_ClampSignedToRange((int)p[43] + (int)(*(char **)(v + 35))[267], 100, 0);
    l2 = Voice_EnvelopeLevel_Curve[(unsigned char)l2];
    if (p[52] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[48], p[49], p[50], (char)p[52]);
        if (p[47] != 0) {
            d = PitchBend_Scale((char)p[47], v[12], 4);
            l1 = Int_ClampSignedToRange(l1 + t + d, 0xff, 0);
            l2 = Int_ClampSignedToRange(l2 + t + d, 0xff, 0);
        } else {
            l1 = Int_ClampSignedToRange(l1 + t, 0xff, 0);
            l2 = Int_ClampSignedToRange(l2 + t, 0xff, 0);
        }
    } else if (p[47] != 0) {
        d = PitchBend_Scale((char)p[47], v[12], 4);
        l1 = Int_ClampSignedToRange(l1 + d, 0xff, 0);
        l2 = Int_ClampSignedToRange(l2 + d, 0xff, 0);
    }
    k = Voice_EnvelopeRate_Table[p[42]];
    r = k;
    r = r < 4 ? 4 : r;
    k = Voice_EnvelopeRate_Table[p[44]];
    y = k;
    ram_451e6 = (l1 << 8) | (r & 0xff);
    ram_451e8 = (l2 << 8) | (y & 0xff);
}

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity Voice_Calc_LevelPair_EGA Voice_Clamp_Byte_HL */
void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[108], 100, 0);
    lv = (unsigned int)Voice_EnvelopeLevel_Curve[(unsigned char)lv];
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

/* cc900-module: Int_ClampSignedToRange PitchBend_Scale Voice_Calc_LevelPair_FixedAtk */
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
    t = lv << 8;
    r = t;
    r |= 0x7f;
    ram_451e4 = r;
    *(unsigned int *)(v + 60) = r;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    t = r < 4 ? 4 : r;
    r = t;
    *(unsigned int *)(v + 62) = (a << 8) | (t & 0xff);
    if (f[13] & 0x20) {
        *(unsigned int *)(v + 64) = (b << 8) | ((unsigned int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* cc900-module: Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource VoiceState_FullReset */
void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            *(unsigned char *)((unsigned long)((unsigned int)j + 8) + (unsigned long)ram_24e6[(int)i]) = 0xff;
            *(unsigned char *)((unsigned long)(unsigned int)j + (unsigned long)ram_24e6[(int)i]) = i;
            *(unsigned char *)((unsigned long)((unsigned int)j + 4) + (unsigned long)ram_24e6[(int)i]) = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++)
            *(unsigned char *)((unsigned long)(unsigned int)j + (unsigned long)ram_1e4d[(int)i]) = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
