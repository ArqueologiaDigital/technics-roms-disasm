/* lane_sub helper B, round 9, form a: the envelope level-pair routines of core/06_voice_envelopes_and_channels.s
   (KN5000 sub-CPU payload v1.42), and Voice_InitVoiceState again.  v is a voice record: v + 23 points at its slot data
   s, v + 35 at its part data; the level lives in an int local (the ROM's IZ) and goes out as (level << 8) pairs.
   cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity Voice_Clamp_Byte_HL PitchBend_Scale Detune_ScaleSymmetric */

extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;

extern unsigned char Voice_OutputLevel_Table[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);

/* round 8: +23, the sum was computed at the byte and the curve byte reached the local through IZL; both cast now */
void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[108], 100, 0);
    lv = (int)Voice_EnvelopeLevel_Curve[(unsigned char)lv];
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

/* the hold level (part word 10 bit 0) capped by the slot's level, else the slot level plus the part's signed byte 269 */
void Voice_ComputeVolume_CappedLFO(unsigned char *v)
{
    unsigned char *s;
    int lv;
    s = *(unsigned char **)(v + 23);
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        lv = (int)Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if ((unsigned int)lv > (unsigned int)Voice_EnvelopeLevel_Curve[s[45]])
            lv = (int)Voice_EnvelopeLevel_Curve[s[45]];
    } else {
        lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[269], 100, 0);
        lv = (int)Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}

/* EG type B: slot byte 15 through the level curve, capped by the hold level, plus the LFO depth (byte 22, velocity
   scaled) and the key tracking (byte 17 against the note v[12]), clamped 0..255; the low byte is the detune of byte 16,
   negated when byte 7 is negative */
void Voice_Calc_LevelPair_EGB(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    s = *(unsigned char **)(v + 23);
    lv = (int)Voice_EnvelopeLevel_Curve[s[15]];
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
    if ((char)s[7] < 0) d = Detune_ScaleSymmetric(-(int)(char)s[16]);
    else d = Detune_ScaleSymmetric((char)s[16]);
    ram_451fe = ram_451fc = (lv << 8) | (d & 0xff);
}

/* EG type C: as B with the slot fields 54 bytes on (69, 76, 73, 71) and the detune of bytes 70 + 61 clamped to +-50 */
void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    s = *(unsigned char **)(v + 23);
    lv = (int)Voice_EnvelopeLevel_Curve[s[69]];
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
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[70] + (int)(char)s[61], 50, -50));
    ram_45202 = ram_45200 = (lv << 8) | (d & 0xff);
}

/* round 8: +155, every register right; the doubling is `add bc,bc` in the ROM, V4.23's `<< 1` / `* 2` gave sla.
   An unsigned value here (form c tries the pseudo-register __BC) */
void Voice_InitVoiceState(unsigned char slot)
{
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    ram_451d0 = *(unsigned int *)&Voice_OutputLevel_Table[ram_41364 * 2] * 2;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}
