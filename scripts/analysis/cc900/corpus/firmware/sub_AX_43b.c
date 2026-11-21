/* lane_sub helper AX, round 43, form b: form a with these changes --
   ExprRamp: z declared after s and u.  Mono: the level renamed a (a name before d), the depth kept as d.
   FixedAtk: the then-branch's word built in r (BC, the ROM's register) and stored from it.
   Form a's notes follow.
   lane_sub helper AX, round 43, form a (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s).
   Three open functions, each from its best earlier attempt, changed only where idiff_full.py shows a difference:
   - Voice_Step_ExprRamp (best sub_AG_21a, +20): no __IZ / __ASM any more.  The ramp value is a plain `int z`
     (signed: the ROM's `cp iz,0xff00; jr gt` and `cp iz,(xwa+58); jr ge`), the inline assembly the lower-case
     `__asm`, so z goes to IZ by itself.  The state word s is `volatile`: the ROM keeps it at (xsp+2) and pushes
     only IZ, so s must not take QIZ.  z declared first.
   - Voice_Calc_LevelPair_Mono (best sub_AG_22c, +65): V4.23 gives lv IZ and d QIZ, the ROM the reverse; both have
     the same number of references (10), and declaration order / `register` did not flip it (rounds 20-28).  Here the
     depth is renamed x (a name after lv), in case a tie is broken by name.
   - Voice_Calc_LevelPair_FixedAtk (best sub_Q_17b, +225): the then-branch's word built as the matched (v + 62) one
     is: the rate byte read into t first, then `(b << 8) | (t & 0xff)` (the ROM copies b into BC before the shift). */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_4138e[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern void Voice_ApplyPortamento(unsigned char *v);
extern void ToneGen_WriteExprReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p, unsigned char *v);
extern void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);

void Voice_Step_ExprRamp(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);

/* cc900-module: Voice_Step_ExprRamp Voice_ApplyPortamento */
void Voice_Step_ExprRamp(unsigned char *v)
{
    volatile unsigned int s;
    unsigned int u;
    int z;
    u = *(unsigned int *)(v + 49);
    s = u;
    if ((u & 0x7f) == 0) {
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
            z = *(int *)(v + 54);
            z += *(int *)(v + 51);
            if (z <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                if (z < *(int *)(v + 58)) {
                    z = *(int *)(v + 58);
                    s &= ~0x4000;
                    s |= 0x2000;
                }
                *(int *)(v + 51) = z;
                Voice_ApplyPortamento(v);
                ToneGen_WriteVoiceParams_Ext(*v, ram_451cc, v);
            }
            break;
        case 0x2000:
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x840;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff00;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x800;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff80;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ToneGen_WriteVoiceParams_Ext2(*v, v);
            break;
        case 0x1000:
            z = *(int *)(v + 56);
            z += *(int *)(v + 51);
            if (z <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                *(int *)(v + 51) = z;
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
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        ram_18 &= ~0x80;
        ram_100000 = *v + 0x800;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        s--;
    } else s--;
    *(unsigned int *)(v + 49) = s;
}

/* cc900-module: Voice_Calc_LevelPair_Mono Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    unsigned char *p;
    int a;
    int t;
    int d;
    int l1, l2;
    int w, r, y;
    int k;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    k = Voice_LevelPair_AttackCurve[p[39]];
    a = k;
    if (p[51] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[48], p[49], p[50], (char)p[51]);
        if (p[46] != 0) {
            d = PitchBend_Scale((char)p[46], v[12], 4);
            a = Int_ClampSignedToRange(a + t + d, 0xff, 0);
        } else a = Int_ClampSignedToRange(a + t, 0xff, 0);
    } else if (p[46] != 0) {
        d = PitchBend_Scale((char)p[46], v[12], 4);
        a = Int_ClampSignedToRange(a + d, 0xff, 0);
    }
    if (**(unsigned char **)(v + 31) & 1) {
        k = a;
        if (k == 0xff) a--;
    }
    w = (a << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
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

/* cc900-module: Voice_Calc_LevelPair_FixedAtk Int_ClampSignedToRange PitchBend_Scale */
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
        r = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        *(unsigned int *)(v + 64) = r;
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
