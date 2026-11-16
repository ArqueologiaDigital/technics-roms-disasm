/* lane_sub helper B, round 4, form b: other spellings of sub_B_4a.c's functions (the Math_Multiply32 callers of
   core/06_voice_envelopes_and_channels.s (KN5000 sub-CPU payload v1.42) among them).  Char operands are cast to int where the
   ROM extends first (V4.23 narrows `unsigned char OP constant`); records are char arrays read at fixed offsets. */

extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;

extern unsigned char ram_4137e[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned char ram_413c9[];
extern unsigned char ram_430bb[];

extern unsigned int ram_451cc[];
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char ram_45210[];
extern unsigned char *ram_45310;

struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_45314;

extern char Voice_KeyShiftRamp_Steps[];
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];

extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern unsigned long ToneDB_Find_ToneRecord(unsigned int, unsigned int);

/* ---- part-record setter: copy, then subtract (the ROM's ld e,c; sub e,0x40) ---- */

void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    char t;
    t = v;
    t -= 0x40;
    ram_4137e[part * 0x11f] = t;
}

/* ---- modulation scalers: depth into a local (HL) first, then the value (DE) multiplied by it ---- */

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 1;
    r /= 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r /= 127;
    ram_41388[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (unsigned int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (unsigned int)v - 64;
        r += r;
        r *= d;
    } else {
        d = m[2];
        r = v;
        r *= d;
    }
    r >>= 6;
    ram_41383[part * 0x11f] = r;
}

/* ---- key-shift ramp: the step doubled in a local ---- */

void Pitch_Bend_Ramp_Tick(void)
{
    int t;
    if (ram_41343 & 0x800) {
        ram_4135c++;
        t = Voice_KeyShiftRamp_Steps[0];
        ram_4135a = t + t;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
    } else if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
    } else if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            t = Voice_KeyShiftRamp_Steps[ram_4135c];
            ram_4135a = t + t;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 32768) {
            ram_4135c++;
            t = Voice_KeyShiftRamp_Steps[ram_4135c];
            ram_4135a = t + t;
            ram_41343 |= 0x400;
        } else {
            ram_4135a = 0;
            ram_41343 |= 0x400;
        }
        if (ram_4135a != 0) return;
        ram_41343 &= 0x1fff;
        ram_4135c = 0;
        ram_41343 |= 0x400;
    } else {
        ram_41343 &= ~0x400;
    }
}

/* ---- curves: the divisor declared first ---- */

int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = p[12];
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else {
            d = (int)q[34] - (int)q[35];
            h = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            d = (int)q[37] - (int)q[36];
            h = (h - (int)q[36]) * -64 / d;
        }
    } else h = 0;
    return h;
}

int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else {
            d = (int)q[30] - (int)q[31];
            h = ((int)q[30] - h) * -64 / d;
        }
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else {
            d = (int)q[33] - (int)q[32];
            h = (h - (int)q[32]) * -64 / d;
        }
    } else h = 0;
    return h;
}

/* ---- voice init: the output-level table read as bytes with a doubled int index ---- */

void Voice_InitVoiceState(unsigned char slot)
{
    int t;
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    t = ram_41364;
    t += t;
    t = *(int *)&Voice_OutputLevel_Table[t];
    ram_451d0 = t + t;
    *(unsigned int *)&ram_430bb[slot * 0x47] = 0xf000;
}

/* ---- coefficient routing: the loop bound declared before the counter ---- */

void DSP_RouteCoeffs_TypeA(unsigned int a, unsigned int c)
{
    unsigned int n, s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i;
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_45314->o68; break;
    case 0x40: off = ram_45314->o76; break;
    case 0x80: off = ram_45314->o72; break;
    case 0xc0: off = ram_45314->o68; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o80;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeB(unsigned int a, unsigned int c)
{
    unsigned int n, s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i;
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_45314->o88; break;
    case 0x40: off = ram_45314->o96; break;
    case 0x80: off = ram_45314->o92; break;
    case 0xc0: off = ram_45314->o88; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o100;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

/* the record address returned as a long and converted (the ROM copies XHL to XBC) */
void DSP_MixSendConfig(unsigned int a, unsigned int c, unsigned char *d)
{
    unsigned int i, n;
    register unsigned char *s;
    s = (unsigned char *)ToneDB_Find_ToneRecord(a, c);
    n = 17;
    for (i = 0; i < n; i++) *d++ = *s++;
}

/* ---- new: depth-scaled table loaders (long multiply = Math_Multiply32), clamped at a minimum ---- */

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = v * depth >> 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = v * Voice_PitchDepth_Scale[depth] >> 8;
    ram_4520c = v;
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
    v = v * depth >> 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        ram_4520a = v;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = v * Voice_FilterDepth_Scale[depth] >> 8;
    ram_4520e = v;
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
    v = v * depth >> 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        ram_45206 = v;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}
