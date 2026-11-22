/* lane_sub helper AX, round 44, form a (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s).
   Voice_Calc_LevelPair_Mono only.  V4.23 gives the level lv IZ and the depth d QIZ; the ROM has the reverse.
   Round 43 (run 2026-11-20-7-sub-r43b) showed that the names (x, a) and a bare `d;` statement change nothing (the
   statement emits no code), and rounds 20-28 that declaration order and `register` change nothing either.
   The built examples with two int register locals do not follow the reference count either
   (Voice_PortamentoTargets_SetAll: the loop counter in QIZ, the body's word in IZ; VoiceParam_CustomTone_Select:
   the outer counter in QIZ, the inner one in IZ; Voice_AdvanceSlotIterator: a 2-reference local in QIZ while a
   4-reference one stays in the frame), so this round tries SCOPE:
   form a: d alone at function scope, every other local in an inner block (same declaration order as before, so
   the frame keeps p, t, l1, l2 at +4, +8, +10, +12). */

extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);

void Voice_Calc_LevelPair_Mono(unsigned char *v);

/* cc900-module: Voice_Calc_LevelPair_Mono Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    int d;
    {
        unsigned char *p;
        int lv;
        int t;
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
}
