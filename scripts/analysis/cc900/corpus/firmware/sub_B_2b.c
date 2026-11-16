/* lane_sub helper B, round 2, form b: other spellings of sub_B_2a.c's functions (sub-CPU payload v1.42).
   The part records (287 bytes at 0x41368) and the voice records (71 bytes at 0x4308e) are two-dimensional char arrays
   here, a field being &rec[n][offset]; loops, casts and evaluation order vary as noted per function. */

extern unsigned char ram_41368[][0x11f];
extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern unsigned char ram_4135e;
extern unsigned char ram_4135f;
extern unsigned int ram_41360;
extern unsigned int ram_41362;
extern int ram_41364;
extern unsigned char ram_4134c;

extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41374[];
extern unsigned char ram_41377[];
extern unsigned char ram_41378[];
extern unsigned char ram_4137a[];
extern unsigned char ram_4137b[];
extern unsigned char ram_4137c[];
extern unsigned char ram_4137e[];
extern unsigned char ram_4137f[];
extern unsigned char ram_41380[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_4138d[];
extern unsigned char ram_4138e[];

extern unsigned char ram_4308e[][0x47];
extern unsigned char ram_43092[];
extern unsigned char ram_430ad[];
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
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern int ram_45204;
extern int ram_45206;
extern int ram_45208;
extern int ram_4520a;
extern int ram_4520c;
extern int ram_4520e;
extern unsigned char ram_45210[];
extern unsigned char *ram_45310;

struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_45314;

extern unsigned int Voice_CC_VolumeCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Voice_OutputLevel_Table[];
extern unsigned char Voice_VibratoDepth_Table[];
extern unsigned int Voice_RhythmMode_ScalePitch_Table[];
extern char Voice_KeyShiftRamp_Steps[];

extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
/* cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single */
extern void ToneGen_WriteExtParam_1C0_Sgl(int, unsigned int *);
extern void ToneGen_WriteReg0640(int, unsigned int *);
extern void ToneGen_WriteExtParam_600(int, unsigned int *);
/* cc900-name: ToneGen_Write_ExtParam_05C0_Stb=ToneGen_Write_ExtParam_05C0_Strobe */
extern void ToneGen_Write_ExtParam_05C0_Stb(int, unsigned int *);
extern void ToneGen_WriteExtParams_56_Alt(int, unsigned int *);
extern unsigned char *Voice_Query_PartVoices(int);
extern void ToneGen_WriteLevelPair(int, unsigned int *);
extern void Level_Build_Reg0C0(unsigned char *);
extern void Voice_Build_GateCommand(unsigned char *);
extern void Voice_ComputePitchBend2(unsigned char *);
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern void Voice_Build_GateCmd_NoPartial(unsigned char *);
extern void ToneGen_ReadPitch_AndScale(int);
extern void ToneGen_WriteSingleReg(int, int);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int, unsigned int);


/* ---- part-record setters (Voice_CC_*): rec[part][offset] ---- */

void Voice_CC_SetReverbSend(unsigned char part, unsigned char v) { ram_41368[part][0x0f] = v; }
void Voice_CC_SetDspEffectSend(unsigned char part, unsigned char v) { ram_41368[part][0x12] = v; }
void Voice_CC_SetBendRange(unsigned char part, unsigned char v) { ram_41368[part][0x13] = v; }
void Voice_CC_SetVelSwitchConfig(unsigned char part, unsigned char v) { ram_41368[part][0x17] = v; }
void Voice_CC_SetSustainLength(unsigned char part, unsigned char v) { ram_41368[part][0x18] = v; }
void Voice_CC_SetGateRoutingMode(unsigned char part, unsigned char v) { ram_41368[part][0x25] = v; }
void Voice_CC_SetTgPanMode(unsigned char part, unsigned char v) { ram_41368[part][0x26] = v; }

void Voice_CC_SetKeyShift(unsigned char part, unsigned char v) { ram_41368[part][0x16] = v - 0x40; }

void Voice_CC_SetTuning(unsigned char part, unsigned char v)
{
    *(int *)&ram_41368[part][0x14] = (v - 0x80) << 1;
}

void Voice_CC_SetSustain(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41368[part][0x0a] |= 1;
    else *(unsigned int *)&ram_41368[part][0x0a] &= ~1;
}

void Voice_CC_SetModWheelRange(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41368[part][0x0a] |= 2;
    else *(unsigned int *)&ram_41368[part][0x0a] &= ~2;
}

void Voice_CC_SetSostenutoFlag(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41368[part][0x0a] |= 0x4000;
    else *(unsigned int *)&ram_41368[part][0x0a] &= ~0x4000;
}

void Voice_CC_SetGlidePedal(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41368[part][0x0a] |= 4;
    else *(unsigned int *)&ram_41368[part][0x0a] &= ~4;
}

void Voice_CC_SetKeyScaling(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41368[part][0x02] |= 0x100;
    else *(unsigned int *)&ram_41368[part][0x02] &= ~0x100;
}

void Voice_CC_SetVolume(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41368[part][0x0c] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41368[part][0x0c] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41368[part][0x0c] = v - 0x7f;
    } else *(unsigned int *)&ram_41368[part][0x0c] = 0xfe00;
}

void Voice_CC_SetExpression(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41368[part][0x10] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41368[part][0x10] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41368[part][0x10] = v - 0x7f;
    } else *(unsigned int *)&ram_41368[part][0x10] = 0xfe00;
}

void VoiceCC_Stub_Ret1(void) { }
void VoiceCC_Stub_Ret2(void) { return; }

int Audio_Clamp_To_Range(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

/* ---- modulation scalers: the result stored without a separate statement ---- */

struct mod { unsigned char a; unsigned char flags; unsigned char depth; };

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, struct mod *m)
{
    int r;
    if (m->flags & 0x80) r = m->depth * ((v - 64) * 2);
    else r = m->depth * v;
    ram_41387[part * 0x11f] = (r >> 1) / 127;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, struct mod *m)
{
    int r;
    if (m->flags & 0x80) r = m->depth * ((v - 64) * 2);
    else r = m->depth * v;
    ram_41388[part * 0x11f] = r / 127;
}

/* ---- level pair / envelope staging ---- */

struct envseg { char pad[62]; int a; int b; };

void Voice_Stage_EnvSegments(struct envseg *p)
{
    ram_451e6 = p->a;
    ram_451e8 = p->b;
}

struct lvl70 { char pad[70]; unsigned char v; };

void Voice_Calc_LevelPair_Silence(struct lvl70 *p)
{
    ram_451fc = 0;
    ram_451fe = 0;
    ram_451f8 = (unsigned int)p->v << 8 | 0x80;
    ram_451fa = (unsigned int)p->v << 8;
    ram_45200 = 0;
    ram_45202 = 0;
}

struct vflag { char pad[13]; unsigned char flags; };
struct vlvl { char pad[13]; unsigned char lvl; };
struct vref { char pad[19]; struct vflag *f; struct vlvl *l; };

void Voice_WriteVolume_OrPan(struct vref *v)
{
    struct vflag *f;
    struct vlvl *l;
    unsigned int t;
    f = v->f;
    l = v->l;
    if (f->flags & 0x20) {
        t = Voice_EnvelopeLevel_Curve[l->lvl] << 8;
        ram_451fa = t;
        t |= 0x80;
        ram_451f8 = t;
    } else {
        ram_451f8 = 0x80;
        ram_451fa = 0;
    }
}

void Voice_InitVoiceState(unsigned char slot)
{
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
    ram_451d0 = Voice_OutputLevel_Table[ram_41364] << 1;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}

/* ---- global key-shift / rhythm state ---- */

void Voice_SetRhythmMode(unsigned char a)
{
    if (a & 8) ram_4135e = 3;
    else ram_4135e = 1;
    ram_4135f = 1;
    ram_41360 = Voice_RhythmMode_ScalePitch_Table[(unsigned char)(a & 0xf0) >> 4];
    if (a & 4) ram_41362 = 0x8000;
    else ram_41362 = 0xa000;
    ram_41364 = (unsigned char)(200 - (a & 3) * 8);
}

void Voice_SetKeyShiftEnable(unsigned char on)
{
    unsigned int t;
    if (on) {
        if (ram_41343 & 0x1000) return;
        ram_41343 |= 0x800;
        ram_4135c = 0;
        return;
    }
    if ((ram_41343 & 0x1000) == 0) return;
    t = ram_41343 & 0xffff2fffL;
    t |= 0x2000;
    if (ram_4135c <= 20) t |= 0x4000;
    else t |= 0x8000;
    ram_41343 = t;
    ram_4135c = 0;
}

void Pitch_Bend_Ramp_Tick(void)
{
    if (ram_41343 & 0x800) {
        ram_4135c++;
        ram_4135a = Voice_KeyShiftRamp_Steps[0] << 1;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
        return;
    }
    if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
        return;
    }
    if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            ram_4135a = Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 0x8000L) {
            ram_4135c++;
            ram_4135a = Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else {
            ram_4135a = 0;
            ram_41343 |= 0x400;
        }
        if (ram_4135a) return;
        ram_41343 &= ~0xe000;
        ram_4135c = 0;
        ram_41343 |= 0x400;
        return;
    }
    ram_41343 &= ~0x400;
}

/* ---- curves: return statements ---- */

struct notep { char pad[12]; unsigned char note; };
struct curvn { char pad[34]; unsigned char lo1; unsigned char lo0; unsigned char hi0; unsigned char hi1; };

int Voice_InterpolateNoteCurve(struct notep *p, struct curvn *q)
{
    int h;
    h = p->note & 0x7f;
    if (h < q->lo1) {
        if (h < q->lo0) return -512;
        return (q->lo1 - h) * -64 / (q->lo1 - q->lo0);
    }
    if (h > q->hi0) {
        if (h > q->hi1) return -512;
        return (h - q->hi0) * -64 / (q->hi1 - q->hi0);
    }
    return 0;
}

struct panp { char pad[8]; int w; };
struct curvp { char pad[30]; unsigned char lo1; unsigned char lo0; unsigned char hi0; unsigned char hi1; };

int Voice_InterpolatePanCurve(struct panp *p, struct curvp *q)
{
    int h;
    h = (p->w & 0x7f00) >> 8;
    if (h < q->lo1) {
        if (h < q->lo0) return -512;
        return (q->lo1 - h) * -64 / (q->lo1 - q->lo0);
    }
    if (h > q->hi0) {
        if (h > q->hi1) return -512;
        return (h - q->hi0) * -64 / (q->hi1 - q->hi0);
    }
    return 0;
}

struct lfo { unsigned char mode; char pad[6]; unsigned char period; unsigned char phase; };

unsigned int Voice_AdvanceLFOPhase(struct lfo *p)
{
    unsigned int r;
    switch ((unsigned char)(p->mode & 0x1c)) {
    case 0x10:
        if (++p->phase >= p->period) {
            p->phase = 0;
            p->mode &= ~0x10;
            p->mode |= 8;
        }
        r = 0;
        break;
    case 8:
        if (++p->phase < p->period) {
            r = (unsigned int)(p->phase << 8) / p->period;
        } else {
            p->phase = 0;
            p->mode &= ~8;
            p->mode |= 4;
            r = 0x100;
        }
        break;
    default:
        r = 0;
        break;
    }
    return r;
}

/* ---- per-voice timers ---- */

void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    t = *(unsigned int *)&p[47];
    if (t & 0x8000) {
        t -= 0x100;
        if (!(t & 0x7f00)) {
            ToneGen_WriteSingleReg(p[0], *(unsigned int *)&p[45]);
            Voice_Clear_HoldBit(p[0]);
            t &= 0x7fff;
        }
    }
    if (t & 0x80) {
        t--;
        if (!(t & 0x7f)) {
            Voice_Reload_Levels(p[0]);
            t &= 0x7f;
        }
    }
    *(unsigned int *)&p[47] = t;
}

/* ---- output-list loaders: for loops ---- */

void Voice_LoadPitchTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45208 = DSP_AlgoType_Dispatch2(ch, 1);
    ram_4520c = DSP_AlgoType_Dispatch1(ch, 1);
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}

void Voice_LoadFilterTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_4520a = DSP_AlgoType_Dispatch2(ch, 0);
    ram_4520e = DSP_AlgoType_Dispatch1(ch, 0);
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451cc);
}

void Voice_LoadToneTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt((unsigned char)list[i], ram_451cc);
}

void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45204 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParam_1C0_Sgl((unsigned char)list[i], ram_451cc);
}

void Voice_DSP_SimpleCopy2(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt((unsigned char)list[i], ram_451cc);
}

void Voice_DSP_OutputConfig(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520e = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteReg0640((unsigned char)list[i], ram_451cc);
    } else {
        ram_4520c = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParam_600((unsigned char)list[i], ram_451cc);
    }
}

void Voice_DSP_OutputConfig2(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520a = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_Write_ExtParam_05C0_Stb((unsigned char)list[i], ram_451cc);
    } else {
        ram_45208 = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParams_56_Alt((unsigned char)list[i], ram_451cc);
    }
}

/* ---- per-voice walks: rec[slot][offset], assignments inside expressions ---- */

void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    unsigned char *q;
    v = *(unsigned char **)&ram_4308e[slot][0x1f];
    if (v[0] & 8) {
        ram_451f8 = (Voice_VibratoDepth_Table[n = v[14]] << 8) | 0x80;
        ram_451fa = Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_4308e[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}

void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    unsigned char *q;
    v &= 0x0f;
    ram_4134c = v;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_41372[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                switch ((*(unsigned char **)&ram_4136e[(p = ram_43092[*q * 0x47]) * 0x11f])[16] & 0xc0) {
                case 0:
                case 0x40:
                case 0xc0:
                    Level_Build_Reg0C0(ram_4308e[*q]);
                    Voice_Build_GateCommand(ram_4308e[*q]);
                    break;
                case 0x80:
                    Voice_ComputePitchBend2(ram_4308e[*q]);
                    Voice_Build_GateCmd_NoPartial(ram_4308e[*q]);
                    break;
                }
                ToneGen_ReadPitch_AndScale(*q);
            }
        }
    }
}

/* ---- DSP coefficient copies (core/09): rows of 16 bytes ---- */

void DSP_CopyCoeffs_TypeA(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    t = (unsigned char (*)[16])(ram_45314->o80 + ram_45310);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_CopyCoeffs_TypeB(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    t = (unsigned char (*)[16])(ram_45314->o100 + ram_45310);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeA(unsigned int a, unsigned int c)
{
    unsigned long off;
    unsigned int s, row, i, n;
    unsigned char (*t)[16];
    a &= 0x7f;
    s = c & 0xc0;
    c &= 0x0f;
    switch (s) {
    case 0: off = ram_45314->o68; break;
    case 0x40: off = ram_45314->o76; break;
    case 0x80: off = ram_45314->o72; break;
    case 0xc0: off = ram_45314->o68; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    t = (unsigned char (*)[16])(ram_45314->o80 + ram_45310);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeB(unsigned int a, unsigned int c)
{
    unsigned long off;
    unsigned int s, row, i, n;
    unsigned char (*t)[16];
    a &= 0x7f;
    s = c & 0xc0;
    c &= 0x0f;
    switch (s) {
    case 0: off = ram_45314->o88; break;
    case 0x40: off = ram_45314->o96; break;
    case 0x80: off = ram_45314->o92; break;
    case 0xc0: off = ram_45314->o88; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    t = (unsigned char (*)[16])(ram_45314->o100 + ram_45310);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_MixSendConfig(unsigned int a, unsigned int c, unsigned char *d)
{
    unsigned char *s;
    unsigned int n, i;
    s = ToneDB_Find_ToneRecord(a, c);
    n = 0x11;
    for (i = 0; i < n; i++)
        *d++ = *s++;
}
