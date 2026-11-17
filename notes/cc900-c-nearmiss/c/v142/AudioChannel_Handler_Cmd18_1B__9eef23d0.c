/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_V_18a.c (2026-11-17-7-sub-r18)
   sha256 9eef23d0a39d7cf39458941b073b5213578f8b8a83c8f8dff63b8de5e10de4e9 (name+funcs); compiled at -Xr */
/* lane_sub helper V, round 18, form a (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s).
   Round 17's open functions of helper Q, respelled from the instruction-level difference of their best form, and the
   six AudioChannel_Handler_Cmd04_07 .. Cmd18_1B.
   - the four modulation scalers: statements, not one expression: the depth byte in an int local first (in both
     branches), then r = v - 64; r = r + r; r = r * d (the ROM keeps the depth in HL and doubles by add);
   - the note / pan curves: both ranges as one expression each (the divisor is computed first), the result in h; the
     note byte through `h = p[12]; h &= 0x7f`;
   - Voice_ComputePitch: the note number reassigned from the mirror table (the ROM reloads its register), locals
     declared q, t, n;
   - the three table loaders: idiom (f), the word through an unsigned int temporary before the staging cell;
   - Voice_Calc_LevelPair_FixedAtk: the release rate through t, as the attack word above it;
   - AudioChannel_AllVoices_Update_Variant3: `continue` for layer type 0x20 (the ROM keeps its compare), the patch
     pointer loaded into an unused local; the loop still a `for`;
   - the six handlers (gen_handlers.py form a): one function-level counter i, block-scoped list / base / q and
     olist / j (the ROM's two blocks share stack bytes);
   - new: AudioMod_Apply_Slot_Field2A / Field29, the handlers' leaf callees (byte locals; the routing bits OR-ed in
     two statements through a byte local, the scaled controller as t = val; d = m[2]; t = t * d). */

extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned char ram_41368[];
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
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char *ToneDB_RootPtr;

extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int PitchBend_Scale(int a, int b, int c);
extern int Voice_Colour_LookupIndex(int a, int b);
extern int Voice_Colour_ClampUpper(int a, int b, int c, int d, int e);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);

extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void ExtVoice_Build_SlotRegisters(unsigned char *v);
/* cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
extern void Voice_SubVoice_ComputeAndTrig(unsigned char *v);
extern void Voice2_UpdatePitch(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteVoice_Reg11(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg13(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg18(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg16(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg07(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg15(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_EnvLevel(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrVoice_Reg07_Or_Reg18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
extern void ToneGen_WrVoice_Reg07_Or_Reg18(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrVoice_Reg15_Or_Reg16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
extern void ToneGen_WrVoice_Reg15_Or_Reg16(int ch, unsigned int *p);

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int d, r;
    if (m[1] & 0x80) {
        d = m[2];
        r = v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = v;
        r = r * d;
    }
    r >>= 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int d, r;
    if (m[1] & 0x80) {
        d = m[2];
        r = v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = v;
        r = r * d;
    }
    r >>= 6;
    ram_41383[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int d, r;
    if (m[1] & 0x80) {
        d = m[2];
        r = v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = v;
        r = r * d;
    }
    r >>= 1;
    r = r / 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int d, r;
    if (m[1] & 0x80) {
        d = m[2];
        r = v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = v;
        r = r * d;
    }
    r = r / 127;
    ram_41388[part * 0x11f] = r;
}

/* ---- curves: 0 inside [q1, q2], -512 outside [q0, q3], a -64 slope between ---- */

int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h;
    h = p[12];
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else h = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else h = (h - (int)q[36]) * -64 / (q[37] - (int)q[36]);
    } else h = 0;
    return h;
}

int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else h = ((int)q[30] - h) * -64 / (q[30] - (int)q[31]);
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else h = (h - (int)q[32]) * -64 / (q[33] - (int)q[32]);
    } else h = 0;
    return h;
}

/* ---- the poly pitch ---- */

/* cc900-module: Voice_Colour_LookupIndex Voice_Colour_ClampUpper Voice_InterpolatePanCurve Voice_InterpolateNoteCurve */
void Voice_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    int p;
    int q, t;
    unsigned int n;
    s = *(unsigned char **)(v + 23);
    n = (unsigned int)v[12];
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
            n = Voice_DepthMirror_Table[n];
            q = Voice_Colour_LookupIndex(n, s[25]) - 0xd0;
            q *= ~(int)(char)s[24] + 1;
        } else {
            q = Voice_Colour_LookupIndex(n, s[25]) - 0xd0;
            q *= (char)s[24];
        }
        q >>= 5;
        p = q + 0xd8;
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

/* ---- level pair, fixed attack ---- */

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

/* ---- output-list loaders: the staging word through a temporary (idiom (f)) ---- */

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    unsigned int r;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        r = v;
        ram_45208 = r;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = v * (unsigned long)Voice_PitchDepth_Scale[depth];
    v >>= 8;
    r = v;
    ram_4520c = r;
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
    unsigned int r;
    v = DSP_AlgoType_Dispatch2(ch, 0);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        r = v;
        ram_4520a = r;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = v * (unsigned long)Voice_FilterDepth_Scale[depth];
    v >>= 8;
    r = v;
    ram_4520e = r;
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
    unsigned int r;
    v = DSP_ChanFreq_WritePacket2(ch);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        r = v;
        ram_45206 = r;
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
            continue;
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

/* ---- audio-channel commands 4 .. 0x1b: one operator slot's parameter of sub-voice K (0 / 1 / 2), applied at once
   to the part's sounding voices when the slot's byte is 0, otherwise through the part's output list ---- */

/* ---- the slot byte writers: the part record byte 40 of operator (k, slot) takes the routing bits of
   m[0]; byte 42 (Field2A) / 41 (Field29) takes the scaled controller ---- */

void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val -= 64;
            val = val + val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] & 0x55) | (m[0] & 0x55);
        (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] = x | (m[0] & 0xaa);
    } else (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] = 0;
    t = val;
    d = m[2];
    t = t * d;
    if ((t >>= 6) == 0 && val != 0) t = 1;
    (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[42] = t;
}

void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val -= 64;
            val = val + val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] & 0x55) | (m[0] & 0x55);
        (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] = x | (m[0] & 0xaa);
    } else (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[40] = 0;
    t = val;
    d = m[2];
    t = t * d;
    if ((t >>= 6) == 0 && val != 0) t = 1;
    (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])[41] = t;
}

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_Reg11 ToneGen_WriteVoice_Reg18 */
void AudioChannel_Handler_Cmd04_07(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 39])[3] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 0), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
            } else {
                ram_4520c = EGEnv_Compute_A((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_EnvLevel ToneGen_WriteVoice_Reg07 */
void AudioChannel_Handler_Cmd08_0B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 55])[3] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
            } else {
                ram_45204 = EGEnv_Compute_B((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_Reg13 ToneGen_WriteVoice_Reg07_Or_Reg18 ToneGen_WrVoice_Reg07_Or_Reg18 */
void AudioChannel_Handler_Cmd0C_0F(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 71])[3] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
            } else {
                Voice_Freq_WriteLeft((unsigned char)i);
            }
            ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_Reg11 ToneGen_WriteVoice_Reg18 ToneGen_WriteVoice_Reg16 */
void AudioChannel_Handler_Cmd10_13(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 39])[2] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 0), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
                ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
            } else {
                ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_EnvLevel ToneGen_WriteVoice_Reg07 ToneGen_WriteVoice_Reg15 */
void AudioChannel_Handler_Cmd14_17(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 55])[2] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
            } else {
                ram_45206 = EGEnv_Compute_B_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg15((unsigned char)i, ram_451cc);
            }
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_Reg13 ToneGen_WriteVoice_Reg07_Or_Reg18 ToneGen_WrVoice_Reg07_Or_Reg18 ToneGen_WriteVoice_Reg15_Or_Reg16 ToneGen_WrVoice_Reg15_Or_Reg16 */
void AudioChannel_Handler_Cmd18_1B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if ((&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 71])[2] == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j] & 0xff;
            Voice_OpSlot_WriteParams(part, &ram_41368[part * 287], slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
                ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
            } else {
                Voice_Freq_WriteRight((unsigned char)i);
                ToneGen_WrVoice_Reg15_Or_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}
