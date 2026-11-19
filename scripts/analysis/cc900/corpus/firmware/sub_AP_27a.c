/* lane_sub helper AP, round 27, form a (KN5000 sub-CPU payload v1.42, core/05 and core/06).
   - Voice2_UpdatePitch: from sub_AP_26a.c (the four address-taken locals declared ty, part, w, e: frame and `lda`
     now match).  Its one difference left (run 2026-11-19-30-sub-r26a) is the order at `e[6] = v[12]`: the ROM
     loads v (XWA), then e (XBC), then the byte; ours loaded e first.  With e volatile (25a) the order was the
     ROM's, so form a makes e both volatile and address-taken.
   - Voice_Calc_LevelPair_Mono (sub_AG_22c +65): the ROM keeps lv in QIZ and d in IZ (t on the stack); 22c's
     `register int d` declared after lv gave lv IZ and d QIZ.  Form a: `register int d;` declared before lv.
   - Voice_Calc_LevelPair_EGA (sub_B_9a +63): the only difference is the curve value assigned to lv: the ROM loads
     it into IZL and extends IZ (`ld izl,a; extz iz`), 9a's `(int)` cast gave `extz wa; ld iz,wa`.  Without the
     cast (as Voice_Pitch_Compute's matched `p = v[5];`).  The same spelling in all three forms.
   - Voice_Calc_LevelPair_FixedAtk (sub_Q_17b +225): the only difference is the then-branch word at v+64, where the
     ROM shifts b in its own register (DE) after the table byte is in WA (`sla 8,de; or de,wa`); 17b copied b to
     BC.  Form a: `b = (b << 8) | (Table[s[12]] & 0xff); *(unsigned int *)(v + 64) = b;`.
   cc900-options: -Xr
*/

struct b4 { unsigned char b0, b1, b2, b3; };

extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e0;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_EnvLevel_IndexMap[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Voice_Clamp_Byte_HL(int a);
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void TG_WriteExtParam_Mute_TypeDisp(unsigned int ch);
void TG_WriteExtParams_TypeDispatch(unsigned int ch, unsigned int *blk);
void ToneGen_WrExtParam_TypeDisp_Sgl(unsigned int ch, unsigned int *blk);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void Voice_Freq_WriteRight(unsigned char n);
void Voice_Freq_WriteLeft(unsigned char n);
void Voice2_UpdatePitch(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
/* cc900-module: Voice2_UpdatePitch Voice_Freq_WriteLeft Voice_Freq_WriteRight Voice_OpSlot_WriteParams */
void Voice2_UpdatePitch(unsigned char *v)
{
    unsigned char ty;
    unsigned char part;
    unsigned int w;
    unsigned char * volatile e;
    unsigned char *q;
    unsigned char *r;
    unsigned char t;
    unsigned int ch;
    (void *)&ty;
    (void *)&part;
    (void *)&w;
    (void *)&e;
    ram_451e0 = 0x4400;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    if (*(unsigned int *)(r + 30) == 0) return;
    t = (unsigned char)*(unsigned int *)(r + 30) & 3;
    ty = t;
    if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x4b])->b2 & 0x80) {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x28));
        ch = w & 0xff;
        TG_WriteExtParam_Mute_TypeDisp(ch);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 8));
        ch = w & 0xff;
    }
    e = &ram_44260[(unsigned long)ch * 27];
    e[6] = v[12];
    if (ch >= 0x80) return;
    ram_451e0 |= (*(unsigned int *)(r + 30) & 0x3300) | ch;
    if (!(w & 0x8000) || (*(unsigned int *)q & 0xc)) {
        Voice_OpSlot_WriteParams(part, q, ty, 2, (unsigned char)ch);
        Voice_Freq_WriteRight((unsigned char)ch);
        TG_WriteExtParams_TypeDispatch(ch, ram_451cc);
    }
    if ((e[7] != 0 && (*(unsigned int *)(q + 2) & 0x2000)) || (e[0] & 0x20)) {
        e[8] = 0;
        e[0] &= 0xf3;
        e[0] |= 0x10;
        ram_45204 = 0;
        ram_4520e = 0;
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
        return;
    }
    if ((e[5] != 0 || !(w & 0x8000)) && !(e[0] & 0x38)) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    } else if (*(unsigned int *)q & 0xc) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    }
}

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Voice_Calc_LevelPair_Mono */
void Voice_Calc_LevelPair_Mono(unsigned char *v)
{
    unsigned char *p;
    register int d;
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

/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity Voice_Calc_LevelPair_EGA Voice_Clamp_Byte_HL */
void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[108], 100, 0);
    lv = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
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
        b = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        *(unsigned int *)(v + 64) = b;
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
