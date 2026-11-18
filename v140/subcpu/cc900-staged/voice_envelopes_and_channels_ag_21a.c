/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_412f7;
extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char ram_43042[][0x47];
extern unsigned char ram_44202[];
extern unsigned char ram_4420b[];
extern unsigned char ram_44214[];
extern unsigned int ram_45180[];
extern unsigned int ram_45198;
extern unsigned int ram_4519a;
extern unsigned int ram_4519c;
extern unsigned int ram_451b8;
extern unsigned int ram_451c0;
extern unsigned int ram_451c2;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_LevelPair_Bit11Default;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern unsigned int Voice_AdvanceLFOPhase(unsigned char *p);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
extern void ToneGen_WrExtParam_1C0_Single(int ch, unsigned int *p);
extern void ToneGen_WrExtParam_TypeDisp_Sgl(int ch, unsigned int *p);
extern void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
extern void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);
extern void Pitch_Bend_Ramp_Tick(void);
extern void Pitch_Emit_Reg400(unsigned char *v);
extern void Voice_Step_DelayTimers(unsigned char *p);
extern unsigned char *Voice_Query_AllChannels(void);
extern void ToneGen_WriteVoicePitch(int ch, unsigned int *p);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_Step_ExprRamp(unsigned char *v);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val);
void Voice_UpdateAllLFO(void);
void Voice_TickNoteDecay(void);
void Audio_Tick_ServiceVoices_B(void);
void Audio_Tick_ServiceVoices_B(void);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_UpdateAllLFO(void);

/* cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
/* cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
/* cc900-module: AudioChannel_Dispatch EGEnv_Compute_A EGEnv_Compute_B Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Pitch_Bend_Ramp_Tick Pitch_Emit_Reg400 Voice_AdvanceLFOPhase Voice_Freq_WriteLeft Voice_Step_DelayTimers Voice_Step_ExprRamp Voice_TickNoteDecay Voice_ToneTableApply_Filter Voice_ToneTableApply_Pitch Voice_ToneTableRamp_Down Voice_ToneTableRamp_Up */
void Audio_Tick_ServiceVoices_B(void)
{
    unsigned char f;
    unsigned char *q;
    unsigned char *v;
    unsigned char i;
    unsigned char *rec;
    unsigned char *u;
    Voice_TickNoteDecay();
    Pitch_Bend_Ramp_Tick();
    if (ram_412f7 & 0x400) {
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_43042[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_45180);
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
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_43042[*q];
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
        rec = &ram_4131c[i * 0x11f];
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

void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val)
{
    unsigned char i;
    switch ((*(unsigned char **)(ram_41322 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_41322 + (int)part * 287) + ((int)i * 3 + 0x1d));
        break;
    }
}

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
        k = lv;
        if (k == 0xff) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_45198 = w;
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
    ram_4519a = (l1 << 8) | (r & 0xff);
    ram_4519c = (l2 << 8) | (y & 0xff);
}

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
        k = lv;
        if (k == 0xff) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_45198 = w;
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

void Voice_UpdateAllLFO(void)
{
    unsigned int i;
    unsigned char *p;
    unsigned int r;
    unsigned long t;
    for (i = 0; i < 0x80; i++) {
        p = ram_44202 + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451c0 = EGEnv_Compute_A((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451c0 & 0x1fff;
                    t *= r;
                    ram_451c0 &= 0xe000;
                    ram_451c0 |= (unsigned int)(t >> 8);
                }
                ToneGen_WriteExtParam_600(i, ram_45180);
            }
        }
    }
    for (i = 0; i < 0x40; i++) {
        p = (unsigned char *)((unsigned long)ram_4420b + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451b8 = EGEnv_Compute_B((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451b8 & 0x1fff;
                    t *= r;
                    ram_451b8 &= 0xe000;
                    ram_451b8 |= (unsigned int)(t >> 8);
                }
                ToneGen_WrExtParam_1C0_Single(i, ram_45180);
            }
        }
    }
    for (i = 0; i < 0x80; i++) {
        p = (unsigned char *)((unsigned long)ram_44214 + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                Voice_Freq_WriteLeft((unsigned char)i);
                if (r != 0x100) {
                    if (i < 0x40) {
                        t = (unsigned long)ram_451b8 & 0x1fff;
                        t *= r;
                        ram_451b8 &= 0xe000;
                        ram_451b8 |= (unsigned int)(t >> 8);
                    } else {
                        t = (unsigned long)ram_451c2 & 0x1fff;
                        t *= r;
                        ram_451c2 &= 0xe000;
                        ram_451c2 |= (unsigned int)(t >> 8);
                    }
                }
                ToneGen_WrExtParam_TypeDisp_Sgl(i, ram_45180);
            }
        }
    }
}
