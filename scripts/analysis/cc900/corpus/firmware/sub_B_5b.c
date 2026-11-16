/* lane_sub helper B, round 5, form b: other spellings of sub_B_5a.c's functions (KN5000 sub-CPU payload v1.42).
   The record kept in XIZ is read as *(unsigned int *)(__XIZ + byte offset); the spilled record pointer is a
   one-member struct. */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4137b[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned char ram_413c9[];
extern unsigned char ram_4308e[][0x47];

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

/* ---- modulation scalers (m[1] bit 7 = bipolar, m[2] = depth): round 4's V4.23 kept the depth in DE and the result
   in HL, the ROM the other way round; the depth a register int declared first here ---- */

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    register int d;
    int r;
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
    register int d;
    int r;
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
    register unsigned int d;
    unsigned int r;
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
    register unsigned int d;
    unsigned int r;
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

/* ---- voice init: the slot record as rec[slot][0x2d] (extz + muls, not the byte mul of round 4) ---- */

void Voice_InitVoiceState(unsigned char slot)
{
    register int t;
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
    t += t;
    ram_451d0 = t;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}

/* ---- depth-scaled loaders: the long operand on the right, so that V4.23 passes it in XWA as the ROM does ---- */

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = depth * v >> 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = (unsigned int)v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = Voice_PitchDepth_Scale[depth] * v >> 8;
    ram_4520c = (unsigned int)v;
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
    v = depth * v >> 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        ram_4520a = (unsigned int)v;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = Voice_FilterDepth_Scale[depth] * v >> 8;
    ram_4520e = (unsigned int)v;
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
    v = depth * v >> 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        ram_45206 = (unsigned int)v;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

/* ---- new: portamento curve.  Bend (BC) scaled by the depth m[2], then by 12 for controls 16-19 / 21-25 or by the
   part's bend range otherwise (a 10-entry jump table on p - 16), shifted, and divided by 16384 / 16383 (long
   divide: the ROM calls Int_SignedDiv_AltEntry for both) into the part record's word at 0x41385 ---- */

void AudioMod_Apply_Porta_Curve(unsigned char p, int bend, unsigned char *m)
{
    long x;
    if (m[1] & 0x80) x = (long)bend - 8192;
    else x = (long)bend >> 1;
    x *= m[2];
    x >>= 6;
    switch ((int)p) {
    case 16:
    case 17:
    case 18:
    case 19:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
        x *= 12;
        break;
    default:
        x *= ram_4137b[p * 0x11f];
        break;
    }
    x <<= 9;
    if (x > 0) x /= 16384;
    else x /= 16383;
    *(int *)&ram_41385[p * 0x11f] = x;
}

/* ---- tone-generator writers ---- */

void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 14);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x80;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 4) & 0x7fff;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_EnvLevel(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 384;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 12);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 16);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg13(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1216;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 20);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg18(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1536;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 64);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg16(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1408;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 60);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 56);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg15(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1344;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 58);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(__XIZ + 46);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 448;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 56);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1536;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 66);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1344;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 58);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1408;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *(unsigned int *)(__XIZ + 62);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 256;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 320;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2176;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x940;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[25];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0xa00;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[27];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x900;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[24];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x9c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[26];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
