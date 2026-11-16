/* lane_sub helper B, round 12, form b (other spellings of sub_B_12a.c: a void switch whose cases call and break; the
   slot entry indexed as one subscript; the scaled amount in one expression; `if` for the rate floor; the sign test
   through *(char *)(s + 6)): the audio-channel command switch, the two slot-field writers that the ROM
   keeps in byte registers (QIYL / QIXL, H, B, W, L), and round 11's near misses (core/06_voice_envelopes_and_channels.s,
   KN5000 sub-CPU payload v1.42).
   cc900-data: AudioChannel_Dispatch 1 = AudioChannel_CaseOffsets
   cc900-module: AudioChannel_Handler_Cmd01 AudioChannel_Handler_Cmd02 AudioChannel_Handler_Cmd03
   cc900-module: AudioChannel_Handler_Cmd04_07 AudioChannel_Handler_Cmd08_0B AudioChannel_Handler_Cmd0C_0F
   cc900-module: AudioChannel_Handler_Cmd10_13 AudioChannel_Handler_Cmd14_17 AudioChannel_Handler_Cmd18_1B
   cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Detune_ScaleSymmetric Voice_Colour_LookupIndex */

extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned int ram_451e4;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char ram_41368[][0x11f];

extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Colour_LookupIndex(int a, int b);

extern int AudioChannel_Handler_Cmd01(int a);
extern int AudioChannel_Handler_Cmd02(int a);
extern int AudioChannel_Handler_Cmd03(int a);
extern int AudioChannel_Handler_Cmd04_07(int a, int b, int k);
extern int AudioChannel_Handler_Cmd08_0B(int a, int b, int k);
extern int AudioChannel_Handler_Cmd0C_0F(int a, int b, int k);
extern int AudioChannel_Handler_Cmd10_13(int a, int b, int k);
extern int AudioChannel_Handler_Cmd14_17(int a, int b, int k);
extern int AudioChannel_Handler_Cmd18_1B(int a, int b, int k);

/* ---- the command switch: AudioChannel_Dispatch and the 27 case stubs at AudioChannel_DispatchTable (one routine:
   the stubs follow the dispatch directly).  d[1] bits 0..5 = the destination command 1..27; commands 1-3 jump to
   their handlers, 4..27 call one of six handlers with the sub-index 0..3 as a stack argument ---- */

int AudioChannel_Dispatch(unsigned char a, unsigned char b, unsigned char *d)
{
    switch (d[1] & 0x3f) {
    case 1: return AudioChannel_Handler_Cmd01(a);
    case 2: return AudioChannel_Handler_Cmd02(a);
    case 3: return AudioChannel_Handler_Cmd03(a);
    case 4: AudioChannel_Handler_Cmd04_07(a, b, 0); break;
    case 5: AudioChannel_Handler_Cmd04_07(a, b, 1); break;
    case 6: AudioChannel_Handler_Cmd04_07(a, b, 2); break;
    case 7: AudioChannel_Handler_Cmd04_07(a, b, 3); break;
    case 8: AudioChannel_Handler_Cmd08_0B(a, b, 0); break;
    case 9: AudioChannel_Handler_Cmd08_0B(a, b, 1); break;
    case 10: AudioChannel_Handler_Cmd08_0B(a, b, 2); break;
    case 11: AudioChannel_Handler_Cmd08_0B(a, b, 3); break;
    case 12: AudioChannel_Handler_Cmd0C_0F(a, b, 0); break;
    case 13: AudioChannel_Handler_Cmd0C_0F(a, b, 1); break;
    case 14: AudioChannel_Handler_Cmd0C_0F(a, b, 2); break;
    case 15: AudioChannel_Handler_Cmd0C_0F(a, b, 3); break;
    case 16: AudioChannel_Handler_Cmd10_13(a, b, 0); break;
    case 17: AudioChannel_Handler_Cmd10_13(a, b, 1); break;
    case 18: AudioChannel_Handler_Cmd10_13(a, b, 2); break;
    case 19: AudioChannel_Handler_Cmd10_13(a, b, 3); break;
    case 20: AudioChannel_Handler_Cmd14_17(a, b, 0); break;
    case 21: AudioChannel_Handler_Cmd14_17(a, b, 1); break;
    case 22: AudioChannel_Handler_Cmd14_17(a, b, 2); break;
    case 23: AudioChannel_Handler_Cmd14_17(a, b, 3); break;
    case 24: AudioChannel_Handler_Cmd18_1B(a, b, 0); break;
    case 25: AudioChannel_Handler_Cmd18_1B(a, b, 1); break;
    case 26: AudioChannel_Handler_Cmd18_1B(a, b, 2); break;
    case 27: AudioChannel_Handler_Cmd18_1B(a, b, 3); break;
    }
}

/* ---- slot-field writers: part record + (j << 4) + (k << 2) is a 4-byte slot entry; byte 40 takes the
   modulation's 0x55 / 0xaa bit pairs, byte 41 (Field29) / 42 (Field2A) the depth-scaled amount (at least 1 when the
   amount is non-zero).  k and j are stack arguments (k the first, at the higher address).  The ROM keeps v in C, the
   amount in IY / its low byte, the depth in IX, the bit pairs in H and B ---- */

void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char v, unsigned char *m, unsigned char k, unsigned char j)
{
    unsigned char h, b;
    unsigned int u, dp;
    if (m[1] & 0x80) {
        if (v > 64) {
            v -= 64;
            v += v;
        } else v = 0;
    }
    if (v != 0) {
        h = ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] & 0x55;
        b = m[0] & 0x55;
        h |= b;
        b = m[0] & 0xaa;
        ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] = h | b;
    } else {
        ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] = 0;
    }
    u = v;
    dp = m[2];
    u = u * dp >> 6;
    if (u == 0 && v != 0) u = 1;
    ram_41368[part][((int)j << 4) + ((int)k << 2) + 41] = u;
}

void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char v, unsigned char *m, unsigned char k, unsigned char j)
{
    unsigned char h, b;
    unsigned int u, dp;
    if (m[1] & 0x80) {
        if (v > 64) {
            v -= 64;
            v += v;
        } else v = 0;
    }
    if (v != 0) {
        h = ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] & 0x55;
        b = m[0] & 0x55;
        h |= b;
        b = m[0] & 0xaa;
        ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] = h | b;
    } else {
        ram_41368[part][((int)j << 4) + ((int)k << 2) + 40] = 0;
    }
    u = v;
    dp = m[2];
    u = u * dp >> 6;
    if (u == 0 && v != 0) u = 1;
    ram_41368[part][((int)j << 4) + ((int)k << 2) + 42] = u;
}

/* ---- round 11 near misses ---- */

/* +254: the sign test of slot byte 7 read through a char pointer (round 11's ComputePitch_Mono showed that this gives
   the ROM's compare on memory, where (char)s[7] loads A) */
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
    if (*(char *)(s + 7) < 0) d = Detune_ScaleSymmetric(~(int)(char)s[16] + 1);
    else d = Detune_ScaleSymmetric((char)s[16]);
    t = (lv << 8) | (d & 0xff);
    ram_451fc = t;
    ram_451fe = t;
}

/* +253: the end: Int_ClampSignedToRange's result passed straight in HL; the ROM copies it to WA (unchanged here,
   the sum order swapped back to round 10's form a) */
void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    unsigned char *p;
    p = *(unsigned char **)(v + 23);
    s = p;
    t = Voice_EnvelopeLevel_Curve[p[69]];
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
    t = Int_ClampSignedToRange((int)(char)s[70] + (int)(char)s[61], 50, -50);
    d = Detune_ScaleSymmetric(t);
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}

/* +106: the attack word shifted in the temp t (WA) and copied to x (BC); the decay word built in x */
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v)
{
    unsigned char *f, *s;
    int lv, t, a, b, r, x;
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
    x = t;
    x |= 0x7f;
    ram_451e4 = x;
    *(unsigned int *)(v + 60) = x;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    if (r < 4) r = 4;
    *(unsigned int *)(v + 62) = (a << 8) | (r & 0xff);
    if (f[13] & 0x20) {
        x = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        *(unsigned int *)(v + 64) = x;
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* +35 / +64: the slot unsigned, with both sign tests through a char pointer and the 0xe0 test on the byte itself */
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
        if (*(char *)(s + 6) < 0) {
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
