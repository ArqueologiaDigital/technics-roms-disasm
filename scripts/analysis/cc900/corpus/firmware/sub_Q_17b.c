/* lane_sub helper Q, round 17, form b (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s):
   other spellings of sub_Q_17a.c's functions (`* 2` for the doubling, register temporaries, the curves' divisor as
   one expression, the long product spelled out, a local for the discarded load, int controller parameters).
   Near misses of pool B respelled from their listings, and new functions:
   - the four modulation scalers: one expression, the doubled controller as the LEFT operand of the product (V4.23
     evaluates the right operand first, and the result takes the left operand's register);
   - idiom (a) (a second local receives the value, the kept local is set from it) in Voice_AllVoices_UpdateVelocity
     and Voice_WriteChPitchWithVib;
   - the table loaders' long product as `v *= depth` (v first, as the ROM's XWA);
   - the pan shift with the shift byte in a local of its own, set before the pan word is read;
   - the note / pan curves with the divisor's subtrahend in a local and the high range through a temporary;
   - new: AudioMod_Apply_BusRouting (16-bit record index, no runtime call), Voice_ComputePitch, the clamp after it,
     AudioChannel_AllVoices_Update_Variant3 and AudioChannel_Handler_Cmd01 / Cmd03 / Cmd02. */

extern unsigned int ram_41343;
extern unsigned char ram_4134c;
extern int __near ram_2940;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned char ram_413c9[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char *ToneDB_RootPtr;

extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern unsigned char Voice_VibratoDepth_Table[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Colour_LookupIndex(int a, int b);
extern int Voice_Colour_ClampUpper(int a, int b, int c, int d, int e);
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_Query_PartVoices_Mask7F(int part);
extern void Level_Build_Reg0C0(unsigned char *v);
extern void Voice_Build_GateCommand(unsigned char *v);
extern void Voice_ComputePitchBend2(unsigned char *v);
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern void Voice_Build_GateCmd_NoPartial(unsigned char *v);
extern void ToneGen_ReadPitch_AndScale(int ch);
extern void ToneGen_WriteLevelPair(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void AudioMod_Apply_Porta_Curve(int part, unsigned int val, unsigned char *m);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void TVF_Refresh_Sounding_Voices(unsigned char *list);
/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
extern void AudioChannel_AllVoices_UpdPan(unsigned char *list);

/* the word at +24 of output-slot record w (37 bytes each, from +110) of a part's 287-byte record */
#define SLOTW(part, w) \
    (((unsigned int *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e])[12])

/* ---- per-bus enable bits: the 4th argument comes on the stack ---- */

void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, unsigned int a, unsigned int b)
{
    unsigned char w;
    for (w = 0; w < 4; w++) {
        if (AudioMod_BusRouting_EnableBits[w] & mask) {
            if (AudioMod_BusRouting_OrIXBits[w] & mask) {
                SLOTW(part, w) |= a | b;
            } else {
                SLOTW(part, w) &= ~b;
                SLOTW(part, w) |= a;
            }
        } else {
            SLOTW(part, w) &= ~(a | b);
        }
    }
}

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (((unsigned int)v - 64) << 1) * (unsigned int)m[2];
    else r = (unsigned int)v * (unsigned int)m[2];
    r = r >> 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (((unsigned int)v - 64) << 1) * (unsigned int)m[2];
    else r = (unsigned int)v * (unsigned int)m[2];
    r = r >> 6;
    ram_41383[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (((int)v - 64) * 2) * (int)m[2];
    else r = (int)v * (int)m[2];
    r = (r >> 1) / 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (((int)v - 64) * 2) * (int)m[2];
    else r = (int)v * (int)m[2];
    r = r / 127;
    ram_41388[part * 0x11f] = r;
}

/* ---- curves: 0 inside [q1, q2], -512 outside [q0, q3], a -64 slope between ---- */

int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char n;
    int h, t;
    n = p[12];
    h = (int)n & 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else h = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            t = h - (int)q[36];
            h = t * -64 / (q[37] - (int)q[36]);
        }
    } else h = 0;
    return h;
}

int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, t;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else h = ((int)q[30] - h) * -64 / (q[30] - (int)q[31]);
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else {
            t = h - (int)q[32];
            h = t * -64 / (q[33] - (int)q[32]);
        }
    } else h = 0;
    return h;
}

/* ---- the poly pitch: Voice_ComputePitch_Mono plus the colour clamp, the two curves and the part's byte 286 ---- */

/* cc900-module: Voice_Colour_LookupIndex Voice_Colour_ClampUpper Voice_InterpolatePanCurve Voice_InterpolateNoteCurve */
void Voice_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned int n;
    int p, t, q;
    s = *(unsigned char **)(v + 23);
    n = v[12];
    if (n & 0x80) *(unsigned int *)(v + 1) |= 0x800;
    n &= 0x7f;
    if ((ram_41343 & 1) || s[25] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else if (ram_41343 & 2) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (((char *)s)[24] < 0) {
            q = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], s[25]) - 0xd0;
            q *= ~(int)(char)s[24] + 1;
        } else {
            q = Voice_Colour_LookupIndex(n, s[25]) - 0xd0;
            q *= (char)s[24];
        }
        p = (q >> 5) + 0xd8;
    }
    p += Voice_Colour_ClampUpper(*(int *)(v + 8), s[26], s[27], s[28], (char)s[29]);
    p += Voice_FineTune_Curve[*(unsigned int *)(v + 43) & 0x7f];
    p += (*(char **)(v + 15))[3];
    p += *(int *)(ToneDB_RootPtr + 224);
    p += ram_2940;
    p += Voice_InterpolatePanCurve(v, s);
    p += Voice_InterpolateNoteCurve(v, s);
    if (s[0] & 0x80) p += (*(unsigned char **)(v + 35))[286];
    *(int *)(v + 13) = p;
    *(unsigned int *)(v + 51) = 0;
}

/* the 17 bytes after Voice_ComputePitch's ret: a signed clamp (WA value, BC high, DE low), a twin of
   Int_ClampSignedToRange */
int Voice_ComputePitch_InlineData(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

/* ---- portamento, second form ---- */

/* cc900-module: Voice_Build_OutputLevel */
int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t;
    unsigned int u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = 0xfe00;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != -512) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}

/* ---- level pairs ---- */

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Detune_ScaleSymmetric */
void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *p;
    unsigned char *s;
    int lv, t, d;
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
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((char)s[70] + (char)s[61], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}

/* cc900-module: Int_ClampSignedToRange PitchBend_Scale */
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
        *(unsigned int *)(v + 64) = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* ---- channel pan shift: the patch (v + 39) word 24 bit 8 enables it, bit 9 makes it subtract ---- */

/* cc900-module: Int_ClampSignedToRange */
void Voice_WriteChPanShift(unsigned char *v, unsigned char flag)
{
    int l, r;
    register int s;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451e6 = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}

/* cc900-module: Int_ClampSignedToRange */
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r;
    register int s;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451e6 = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}

/* ---- vibrato depth of every voice of a part that shares the slot's byte 14 ---- */

void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    register unsigned char u;
    unsigned char *q;
    v = *(unsigned char **)&ram_4308e[slot][0x1f];
    if (v[0] & 8) {
        u = v[14];
        n = u;
        ram_451f8 = (unsigned int)Voice_VibratoDepth_Table[u] << 8 | 0x80;
        ram_451fa = (unsigned int)Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_4308e[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}

void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    register unsigned char u;
    unsigned char *q;
    ram_4134c = v & 0x0f;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_41372[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                u = ram_4308e[*q][4];
                p = u;
                switch ((*(unsigned char **)&ram_4136e[u * 0x11f])[16] & 0xc0) {
                case 0:
                case 0x40:
                case 0xc0:
                    Level_Build_Reg0C0(ram_4308e[*q]);
                    Voice_Build_GateCommand(ram_4308e[*q]);
                    break;
                case 0x80:
                    Voice_ComputePitchBend2(ram_4308e[*q]);
                    Voice_Build_GateCmd_NoPartial(ram_4308e[*q]);
                    break;
                }
                ToneGen_ReadPitch_AndScale(*q);
            }
        }
    }
}

/* ---- the two delay counters of a voice's word 47: the callee's first parameter a byte ---- */

void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    unsigned int k;
    t = *(unsigned int *)(p + 47);
    if (t & 32768) {
        t -= 0x100;
        if ((t & 0x7f00) == 0) {
            k = *p;
            ToneGen_WriteSingleReg(k, *(unsigned int *)(p + 45));
            Voice_Clear_HoldBit(*p);
            t &= ~0x8000;
        }
    }
    if (t & 0x80) {
        t--;
        if ((t & 0x7f) == 0) {
            Voice_Reload_Levels(*p);
            t &= 0x7f;
        }
    }
    *(unsigned int *)(p + 47) = t;
}

/* ---- output-list loaders: v *= depth ---- */

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = (unsigned int)v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = v * (unsigned long)Voice_PitchDepth_Scale[depth];
    v >>= 8;
    ram_4520c = (unsigned int)v;
    *(unsigned int *)&ram_413c3[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}

void Voice_LoadFilterTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 0);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        ram_4520a = (unsigned int)v;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = v * (unsigned long)Voice_FilterDepth_Scale[depth];
    v >>= 8;
    ram_4520e = (unsigned int)v;
    *(unsigned int *)&ram_413bf[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451cc);
}

void Voice_LoadToneTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_ChanFreq_WritePacket2(ch);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        ram_45206 = (unsigned int)v;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

/* ---- voice-list walker: only layer type 0x10 does anything; the load of the patch pointer is discarded ---- */

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: ToneGen_WriteVoice_Reg21_Reg22 */
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    unsigned char *f;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 0x20:
            break;
        case 8:
            break;
        case 0x10:
            f = *(unsigned char **)(v + 19);
            Voice_Calc_LevelPair_FixedAtk(v);
            Voice_WriteChPanShift2(v, 0);
            ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            break;
        }
    }
}

/* ---- audio-channel commands 1, 3 and 2: scale the controller, set the bus bits, refresh the part's voices ---- */

/* cc900-module: AudioMod_Apply_Porta_Curve AudioMod_Apply_BusRouting Pitch_Refresh_Sounding_Voices */
void AudioChannel_Handler_Cmd01(unsigned char part, unsigned int val, unsigned char *m)
{
    if (val & 32768) val &= ~0x8000;
    else val <<= 7;
    AudioMod_Apply_Porta_Curve(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 16, 32);
    Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}

/* cc900-module: AudioMod_Scale_To_Part_1F AudioMod_Apply_BusRouting TVF_Refresh_Sounding_Voices */
void AudioChannel_Handler_Cmd03(unsigned char part, unsigned int val, unsigned char *m)
{
    AudioMod_Scale_To_Part_1F(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 64, 128);
    TVF_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}

/* cc900-module: AudioMod_Scale_To_LevelPairShift AudioMod_Scale_To_LevelPairShf AudioMod_Apply_BusRouting */
/* cc900-module: AudioChannel_AllVoices_Update_PanShift AudioChannel_AllVoices_UpdPan */
void AudioChannel_Handler_Cmd02(unsigned char part, unsigned int val, unsigned char *m)
{
    unsigned char *list;
    AudioMod_Scale_To_LevelPairShf(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 256, 512);
    switch ((*(unsigned char **)&ram_4136e[part * 0x11f])[16] & 0xc0) {
    case 0:
        list = Voice_Query_PartVoices_Mask7F(part);
        break;
    case 0x80:
        list = Voice_Query_PartVoices(part);
        break;
    case 0x40:
        break;
    case 0xc0:
        break;
    }
    AudioChannel_AllVoices_UpdPan(list);
}
