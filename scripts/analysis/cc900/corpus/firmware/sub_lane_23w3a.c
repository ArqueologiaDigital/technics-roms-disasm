/* lane_sub, round 23: sub_B_3b.c respelled by notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23w.py, form a: inline assembly as `__asm` (V4.23 then keeps values live across it in XIZ, as the ROM does).  The original file follows unchanged otherwise.
   cc900-options: -Xr */

/* lane_sub helper B, round 3, form b: other spellings of sub_B_3a.c's functions, and three ToneGen writers with a real TAB in __asm
   (KN5000 sub-CPU payload v1.42).  V4.23 computes `unsigned char op constant` at the byte (bugs 1 / 9 of
   cc900-v423-bugs.md) where the ROM extends first, so the char operands are cast to int; a struct member after an
   odd-sized char array moves to an even offset, so records are read through char pointers at fixed offsets. */

extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern unsigned char ram_4134c;

extern unsigned char ram_41368[][0x11f];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41374[];
extern unsigned char ram_41378[];
extern unsigned char ram_4137c[];
extern unsigned char ram_4137e[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451cc[];
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern int ram_45204;
extern int ram_45206;
extern int ram_4520a;
extern int ram_4520c;
extern int ram_4520e;
extern int ram_45208;
extern unsigned char ram_45210[];
extern unsigned char *ram_45310;

struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_45314;

extern unsigned int Voice_CC_VolumeCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_VibratoDepth_Table[];
extern char Voice_KeyShiftRamp_Steps[];

extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
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
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int, unsigned int);

/* ---- part-record setters: the value into a local first (the ROM computes it before the target) ---- */

void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    char t;
    t = v - 0x40;
    ram_4137e[part * 0x11f] = t;
}

void Voice_CC_SetTuning(unsigned char part, unsigned char v)
{
    int t;
    t = v;
    t -= 0x80;
    t += t;
    *(int *)&ram_4137c[part * 0x11f] = t;
}

void Voice_CC_SetVolume(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41374[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41374[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41374[part * 0x11f] = (int)v - 0x7f;
    } else *(unsigned int *)&ram_41374[part * 0x11f] = 0xfe00;
}

void Voice_CC_SetExpression(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41378[part * 0x11f] = (int)v - 0x7f;
    } else *(unsigned int *)&ram_41378[part * 0x11f] = 0xfe00;
}

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (int)m[2] * (((int)v - 64) << 1);
    else r = (int)m[2] * (int)v;
    r = (r >> 1) / 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (int)m[2] * (((int)v - 64) << 1);
    else r = (int)m[2] * (int)v;
    r = r / 127;
    ram_41388[part * 0x11f] = r;
}

/* new: the unsigned twins (mul, srl) */
void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (unsigned int)m[2] * (((unsigned int)v - 64) * 2);
    else r = (unsigned int)m[2] * (unsigned int)v;
    ram_41384[part * 0x11f] = r >> 6;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (unsigned int)m[2] * (((unsigned int)v - 64) * 2);
    else r = (unsigned int)m[2] * (unsigned int)v;
    ram_41383[part * 0x11f] = r >> 6;
}

/* ---- level pair ---- */

void Voice_WriteVolume_OrPan(unsigned char *v)
{
    unsigned char *f;
    unsigned char *l;
    unsigned int t;
    f = *(unsigned char **)(v + 19);
    l = *(unsigned char **)(v + 23);
    if (f[13] & 0x20) {
        t = (unsigned int)Voice_EnvelopeLevel_Curve[l[13]] << 8;
        ram_451fa = t;
        t |= 0x80;
        ram_451f8 = t;
    } else {
        ram_451f8 = 0x80;
        ram_451fa = 0;
    }
}

/* ---- key-shift ramp: the step doubled as an int ---- */

void Pitch_Bend_Ramp_Tick(void)
{
    if (ram_41343 & 0x800) {
        ram_4135c++;
        ram_4135a = (int)Voice_KeyShiftRamp_Steps[0] << 1;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
    } else if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
    } else if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            ram_4135a = (int)Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 32768) {
            ram_4135c++;
            ram_4135a = (int)Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
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

/* ---- curves: one result variable, the divisor a local ---- */

int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (int)p[12] & 0x7f;
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

/* p[0] mode bits, p[7] period, p[8] phase */
unsigned int Voice_AdvanceLFOPhase(unsigned char *p)
{
    unsigned int r;
    switch (p[0] & 0x1c) {
    case 0x10:
        if (++p[8] >= p[7]) {
            p[8] = 0;
            p[0] &= ~0x10;
            p[0] |= 8;
        }
        r = 0;
        break;
    case 8:
        if (++p[8] < p[7]) {
            r = ((unsigned int)p[8] << 8) / p[7];
        } else {
            p[8] = 0;
            p[0] &= ~8;
            p[0] |= 4;
            r = 0x100;
        }
        break;
    default:
        r = 0;
        break;
    }
    return r;
}

/* ---- output-list loaders: the argument `& 0xff` (ld w,0), as the matched Voice_LoadPitchTable_All ---- */

void Voice_LoadToneTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45204 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParam_1C0_Sgl(list[i] & 0xff, ram_451cc);
}

void Voice_DSP_SimpleCopy2(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

void Voice_DSP_OutputConfig(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520e = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteReg0640(list[i] & 0xff, ram_451cc);
    } else {
        ram_4520c = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParam_600(list[i] & 0xff, ram_451cc);
    }
}

void Voice_DSP_OutputConfig2(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520a = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_Write_ExtParam_05C0_Stb(list[i] & 0xff, ram_451cc);
    } else {
        ram_45208 = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParams_56_Alt(list[i] & 0xff, ram_451cc);
    }
}

/* ---- per-voice walks: voice records as rec[slot][offset] (extz + muls, not the byte mul) ---- */

void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    unsigned char *q;
    v = *(unsigned char **)&ram_4308e[slot][0x1f];
    if (v[0] & 8) {
        ram_451f8 = (unsigned int)Voice_VibratoDepth_Table[n = v[14]] << 8 | 0x80;
        ram_451fa = (unsigned int)Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_4308e[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}

void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    unsigned char *q;
    ram_4134c = v & 0x0f;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_41372[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                switch ((*(unsigned char **)&ram_4136e[(p = ram_4308e[*q][4]) * 0x11f])[16] & 0xc0) {
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

/* ---- DSP coefficient copies: the offset variable reused for the row table's offset ---- */

void DSP_CopyCoeffs_TypeA(unsigned int row)
{
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i, n;
    off = ram_45314->o80;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_CopyCoeffs_TypeB(unsigned int row)
{
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i, n;
    off = ram_45314->o100;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeA(unsigned int a, unsigned int c)
{
    unsigned int s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i, n;
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
    unsigned int s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i, n;
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

void DSP_MixSendConfig(unsigned int a, unsigned int c, unsigned char *d)
{
    unsigned int i, n;
    unsigned char *s;
    s = ToneDB_Find_ToneRecord(a, c);
    n = 17;
    for (i = 0; i < n; i++) *d++ = *s++;
}

/* ---- new: per-slot coefficient routing.  Part record + 110 holds 37-byte slot records whose first long points
   at the slot's patch bytes ([2] coefficient column, [3] row (low nibble) and table select (bits 6-7)). ---- */

#define SLOTREC(part, s) &ram_41368[part][(int)(s) * 37 + 110]

void DSP_VoiceCoeffRoute(unsigned char part, unsigned char slot)
{
    unsigned char s;
    unsigned int x, y, row, i, j;
    unsigned long off;
    unsigned char (*t)[16];
    s = slot & 15;
    x = (unsigned int)(*(unsigned char **)SLOTREC(part, s))[2] & 127;
    y = (unsigned int)(*(unsigned char **)SLOTREC(part, s))[3] & 15;
    switch ((unsigned int)(*(unsigned char **)SLOTREC(part, s))[3] & 192) {
    case 0: off = ram_45314->o68; break;
    case 0x40: off = ram_45314->o76; break;
    case 0x80: off = ram_45314->o72; break;
    case 0xc0: off = ram_45314->o68; break;
    }
    row = *(unsigned long *)(((y << 7) + x) * 2 + off + ram_45310);
    off = ram_45314->o80;
    t = (unsigned char (*)[16])(ram_45310 + off);
    j = 13;
    for (i = 0; i < j; i++)
        ram_45210[i + 6] = t[row][i];
    ram_45210[j + 6] = t[row][13];
    j++;
    ram_45210[j + 6] = row & 0xff;
    j++;
    ram_45210[j + 6] = row >> 8;
    j++;
}

/* new: per-bus enable / OR bits into the slot record's word at +24; the 4th argument comes on the stack */
extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];

void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, unsigned int bits, unsigned int ixbits)
{
    unsigned char i;
    for (i = 0; i < 4; i++) {
        if (AudioMod_BusRouting_EnableBits[i] & mask) {
            if (AudioMod_BusRouting_OrIXBits[i] & mask) {
                *(unsigned int *)(((unsigned char (*)[37])&ram_41368[part][110])[i] + 24) |= bits | ixbits;
            } else {
                *(unsigned int *)(((unsigned char (*)[37])&ram_41368[part][110])[i] + 24) &= ~ixbits;
                *(unsigned int *)(((unsigned char (*)[37])&ram_41368[part][110])[i] + 24) |= bits;
            }
        } else {
            *(unsigned int *)(((unsigned char (*)[37])&ram_41368[part][110])[i] + 24) &= ~(bits | ixbits);
        }
    }
}

/* ---- three tone-generator register writers with a real TAB inside the __asm strings (the round-2 escape failed);
   they test only that a TAB inside the string assembles: the goto that should give the `jr` is dropped by V4.23
   (round 2), so they miss at that `jr`; form c has the `jr $+2` versions ---- */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

void ToneGen_WriteVoice_Long(unsigned int ch, register unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __asm("	nop");
    ram_18 |= 0x80;
    ram_100002 = p[7];
    goto gap;
gap:
    __asm("	nop");
    __asm("	nop");
    __asm("	nop");
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, register unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __asm("	nop");
    ram_18 |= 0x80;
    ram_100002 = p[8];
    goto gap;
gap:
    __asm("	nop");
    __asm("	nop");
    __asm("	nop");
}

void ToneGen_WriteVoice_Direct(unsigned int a, register unsigned int d)
{
    ram_18 &= ~0x80;
    ram_100000 = a;
    __asm("	nop");
    ram_18 |= 0x80;
    ram_100002 = d;
    goto gap;
gap:
    __asm("	nop");
    __asm("	nop");
    __asm("	nop");
}
