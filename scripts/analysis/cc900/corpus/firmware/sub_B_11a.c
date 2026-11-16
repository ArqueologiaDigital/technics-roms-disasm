/* lane_sub helper B, round 11, form a: refinements of round 10's level-pair / pitch misses and the voice-list walker
   Audio_Tick_ServiceVoices_A (core/06_voice_envelopes_and_channels.s, KN5000 sub-CPU payload v1.42).
   A pattern seen in every remaining miss: V4.23 reloads a pointer from its stack slot right after storing it, where
   the ROM goes on using the register.  Here the value is first held in a second local (p), the stack variable is set
   from it, and the next read goes through p.
   cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Detune_ScaleSymmetric
   cc900-module: Voice_Colour_LookupIndex Voice_UpdateAllLFO Voice_Step_DelayTimers */

extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned int ram_451e4;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char ram_4308e[][0x47];

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
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);

/* round 10: +15, the slot pointer reloaded after its store */
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
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[61] + (int)(char)s[70], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}

/* round 10: +111; the attack word built in a local (the ROM's BC), each curve byte through the int temp t */
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
    x = lv << 8;
    x |= 0x7f;
    ram_451e4 = x;
    *(unsigned int *)(v + 60) = x;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    r = r < 4 ? 4 : r;
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

/* round 10: +41; the note-map byte through the int temp t; the slot read as signed bytes so that the sign test is
   the ROM's compare on memory */
void Voice_ComputePitch_Mono(unsigned char *v)
{
    char *s;
    unsigned int n;
    int p, t;
    s = *(char **)(v + 23);
    n = (unsigned int)v[12] & 0x7f;
    if ((ram_41343 & 1) || (unsigned char)s[7] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (ram_41343 & 2) {
            t = Voice_AltNoteMap_Curve[n];
            p = t - 12;
        }
        if (s[6] < 0) {
            p = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], (unsigned char)s[7]) - 0xd0;
            p *= ~(int)s[6] + 1;
        } else {
            p = Voice_Colour_LookupIndex(n, (unsigned char)s[7]) - 0xd0;
            p *= s[6];
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

/* rounds 7-8: +16, the cursor reloaded before the first test; tested here through p, the value just stored */
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *v;
    unsigned char *p;
    Voice_UpdateAllLFO();
    p = Voice_Query_AllChannels() + 5;
    q = p;
    if (*p < 0x40) {
        do {
            v = &ram_4308e[*q][0];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            }
            q++;
        } while (*q < 0x40);
    }
}
