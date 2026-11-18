/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AG_22c.c (2026-11-18-29-sub-r21f)
   sha256 7bc8ddf6054653962264ee368ff6bb8ce6547a0d0a4aeb0851b55931554cb82c (tar-sha256); compiled at -Xr */
/* lane_sub round 21: sub_AG_21c.c without Voice_Step_ExprRamp, whose __IZ may crash V4.23 (bug candidate 12) and lose the whole file; sub_AG_21c.c goes into the same run */
/* lane_sub helper AG, round 21, form c: sub_AG_21a.c with these changes --
   Mono: `register int d`.  Full / PatchAtk: CheckMax as `lv == 0xffU`.  FixedAtk: `(int)(unsigned int)b << 8`.
   ExprRamp: the word assigned inside the first test (`((s = ...) & 0x7f) == 0`) instead of idiom (a).
   UpdateAllLFO: `t = t * r`.  ServiceVoices_B: `if (*(q = ...) < 0x40) do ... while`.  TickNoteDecay:
   `ram_4135f = ram_4135f - 1`.  Porta_Curve: `r = m[2] * r; r >>= 6;`.  02A061: `0x1d + (int)i * 3`.
   Form a's notes follow.
   lane_sub helper AG, round 21, form a (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s).
   Round 20 (run 2026-11-18-18-sub-r21a) left these open; each starts from its best round-20 form, changed where the
   instruction diff (MAME disassembly of both sides) showed the first real difference:
   - LevelPair Mono / Full / PatchAtk: a byte loaded into an int register variable goes through an int temporary k
     in WA (`k = T[i]; lv = k;`: the ROM's `extz wa; ld iz,wa`, as the built EGC's `t`); the char sums with explicit
     (int) operands (V4.23 added them in 8 bits); the CheckMax compare through k (the ROM copies lv into WA first).
     Mono: lv declared before d (round 20 gave lv IZ in both orders; with k the counts change).
   - FixedAtk: the ROM copies b (DE) into BC before `<< 8` in the then-branch; here b goes through a comma.
   - Voice_Step_ExprRamp: round 20 b (__IZ) plus idiom (a) at the entry; __IZ compared without the (int) cast
     (the cast made V4.23 copy IZ into WA; the ROM compares IZ in place).
   - Voice_UpdateAllLFO: the compare is with 0x100 (the ROM's cp QIZ,0x0100); the arguments `(unsigned char)i` to
     int parameters (the ROM extends); the product's left operand built in t first; loops 2 / 3 as round 20 b.
   - Audio_Tick_ServiceVoices_B: idiom (a) at the loop entries (the ROM tests the fresh pointer without a reload).
   - Voice_TickNoteDecay: round 20 b with `-= 1` (the ROM compares the cell again after its dec).
   - AudioMod_Apply_Porta_Curve: the first product's operands swapped (`m[2] * r`).
   - VoiceModWheel_DataTable_02A061: the descriptor offset in int (`(int)i * 3 + 0x1d`; V4.23 had it in 8 bits). */

#ifdef __GNUC__
extern unsigned int __iz;
#endif
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned int ram_41343;
extern unsigned char ram_4135e;
extern unsigned char ram_4135f;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4137b[];
extern unsigned char ram_41385[];
extern unsigned char ram_4138e[];
extern unsigned char ram_4308e[][0x47];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_45204;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_LevelPair_Bit11Default;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Voice_ApplyPortamento(unsigned char *v);
extern void ToneGen_WriteExprReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p, unsigned char *v);
extern void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern unsigned int Voice_AdvanceLFOPhase(unsigned char *p);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
extern void ToneGen_WrExtParam_1C0_Single(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
extern void ToneGen_WrExtParam_TypeDisp_Sgl(int ch, unsigned int *p);
extern void Voice_SetPanning(unsigned char *v);
extern void Voice_InitVoiceState(unsigned char slot);
extern void ToneGen_WriteVoiceParams(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);
extern void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
extern void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);
extern void Pitch_Bend_Ramp_Tick(void);
extern void Pitch_Emit_Reg400(unsigned char *v);
extern void Voice_Step_DelayTimers(unsigned char *p);
extern unsigned char *Voice_Query_AllChannels(void);
extern void ToneGen_WriteVoicePitch(int ch, unsigned int *p);

void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_Step_ExprRamp(unsigned char *v);
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val);
void Voice_UpdateAllLFO(void);
void Voice_TickNoteDecay(void);
void Audio_Tick_ServiceVoices_B(void);

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    unsigned char *p;
    int lv;
    int t;
    register int d;
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

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Full(unsigned char *v)
{
    unsigned char *p;
    int lv;
    int t;
    int d;
    int l1, l2;
    int w, r, y;
    int k;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    if (*(unsigned int *)(v + 1) & 0x800) {
        k = Voice_LevelPair_Bit11Default;
        lv = k;
    } else {
        lv = Int_ClampSignedToRange((int)p[39] + (int)(*(char **)(v + 35))[268], 100, 0);
        k = Voice_LevelPair_AttackCurve[(unsigned char)lv];
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
    }
    if (**(unsigned char **)(v + 31) & 1) {
        if (lv == 0xffU) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451e4 = w;
    *(unsigned int *)(v + 60) = w;
    l1 = Voice_EnvelopeLevel_Curve[p[41]];
    l2 = Voice_EnvelopeLevel_Curve[p[43]];
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

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v)
{
    unsigned char *p;
    int lv;
    int t;
    int d;
    unsigned char *q;
    int l1, l2;
    unsigned char *x;
    int w, r, y;
    int k;
    p = *(unsigned char **)(v + 23);
    q = *(unsigned char **)(v + 31);
    x = *(unsigned char **)(v + 35);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    lv = Int_ClampSignedToRange((int)p[39] + (int)(char)x[107], 100, 0);
    k = Voice_LevelPair_AttackCurve[(unsigned char)lv];
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
    if (*q & 1) {
        if (lv == 0xffU) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451e4 = w;
    *(unsigned int *)(v + 60) = w;
    l1 = Voice_EnvelopeLevel_Curve[p[41]];
    l2 = Voice_EnvelopeLevel_Curve[p[43]];
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
    *(unsigned int *)(v + 62) = (l1 << 8) | (r & 0xff);
    *(unsigned int *)(v + 64) = (l2 << 8) | (y & 0xff);
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
        *(unsigned int *)(v + 64) = ((int)(unsigned int)b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* cc900-module: Voice_ApplyPortamento */

/* cc900-data: AudioMod_Apply_Porta_Curve 1 = AudioMod_PortaCurve_CaseOffsets */
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m)
{
    long r;
    if (m[1] & 0x80) r = (long)val - 8192;
    else r = (long)val >> 1;
    r = m[2] * r;
    r >>= 6;
    switch (part) {
    case 0x10:
    case 0x11:
    case 0x12:
    case 0x13:
    case 0x15:
    case 0x16:
    case 0x17:
    case 0x18:
    case 0x19:
        r = r * 12;
        break;
    default:
        r = r * ram_4137b[part * 0x11f];
        break;
    }
    r <<= 9;
    if (r > 0) r = r / 16384;
    else r = r / 16383;
    *(int *)&ram_41385[part * 0x11f] = r;
}

/* cc900-module: AudioChannel_Dispatch */
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val)
{
    unsigned char i;
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_4136e + (int)part * 287) + (0x1d + (int)i * 3));
        break;
    }
}

/* cc900-module: Voice_AdvanceLFOPhase EGEnv_Compute_A EGEnv_Compute_B Voice_Freq_WriteLeft */
void Voice_UpdateAllLFO(void)
{
    unsigned int i;
    unsigned char *p;
    unsigned int r;
    unsigned long t;
    for (i = 0; i < 0x80; i++) {
        p = ram_4424e + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_4520c = EGEnv_Compute_A((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_4520c & 0x1fff;
                    t = t * r;
                    ram_4520c &= 0xe000;
                    ram_4520c |= (unsigned int)(t >> 8);
                }
                ToneGen_WriteExtParam_600(i, ram_451cc);
            }
        }
    }
    for (i = 0; i < 0x40; i++) {
        p = (unsigned char *)((unsigned long)ram_44257 + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_45204 = EGEnv_Compute_B((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_45204 & 0x1fff;
                    t = t * r;
                    ram_45204 &= 0xe000;
                    ram_45204 |= (unsigned int)(t >> 8);
                }
                ToneGen_WrExtParam_1C0_Single(i, ram_451cc);
            }
        }
    }
    for (i = 0; i < 0x80; i++) {
        p = (unsigned char *)((unsigned long)ram_44260 + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                Voice_Freq_WriteLeft((unsigned char)i);
                if (r != 0x100) {
                    if (i < 0x40) {
                        t = (unsigned long)ram_45204 & 0x1fff;
                        t = t * r;
                        ram_45204 &= 0xe000;
                        ram_45204 |= (unsigned int)(t >> 8);
                    } else {
                        t = (unsigned long)ram_4520e & 0x1fff;
                        t = t * r;
                        ram_4520e &= 0xe000;
                        ram_4520e |= (unsigned int)(t >> 8);
                    }
                }
                ToneGen_WrExtParam_TypeDisp_Sgl(i, ram_451cc);
            }
        }
    }
}

/* cc900-module: Voice_InitVoiceState */
void Voice_TickNoteDecay(void)
{
    unsigned char i;
    unsigned char buf[14];
    if (ram_4135e != 0) {
        ram_4135f = ram_4135f - 1;
        if (ram_4135f == 0) {
            Voice_SetPanning(buf);
            if (buf[10] < 0x40) {
                Voice_InitVoiceState(i = buf[10]);
                ToneGen_WriteVoiceParams(i, ram_451cc);
                ToneGen_WriteSingleReg(i, *(unsigned int *)(ram_4308e[i] + 45));
            }
            ram_4135e--;
            ram_4135f = 4;
        }
    }
}

/* cc900-module: Voice_TickNoteDecay Pitch_Bend_Ramp_Tick Pitch_Emit_Reg400 Voice_Step_DelayTimers Voice_Step_ExprRamp */
/* cc900-module: Voice_ToneTableRamp_Up Voice_ToneTableApply_Filter Voice_ToneTableRamp_Down Voice_ToneTableApply_Pitch */
void Audio_Tick_ServiceVoices_B(void)
{
    unsigned char f;
    unsigned char *q;
    unsigned char *v;
    unsigned char i;
    unsigned char *rec;
    Voice_TickNoteDecay();
    Pitch_Bend_Ramp_Tick();
    if (ram_41343 & 0x400) {
        if (*(q = Voice_Query_AllChannels() + 5) < 0x40) do {
            v = ram_4308e[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_451cc);
            }
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000L) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
                else if (*(unsigned int *)(v + 49) & 0x8000L) Voice_Step_ExprRamp(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if (*(unsigned int *)(v + 49) & 0x8000L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
            q++;
        } while (*q < 0x40);
    } else {
        if (*(q = Voice_Query_AllChannels() + 5) < 0x40) do {
            v = ram_4308e[*q];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000L) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
                else if (*(unsigned int *)(v + 49) & 0x8000L) Voice_Step_ExprRamp(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if (*(unsigned int *)(v + 49) & 0x8000L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
            q++;
        } while (*q < 0x40);
    }
    for (i = 0; i < 26; i++) {
        rec = &ram_41368[i * 0x11f];
        f = rec[99];
        if (f & 1) {
            if (f & 2) {
                if (f & 4) {
                    if (!(f & 8)) Voice_ToneTableRamp_Up(i, rec);
                } else {
                    rec[99] |= 4;
                    Voice_ToneTableApply_Filter(i, rec);
                }
            } else if (!(f & 4)) {
                if (!(f & 0x10)) Voice_ToneTableRamp_Down(i, rec);
            } else {
                rec[99] &= ~4;
                Voice_ToneTableApply_Pitch(i, rec);
            }
        }
    }
}
