/* lane_sub helper A, round 4, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07).  Round-3 misses refined, plus new functions (the Math_Multiply32 callers among them).  Names are the
   tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.  The 71-byte voice records
   and 287-byte part records have odd field offsets, so they are read through char pointers (B / W / SW / P). */

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
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned long ram_45310;
extern int ram_41366;
extern unsigned int Voice_GlobalFlags;
extern unsigned char ram_451cc[];
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
extern unsigned int EGEnv_ValueCurve_Simple[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char ram_41368[];
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
extern unsigned char ram_4308e[];
extern unsigned char ram_43094[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned char ram_4134c;
extern unsigned char __near ram_24e6[];

struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct pslot { unsigned char *src; unsigned char *tone; };
struct z6 { int w0; char pad[2]; int w4; };

int TVF_Clamp_Cutoff(int a);
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a);
/* cc900-name: CalcAmpNibble_i=Voice_Slot_CalcAmpNibble */
unsigned int CalcAmpNibble_i(int part, int n, int e);
/* cc900-name: FindOctaveOffset_i=Voice_Slot_FindOctaveOffset */
unsigned int FindOctaveOffset_i(int part, int n, int e);
struct pkt *Voice_Query_AllChannels(void);
void Voice_NoteState_Clear(int n);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void ToneGen_WriteSegRegs_SameLevel(int n, unsigned char *blk);
void ToneGen_WriteEnvSegments(int n, unsigned char *blk);
void ToneGen_WriteSingleReg(int n, int v);
void Voice_Clear_HoldBit(int n);
void Voice_Stage_EnvSegments(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
void WaveSel_AddRandomEntryOffset(int *p);
void Pitch_Apply_Zone_Trim(unsigned char *v);
/* cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
void Voice_Build_GateCmd_NoPartial(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);
void Voice_ApplyPortamento2(unsigned char *v);
void Voice_Slot_LoadPitchOffset_A(unsigned char *v);
void Voice_Slot_LoadPitchOffset_B(unsigned char *v);
void Pitch_Apply_Partial_Detune(unsigned char *v);
void Pitch_Emit_Reg400(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Registers(unsigned char *v);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_PortaLevel_Compute(unsigned char *v);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrigger(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Slot_ApplyPortamentoDelta(unsigned char *v);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);

/* ---- round-3 misses ---- */

int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d, r;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - (int)b;
    r = s;
    r = (r * d) >> 5;
    return r;
}

int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d, r;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - (int)b;
    r = s;
    r = (r * d) >> 5;
    return r;
}

void Voice_Artic_SetDepthPair_A(unsigned char part, unsigned char v)
{
    ram_41472[part * 287] = ((char)v >> 4) << 2;
    ram_41473[part * 287] = ((char)(unsigned char)(v << 4) >> 4) * 2;
}

void Voice_Artic_SetDepthPair_B(unsigned char part, unsigned char v)
{
    ram_41474[part * 287] = ((char)v >> 4) << 2;
    ram_41475[part * 287] = ((char)(unsigned char)(v << 4) >> 4) << 3;
}

void Voice_ComputePitchBend2(unsigned char *v)
{
    unsigned char *q;
    int d;
    q = P(v, 19);
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = (unsigned short)B(P(v, 35), 15); break;
        }
    } else d = (unsigned short)B(P(v, 35), 15);
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
        default: d = (unsigned short)B(P(v, 35), 15); break;
        }
    } else d = (unsigned short)B(P(v, 35), 15);
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

void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    unsigned char *p;
    p = ram_41368 + part * 287;
    ((struct pslot *)&p[(int)slot * 37 + 0x6e])->tone = Voice_DefaultToneRecord;
}

void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned int *q, *f;
    q = (unsigned int *)((unsigned long)&ram_41368[part * 287] + 258);
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
    q = (unsigned int *)((unsigned long)&ram_41368[part * 287] + 258);
    if ((*(unsigned int *)&ram_43094[(int)n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}

void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + (unsigned int)c);
    y = *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + ((unsigned int)c + 4));
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)y * 12) + (unsigned int)c) = x;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)x * 12) + ((unsigned int)c + 4)) = y;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + (unsigned int)c) = a;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + ((unsigned int)c + 4)) = a;
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n, hi, lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
    } else {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
    }
    return hi | lo;
}

int PitchBend_Scale(char a, unsigned int b, unsigned char e)
{
    int r;
    b &= ~0x80;
    if (a < 0) {
        b = Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    r = (int)a * PitchBend_ScaleCoeff_Table[b];
    return r >> (e & 0xf);
}

void ToneGen_SilenceChannel(volatile unsigned char ch)
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

void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutReg_Sec(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCmd_NoPartial(v);
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
    Voice_Pitch_WriteOutReg_Sec(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCmd_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_Slot_LoadPitchOffset_B(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

/* ---- new in round 4 ---- */

/* cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
void WaveSel_StageB_Reg040_Footage(unsigned char *v)
{
    struct z6 *t;
    unsigned int w;
    t = (struct z6 *)(*(unsigned char **)(P(v, 31) + 5) + ram_45310);
    if (v[3] == 0) t += Voice_KeyIndex_Pack3Nibbles(CalcAmpNibble_i(v[4], v[0], v[3]));
    else if (v[3] < 3) t += Voice_KeyIndex_Pack3Nibbles(FindOctaveOffset_i(v[4], v[0], v[3]));
    else t += ((unsigned int *)(P(v, 35) + 0x102))[v[3]];
    P(v, 15) = (unsigned char *)t;
    W(v, 1) |= 0x4000;
    ram_451ce = t->w0;
    ram_293e = t->w4;
    if (Voice_GlobalFlags & 4) {
        w = (ram_451ce & 0xf000) << 1;
        ram_451ce &= 0xfff;
        ram_451ce |= w;
    }
}

void Voice_Release_Type4(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Reg040_Footage(v);
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

unsigned int Voice_Slot_FindOctaveOffset(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned char k;
    unsigned int w, r, b, c;
    q = (unsigned int *)((unsigned long)&ram_41368[part * 287] + 258);
    k = 0;
    w = (*(unsigned int *)&ram_43094[(int)n * 71] >> 8) - 12;
    while (w >= 0x54) {
        w -= 12;
        k++;
    }
    if (k == 0) r = q[e];
    else if (k == 1) {
        r = q[e] & 0xff;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (b < c) r = (r & 0xf) | (c << 4);
    } else {
        r = q[e] & 0xf;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (r < b) {
            if (b < c) r = c;
            else r = b;
        } else if (r < c) r = c;
    }
    return r;
}

void Voice_Reload_Levels(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    v[5] &= 0x7f;
    if ((W(v, 1) & 0x8000L) || !(W(P(v, 35), 10) & 1)) {
        if (W(v, 1) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, SW(v, 45));
            Voice_Clear_HoldBit(n);
            W(v, 1) &= ~0x100;
        } else {
            Voice_Calc_LevelPair_EGA(v);
            Voice_Calc_LevelPair_EGB(v);
            Voice_Calc_LevelPair_EGC(v);
            ToneGen_WriteLevelBurst(n, ram_451cc);
        }
    } else {
        if (W(v, 1) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, SW(v, 45));
            Voice_Clear_HoldBit(n);
            W(v, 1) &= ~0x100;
        } else {
            Voice_Stage_EnvSegments(v);
            ToneGen_WriteEnvSegments(n, ram_451cc);
        }
    }
}

unsigned long EGEnv_Compute_A_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_4424e[(int)n * 27];
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}

unsigned long EGEnv_Compute_A_Simple_Dup(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_4424e[(int)n * 27];
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}

unsigned long EGEnv_Compute_B_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = ram_44257 + (int)n * 27;
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}

unsigned long Voice_Freq_ComputeLeft_Raw(unsigned char n)
{
    unsigned char *p;
    p = ram_44257 + (int)n * 27;
    return ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
}

void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = ram_44260 + (int)n * 27;
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        if (p[0] & 0x20) ram_45206 = (unsigned int)r | 0x8000;
        else ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}

void Voice_Freq_ComputeRight_Raw(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = ram_44260 + (int)n * 27;
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}

unsigned int Voice_Clamp_Byte_Unsigned(unsigned int a)
{
    if (a > 255) a = 255;
    return a;
}

void Voice_Vol_ScaleVelocityWord(void)
{
    unsigned long t;
    t = ram_1040;
    ram_41366 = (int)(char)((t * t >> 2) & 0xff) * 13 >> 7;
}

unsigned long EnvDepth_Cap(unsigned long a, unsigned char c, unsigned char e)
{
    unsigned long t, r;
    t = (unsigned long)e * (0x7fUL - c);
    r = (t * a) >> 12;
    if (r > a) r = a;
    return r;
}

void Voice_PortamentoTargets_SetAll(unsigned char part)
{
    unsigned int i;
    unsigned int v;
    for (i = 0; i < 4; i++) {
        v = (*(unsigned char **)(ram_41368 + (int)part * 287 + ((unsigned long)i * 37 + 0x6e)))[2];
        v |= (unsigned int)(*(unsigned char **)(ram_41368 + (int)part * 287 + ((unsigned long)i * 37 + 0x6e)))[3] << 8;
        ((unsigned int *)(ram_41368 + (int)part * 287 + 0x102))[i] = v & 0xfff;
    }
}

int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    int d;
    t = P(v, 23);
    d = (char)t[16];
    if (d != 0) {
        d = d * TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
