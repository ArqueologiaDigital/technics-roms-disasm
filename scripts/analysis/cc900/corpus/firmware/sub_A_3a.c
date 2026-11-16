/* lane_sub helper A, round 3, form a: functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07).  Round-2 misses refined, plus new functions.  Names are the tree's labels; ram_<hex> is a RAM cell
   (sub-CPU address) the tree has not named.
   Round 2 showed that V4.23 does `unsigned char OP constant <= 255` (and `uchar << 8`) in 8 bits, where the ROM
   extends first and works in 16 bits: those operands are cast to int here ((int)i * 71 gives extz + muls). */

#define B(p, o) (*(unsigned char *)((p) + (o)))
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned int ram_100002;
extern int __near ram_293e;
extern int __near ram_2940;
extern unsigned long __near ram_1040;
extern int ram_451ce;
extern int ram_451d2;
extern unsigned char ram_451cc[];
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern unsigned char Voice_Colour_RowOffset_Table[];
extern unsigned char Voice_Colour_TransferCurves[];
extern unsigned char Voice_DepthMirror_Table[];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
extern unsigned char ram_41368[];
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
extern unsigned char ram_41481[];
extern unsigned char ram_41485[];
extern unsigned char ram_41486[];
extern unsigned char ram_4308e[];
extern unsigned char ram_4308f[];
extern unsigned char ram_43094[];
extern unsigned char ram_4134c;
extern unsigned char ram_4424e[][3][9];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_24e6[][12];

struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };

struct pkt *Voice_Query_AllChannels(void);
void Voice_NoteState_Clear(int n);
void Voice_Calc_LevelPair_Silence(unsigned char *v);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_ComputeVolume_CappedLFO(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
void WaveSel_StageB_Build_Reg040_Footage(unsigned char *v);
void WaveSel_AddRandomEntryOffset(int *p);
void Pitch_Apply_Zone_Trim(unsigned char *v);
void Voice_Pitch_WriteOutputReg_Secondary(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);
void Voice_Build_GateCommand_NoPartial(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);
void Voice_ApplyPortamento2(unsigned char *v);
void Voice_Slot_LoadPitchOffset_A(unsigned char *v);
void Voice_Slot_LoadPitchOffset_B(unsigned char *v);
void Pitch_Emit_Reg400(unsigned char *v);
void Pitch_Apply_Partial_Detune(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Registers(unsigned char *v);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_PortaLevel_Compute(unsigned char *v);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrigger(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Slot_ApplyPortamentoDelta(unsigned char *v);
void Voice_WriteChPanShift(unsigned char *v, int s);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);

/* ---- round-2 misses ---- */

unsigned int ToneGen_Read_Register(unsigned int r)
{
    ram_18 &= 0x7f;
    ram_100000 = r;
    return ram_100000;
}

unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if ((int)a & 0x8000) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}

unsigned char VoiceRec_Decode2BitField(unsigned char n)
{
    unsigned char r;
    switch (*(unsigned int *)&ram_4308f[(int)n * 71] & 0xc0) {
    case 0: r = 0; break;
    case 0x40: r = 1; break;
    case 0x80: r = 2; break;
    case 0xc0: r = 3; break;
    }
    return r;
}

void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = (int)*p + d;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
}

int Pitch_Clamp_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    if (a & 0x8000) {
        if (v > -0x4000) v = 0;
        else v = 0x7fff;
    }
    if (v < ((int)lo << 8) + 0x80) v = ((int)lo << 8) + 0x80;
    else if (v > ((int)hi << 8) + 0x80) v = ((int)hi << 8) + 0x80;
    return v;
}

int Pitch_Fold_Octaves_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    while (v & 0x8000) {
        if (v > -0x4000) v += 0xc00;
        else v -= 0xc00;
    }
    while (v < ((int)lo << 8) + 0x80) v += 0xc00;
    while (v > ((int)hi << 8) + 0x80) v -= 0xc00;
    return v;
}

int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - b;
    return (s * d) >> 5;
}

int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - b;
    return (s * d) >> 5;
}

/* wave-select zone records: voice +15 = record pointer, +1 = flags */

void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 4;
    P(v, 15) = t;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 6;
    P(v, 15) = t;
    W(v, 1) |= 0x4000;
    ram_451ce = SW(t, 0);
    x = SW(t, 4);
    ram_293e = x;
}

void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 10;
    P(v, 15) = t;
    W(v, 1) |= 0x1000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 12;
    P(v, 15) = t;
    W(v, 1) |= 0x5000;
    ram_451ce = SW(t, 0);
    x = SW(t, 10);
    ram_293e = x;
}

void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 13;
    P(v, 15) = t;
    W(v, 1) |= 0x3000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 15;
    P(v, 15) = t;
    W(v, 1) |= 0x7000;
    ram_451ce = SW(t, 0);
    x = SW(t, 13);
    ram_293e = x;
}

void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = (v << 4 >> 4) * 2;
}

void Voice_Artic_SetDepthPair_B(unsigned char part, char v)
{
    ram_41474[part * 287] = (v >> 4) << 2;
    ram_41475[part * 287] = (v << 4 >> 4) << 3;
}

void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = ram_4424e[j][i];
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}

void VoiceRow_FetchPair_WA_SP(unsigned char a)
{
    unsigned char x, y;
    x = ram_2126[(int)a * 5];
    y = ram_2127[(int)a * 5];
    ram_2126[(int)y * 5] = x;
    ram_2127[(int)x * 5] = y;
    ram_2126[(int)a * 5] = a;
    ram_2127[(int)a * 5] = a;
}

void VoiceRow_FetchPair_DE_WA(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ram_2126[(int)a * 5];
    y = ram_2127[(int)a * 5];
    ram_2126[(int)y * 5] = x;
    ram_2127[(int)x * 5] = y;
    y = ram_2127[(int)c * 5];
    ram_2126[(int)y * 5] = a;
    ram_2127[(int)a * 5] = y;
    ram_2126[(int)a * 5] = c;
    ram_2127[(int)c * 5] = a;
}

void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = v % 16;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = v % 16;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = v % 16;
}

void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    P(&(ram_41368 + part * 287)[(int)slot * 37 + 0x6e], 4) = Voice_DefaultToneRecord;
}

void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned int *q, *f;
    q = (unsigned int *)&ram_41368[part * 287] + 129;
    f = (unsigned int *)(ram_41368 + part * 287) + 1;
    if (q[0] != 0) *f |= 1; else *f &= ~1;
    if (q[1] != 0) *f |= 2; else *f &= ~2;
    if (q[2] != 0) *f |= 4; else *f &= ~4;
    if (q[3] != 0) *f |= 8; else *f &= ~8;
}

unsigned int Voice_Slot_CalcAmpNibble(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned int lo;
    unsigned int r;
    q = (unsigned int *)&ram_41368[part * 287] + 129;
    if ((*(unsigned int *)&ram_43094[(int)n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}

void Voice_ComputePitchBend2(unsigned char *v)
{
    unsigned char *q;
    int d;
    q = P(v, 19);
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = (int)B(P(v, 35), 15); break;
        }
    } else d = (int)B(P(v, 35), 15);
    if (d != 0) {
        d += (int)B(q, 15) - 0x40;
        if (d < 0) d = 0;
        else if (d > 0x7f) d = 0x7f;
        d <<= 8;
    }
    if (B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 5:
        case 6: d |= 0x7f; break;
        default: d |= B(P(v, 35), 18); break;
        }
    } else d |= B(P(v, 35), 18);
    ram_451d2 = d;
}

void Level_Build_Reg0C0(unsigned char *v)
{
    int d;
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = (int)B(P(v, 35), 15); break;
        }
    } else d = (int)B(P(v, 35), 15);
    if (d != 0) {
        d += (int)B(P(v, 19), 92) - 0x40;
        d += (char)B(P(v, 35), 102);
        if (d < 0) d = 0;
        else if (d > 0x7f) d = 0x7f;
        d <<= 8;
    }
    if (B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 5:
        case 6: d |= 0x7f; break;
        default: d |= B(P(v, 35), 18); break;
        }
    } else d |= B(P(v, 35), 18);
    ram_451d2 = d;
}

void Voice_ReleaseSingle(unsigned char n)
{
    unsigned char *v;
    v = ram_4308e + (int)n * 71;
    v[5] &= 0x7f;
    if (v[70] != 0) {
        Voice_Calc_LevelPair_Silence(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
}

void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutputReg_Secondary(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCommand_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Init_Type1(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    WaveSel_AddRandomEntryOffset(&ram_451ce);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutputReg_Secondary(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCommand_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_Slot_LoadPitchOffset_B(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Build_Register_Set(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    Voice_Calc_LevelPair_PatchAtk(v);
    Voice_WriteChPanShift(v, 0);
    Voice_ComputePitch(v);
    Voice_ApplyPortamento(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Cut(unsigned char n)
{
    unsigned char *v;
    unsigned char *s;
    unsigned int w;
    v = &ram_4308e[(int)n * 71];
    s = P(v, 35);
    v[5] &= 0x7f;
    w = W(s, 10);
    if (v[3] == 3) W(s, 10) &= ~1;
    if ((W(v, 1) & 0x8000L) || !(W(P(v, 35), 10) & 1)) {
        if (v[3] < 3) Voice_ComputeVolume_CappedLFO(v);
        else Voice_Calc_LevelPair_EGA(v);
        Voice_Calc_LevelPair_EGB(v);
        Voice_Calc_LevelPair_EGC(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
    W(s, 10) = w;
}

/* ---- new in round 3 ---- */

void Pitch_Apply_Partial_Detune(unsigned char *v)
{
    SW(v, 10) = SW(v, 6) + ram_293e + (int)(char)B(P(v, 23), 5) * 2 + (char)B(P(v, 39), 33) + SW(P(v, 35), 20);
    if ((W(P(v, 35), 10) & 4) && (B(P(v, 19), 16) & 0x20)) W(v, 1) |= 0x400;
    else W(v, 1) &= ~0x400;
}

void Voice_Release_Type4(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040_Footage(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    if (v[3] < 3) {
        Voice_Calc_LevelPair_Full(v);
        Voice_ComputePitch(v);
        Voice_Slot_LoadPitchOffset_A(v);
        Voice_ApplyPortamento(v);
    } else {
        Voice_Calc_LevelPair_Mono(v);
        Voice_ComputePitch(v);
        Voice_Slot_ApplyPortamentoDelta(v);
        Voice_ApplyPortamento(v);
    }
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Env_UpdateVelocityCounters(unsigned char a)
{
    unsigned long d;
    d = ram_1040 - *(unsigned long *)&ram_41481[a * 287];
    if (d != 0) {
        if (d < 0x19) {
            switch (++*(ram_41485 + a * 287)) {
            case 0: ram_41486[a * 287] = 0; break;
            case 1: ram_41486[a * 287] = 0x10; break;
            default: ram_41486[a * 287] = 0x20; break;
            }
        } else {
            ram_41485[a * 287] = 0;
            ram_41486[a * 287] = 0;
        }
    }
    *(unsigned long *)&ram_41481[a * 287] = ram_1040;
}

void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ram_24e6[a][(unsigned int)c];
    y = ram_24e6[a][(unsigned int)c + 4];
    ram_24e6[y][(unsigned int)c] = x;
    ram_24e6[x][(unsigned int)c + 4] = y;
    ram_24e6[a][(unsigned int)c] = a;
    ram_24e6[a][(unsigned int)c + 4] = a;
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n, hi, lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = (unsigned int)TVF_DepthRecords_B[n][1] << 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = (char)TVF_DepthRecords_B[n][2];
    } else {
        hi = (unsigned int)TVF_DepthRecords_A[n][1] << 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = (char)TVF_DepthRecords_A[n][2];
    }
    return hi | lo;
}

unsigned int Voice_Colour_LookupIndex(unsigned int a, unsigned char b)
{
    b = (b & 0xe0) >> 5;
    return Voice_Colour_TransferCurves[((int)b << 8) + Voice_Colour_RowOffset_Table[a]];
}

int PitchBend_Scale(char a, unsigned char b, unsigned char e)
{
    int r;
    b &= 0x7f;
    if (a < 0) {
        b = Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    r = PitchBend_ScaleCoeff_Table[b] * (int)a;
    return r >> (e & 0xf);
}

void ToneGen_SilenceChannel(unsigned char ch)
{
    ram_18 &= 0x7f;
    ram_100000 = (unsigned char)(ch + 0xc0);
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= 0x7f;
    ram_100000 = ch;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x7e00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void Voice_AllVoices_PortamentoReset(void)
{
    unsigned char i;
    unsigned char *p;
    for (i = 0; i < 0x1a; i++) Voice_NoteState_Clear(i);
    p = (unsigned char *)Voice_Query_AllChannels() + 5;
    for (; *p < 0x40; p++) {
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}
