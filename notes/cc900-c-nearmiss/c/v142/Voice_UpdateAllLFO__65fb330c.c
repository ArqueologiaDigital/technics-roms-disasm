/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AG_20b.c (2026-11-18-18-sub-r21a)
   sha256 65fb330c447981ca5949dd5873dd1bdadf83a46d242d0a7a779fa204f2f5bed6 (tar-sha256); compiled at -Xr */
/* lane_sub helper AG, round 20, form b: the functions of sub_AG_20a.c, other spellings.
   - LevelPair Mono / Full / PatchAtk: d declared BEFORE lv (the ROM has lv in QIZ in Mono but in IZ in Full /
     PatchAtk); the tail's rates as `(unsigned char)r` (the ROM copies r into WA before clearing W); PatchAtk's q and x
     in a block of their own and l1 / l2 in a second block (the ROM gives q and l1 one slot).
   - FixedAtk: the then-branch's rate through t (as the first store, which matched), b unconverted.
   - Voice_Step_ExprRamp: n is V4.23's pseudo-register __IZ (ToneGen_WriteVoice_Direct needed __IZ).
   - AudioMod_Apply_Porta_Curve: `(r * 3) << 2` for the cases.
   - Voice_ModWheel_Apply: the descriptor offset `i * 3L + 0x15`.
   - Voice_UpdateAllLFO: the second and third pointers built in integers (the ROM adds in XWA, then copies to XBC).
   - Voice_TickNoteDecay: `--ram_4135f == 0`, the slot through the call's argument, the word as ram_4308e[i] + 45.
   - Voice_ToneTableApply_Filter / _Pitch: `while` loops; the division into t in one statement.
   - Audio_Tick_ServiceVoices_B: the flag words converted to unsigned long instead of long constants; f declared
     first. */

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
extern unsigned char ram_430bb[];
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
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];

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
extern unsigned int EGEnv_Compute_A(unsigned char n);
extern unsigned int EGEnv_Compute_B(unsigned char n);
extern void Voice_Freq_WriteLeft(unsigned char n);
extern void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
extern void ToneGen_WrExtParam_1C0_Single(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
extern void ToneGen_WrExtParam_TypeDisp_Sgl(int ch, unsigned int *p);
extern void Voice_SetPanning(unsigned char *v);
extern void Voice_InitVoiceState(unsigned char slot);
extern void ToneGen_WriteVoiceParams(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);
extern void Voice_LoadPitchTable_Ch(int ch, char depth);
extern void Voice_LoadFilterTable_Ch(int ch, char depth);
extern void Voice_LoadToneTable_Ch(int ch, char depth);
extern void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s);
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
void Voice_ModWheel_Apply(unsigned char part, unsigned char val);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val);
void Voice_UpdateAllLFO(void);
void Voice_TickNoteDecay(void);
void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);
void Audio_Tick_ServiceVoices_B(void);

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    unsigned char *p;
    int d;
    int t;
    int lv;
    int l1, l2;
    int w, r, y;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    lv = Voice_LevelPair_AttackCurve[p[39]];
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
        if (lv == 0xff) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451e4 = w;
    *(unsigned int *)(v + 60) = w;
    l1 = Int_ClampSignedToRange(p[41] + (*(char **)(v + 35))[267], 100, 0);
    l1 = Voice_EnvelopeLevel_Curve[(unsigned char)l1];
    l2 = Int_ClampSignedToRange(p[43] + (*(char **)(v + 35))[267], 100, 0);
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
    r = Voice_EnvelopeRate_Table[p[42]];
    r = r < 4 ? 4 : r;
    y = Voice_EnvelopeRate_Table[p[44]];
    ram_451e6 = (l1 << 8) | (unsigned char)r;
    ram_451e8 = (l2 << 8) | (unsigned char)y;
}

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Full(unsigned char *v)
{
    unsigned char *p;
    int d;
    int t;
    int lv;
    int l1, l2;
    int w, r, y;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    if (*(unsigned int *)(v + 1) & 0x800) lv = Voice_LevelPair_Bit11Default;
    else {
        lv = Int_ClampSignedToRange(p[39] + (*(char **)(v + 35))[268], 100, 0);
        lv = Voice_LevelPair_AttackCurve[(unsigned char)lv];
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
        if (lv == 0xff) lv--;
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
    r = Voice_EnvelopeRate_Table[p[42]];
    r = r < 4 ? 4 : r;
    y = Voice_EnvelopeRate_Table[p[44]];
    ram_451e6 = (l1 << 8) | (unsigned char)r;
    ram_451e8 = (l2 << 8) | (unsigned char)y;
}

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v)
{
    unsigned char *p;
    int d;
    int t;
    int lv;
    int w, r, y;
    p = *(unsigned char **)(v + 23);
    {
        unsigned char *q;
        unsigned char *x;
        q = *(unsigned char **)(v + 31);
        x = *(unsigned char **)(v + 35);
        if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
        else *(unsigned int *)(v + 1) |= 0x8000;
        lv = Int_ClampSignedToRange(p[39] + (char)x[107], 100, 0);
        lv = Voice_LevelPair_AttackCurve[(unsigned char)lv];
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
            if (lv == 0xff) lv--;
        }
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451e4 = w;
    *(unsigned int *)(v + 60) = w;
    {
        int l1, l2;
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
        r = Voice_EnvelopeRate_Table[p[42]];
        r = r < 4 ? 4 : r;
        y = Voice_EnvelopeRate_Table[p[44]];
        *(unsigned int *)(v + 62) = (l1 << 8) | (unsigned char)r;
        *(unsigned int *)(v + 64) = (l2 << 8) | (unsigned char)y;
    }
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
        t = Voice_EnvelopeRate_Table[s[12]];
        *(unsigned int *)(v + 64) = (b << 8) | (t & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}

/* cc900-module: Voice_ApplyPortamento */
void Voice_Step_ExprRamp(unsigned char *v)
{
    unsigned int s;
    s = *(unsigned int *)(v + 49);
    if ((s & 0x7f) == 0) {
        s |= v[53];
        s ^= 0x800;
        if (s & 0x800) {
            if (ram_4138e[v[4] * 0x11f] == 1)
                ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
            else if (ram_4138e[v[4] * 0x11f] == 2)
                ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
            else
                ToneGen_WriteExprReg(*v, (*(unsigned int *)(v + 43) & 0xff80) | (*(unsigned char **)(v + 39))[36]);
        } else
            ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
        switch (s & 0x7000) {
        case 0x4000:
            __IZ = *(int *)(v + 54);
            __IZ += *(int *)(v + 51);
            if ((int)__IZ <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                if ((int)__IZ < *(int *)(v + 58)) {
                    __IZ = *(int *)(v + 58);
                    s &= ~0x4000;
                    s |= 0x2000;
                }
                *(int *)(v + 51) = __IZ;
                Voice_ApplyPortamento(v);
                ToneGen_WriteVoiceParams_Ext(*v, ram_451cc, v);
            }
            break;
        case 0x2000:
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x840;
            __ASM(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff00;
            __ASM(" jr $+2");
            __ASM(" nop");
            __ASM(" nop");
            __ASM(" nop");
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x800;
            __ASM(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff80;
            __ASM(" jr $+2");
            __ASM(" nop");
            __ASM(" nop");
            __ASM(" nop");
            ToneGen_WriteVoiceParams_Ext2(*v, v);
            break;
        case 0x1000:
            __IZ = *(int *)(v + 56);
            __IZ += *(int *)(v + 51);
            if ((int)__IZ <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                *(int *)(v + 51) = __IZ;
                Voice_ApplyPortamento(v);
                ToneGen_WriteVoiceParams_Ext(*v, ram_451cc, v);
            }
            break;
        default:
            s = 0;
            break;
        }
    } else if ((s & 0x7f) == 1) {
        ram_18 &= ~0x80;
        ram_100000 = *v + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = *v + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        s--;
    } else s--;
    *(unsigned int *)(v + 49) = s;
}

/* cc900-data: AudioMod_Apply_Porta_Curve 1 = AudioMod_PortaCurve_CaseOffsets */
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m)
{
    long r;
    if (m[1] & 0x80) r = (long)val - 8192;
    else r = (long)val >> 1;
    r = r * m[2] >> 6;
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
        r = (r * 3) << 2;
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
void Voice_ModWheel_Apply(unsigned char part, unsigned char val)
{
    unsigned char *pr;
    unsigned int i;
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_4136e + (int)part * 287) + (i * 3L + 0x17));
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, pr + (i * 3L + 0x15));
        break;
    }
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
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_4136e + (int)part * 287) + (i * 3 + 0x1d));
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
                ram_4520c = EGEnv_Compute_A(i);
                if (r != 1) {
                    t = ((unsigned long)ram_4520c & 0x1fff) * r;
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
                ram_45204 = EGEnv_Compute_B(i);
                if (r != 1) {
                    t = ((unsigned long)ram_45204 & 0x1fff) * r;
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
                Voice_Freq_WriteLeft(i);
                if (r != 1) {
                    if (i < 0x40) {
                        t = ((unsigned long)ram_45204 & 0x1fff) * r;
                        ram_45204 &= 0xe000;
                        ram_45204 |= (unsigned int)(t >> 8);
                    } else {
                        t = ((unsigned long)ram_4520e & 0x1fff) * r;
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
        if (--ram_4135f == 0) {
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

/* cc900-module: Voice_LoadFilterTable_Ch Voice_LoadPitchTable_Ch Voice_LoadToneTable_Ch */
void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r)
{
    unsigned char i;
    unsigned char t;
    r[99] &= 0xe7;
    t = Voice_ToneRampFilter_Curve[r[100] >> 1];
    i = 0;
    while (t > Voice_ToneRampPitch_Curve[i]) i++;
    r[100] = i;
    Voice_LoadPitchTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    t = r[101] / 5;
    i = t;
    r[101] = t * 6;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
}

/* cc900-module: Voice_LoadFilterTable_Ch Voice_LoadPitchTable_Ch Voice_LoadToneTable_Ch */
void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r)
{
    unsigned char i;
    unsigned char t;
    r[99] &= 0xe7;
    t = Voice_ToneRampPitch_Curve[r[100]];
    i = 25;
    while (t < Voice_ToneRampFilter_Curve[i]) i--;
    r[100] = i;
    Voice_LoadPitchTable_Ch(ch, Voice_ToneRampPitch_Curve[t]);
    t = r[101] / 6;
    i = t;
    r[101] = t * 5;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
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
        for (q = Voice_Query_AllChannels() + 5; *q < 0x40; q++) {
            v = ram_4308e[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_451cc);
            }
            if ((unsigned long)*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000) {
                if ((unsigned long)*(unsigned int *)(v + 47) & 0x8080) Voice_Step_DelayTimers(v);
                else if ((unsigned long)*(unsigned int *)(v + 49) & 0x8000) Voice_Step_ExprRamp(v);
            } else if ((unsigned long)*(unsigned int *)(v + 47) & 0x8080) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if ((unsigned long)*(unsigned int *)(v + 49) & 0x8000) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
        }
    } else {
        for (q = Voice_Query_AllChannels() + 5; *q < 0x40; q++) {
            v = ram_4308e[*q];
            if ((unsigned long)*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000) {
                if ((unsigned long)*(unsigned int *)(v + 47) & 0x8080) Voice_Step_DelayTimers(v);
                else if ((unsigned long)*(unsigned int *)(v + 49) & 0x8000) Voice_Step_ExprRamp(v);
            } else if ((unsigned long)*(unsigned int *)(v + 47) & 0x8080) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if ((unsigned long)*(unsigned int *)(v + 49) & 0x8000) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
        }
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
