/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
/* Copyright (C) 1991-2025 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */
/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */
/* glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default.  */
/* wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISO/IEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters */
/* lane_sub helper Q, round 17, form c (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s):
   other spellings of sub_Q_17a.c's functions (the depth byte uncast, block-scoped temporaries, the curves' result in
   a variable of its own, a K&R declaration of ToneGen_WriteSingleReg, int bus bits).
   THIS FORM HAS Voice_ToneTableRamp_Up INSTEAD OF THE THREE Voice_Load*Table_Ch: Ramp_Up needs their prototypes with
   a plain `char` depth (idiom (c)), which cannot stand beside their definitions with an unsigned char depth.
   Near misses of pool B respelled from their listings, and new functions:
   - the four modulation scalers: one expression, the doubled controller as the LEFT operand of the product (V4.23
     evaluates the right operand first, and the result takes the left operand's register);
   - idiom (a) (a second local receives the value, the kept local is set from it) in Voice_AllVoices_UpdateVelocity
     and Voice_WriteChPitchWithVib;
   - the table loaders' long product as `v *= depth` (v first, as the ROM's XWA);
   - the pan shift with the shift byte in a local of its own, set before the pan word is read;
   - the note / pan curves with the divisor's subtrahend in a local and the high range through a temporary;
   - new: AudioMod_Apply_BusRouting (16-bit record index, no runtime call), Voice_ComputePitch, the clamp after it,
     AudioChannel_AllVoices_Update_Variant3 and AudioChannel_Handler_Cmd01 / Cmd03 / Cmd02. */
extern unsigned int ram_41343;
extern unsigned char ram_4134c;
extern int __near ram_2940;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
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
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern unsigned char Voice_VibratoDepth_Table[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Colour_LookupIndex(int a, int b);
extern int Voice_Colour_ClampUpper(int a, int b, int c, int d, int e);
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_Query_PartVoices_Mask7F(int part);
extern void Level_Build_Reg0C0(unsigned char *v);
extern void Voice_Build_GateCommand(unsigned char *v);
extern void Voice_ComputePitchBend2(unsigned char *v);
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern void Voice_Build_GateCmd_NoPartial(unsigned char *v);
extern void ToneGen_ReadPitch_AndScale(int ch);
extern void ToneGen_WriteLevelPair(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg();
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern void Voice_LoadPitchTable_All(int ch);
extern void Voice_LoadFilterTable_All(int ch);
extern void Voice_LoadToneTable_All(int ch);
void Voice_LoadPitchTable_Ch(int ch, char depth);
void Voice_LoadFilterTable_Ch(int ch, char depth);
void Voice_LoadToneTable_Ch(int ch, char depth);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void AudioMod_Apply_Porta_Curve(int part, unsigned int val, unsigned char *m);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void TVF_Refresh_Sounding_Voices(unsigned char *list);
/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
extern void AudioChannel_AllVoices_UpdPan(unsigned char *list);
/* the word at +24 of output-slot record w (37 bytes each, from +110) of a part's 287-byte record */
/* ---- per-bus enable bits: the 4th argument comes on the stack ---- */
void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, int a, int b)
{
    unsigned char w;
    for (w = 0; w < 4; w++) {
        if (AudioMod_BusRouting_EnableBits[w] & mask) {
            if (AudioMod_BusRouting_OrIXBits[w] & mask) {
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) |= a | b;
            } else {
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) &= ~b;
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) |= a;
            }
        } else {
            (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) &= ~(a | b);
        }
    }
}
/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */
void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (unsigned int)(((int)v - 64) * 2) * m[2];
    else r = (unsigned int)v * m[2];
    r >>= 6;
    ram_41384[part * 0x11f] = r;
}
void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) r = (unsigned int)(((int)v - 64) * 2) * m[2];
    else r = (unsigned int)v * m[2];
    r >>= 6;
    ram_41383[part * 0x11f] = r;
}
void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (((int)v - 64) << 1) * m[2];
    else r = v * m[2];
    r >>= 1;
    r = r / 127;
    ram_41387[part * 0x11f] = r;
}
/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) r = (((int)v - 64) << 1) * m[2];
    else r = v * m[2];
    r /= 127;
    ram_41388[part * 0x11f] = r;
}
/* ---- curves: 0 inside [q1, q2], -512 outside [q0, q3], a -64 slope between ---- */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char n;
    int h, s, d, r;
    n = p[12];
    h = n;
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) r = -512;
        else {
            s = q[35];
            d = q[34] - s;
            r = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) r = -512;
        else {
            s = q[36];
            d = q[37] - s;
            r = (h - (int)q[36]) * -64 / d;
        }
    } else r = 0;
    return r;
}
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, s, d, r;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) r = -512;
        else {
            s = q[31];
            d = q[30] - s;
            r = ((int)q[30] - h) * -64 / d;
        }
    } else if (h > q[32]) {
        if (h > q[33]) r = -512;
        else {
            s = q[32];
            d = q[33] - s;
            r = (h - (int)q[32]) * -64 / d;
        }
    } else r = 0;
    return r;
}
/* ---- the poly pitch: Voice_ComputePitch_Mono plus the colour clamp, the two curves and the part's byte 286 ---- */
/* cc900-module: Voice_Colour_LookupIndex Voice_Colour_ClampUpper Voice_InterpolatePanCurve Voice_InterpolateNoteCurve */
void Voice_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned int n;
    int p, t, q;
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
            q = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], s[25]) - 0xd0;
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
/* the 17 bytes after Voice_ComputePitch's ret: a signed clamp (WA value, BC high, DE low), a twin of
   Int_ClampSignedToRange */
int Voice_ComputePitch_InlineData(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}
/* ---- portamento, second form ---- */
/* cc900-module: Voice_Build_OutputLevel */
int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t;
    int u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = -512;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != 0xfe00) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}
/* ---- level pairs ---- */
/* cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Detune_ScaleSymmetric */
void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    unsigned char *p;
    p = *(unsigned char **)(v + 23);
    s = p;
    t = Voice_EnvelopeLevel_Curve[p[69]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[76] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[76]);
        if (s[71] != 0) {
            lv += PitchBend_Scale((char)s[71], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[71] != 0) {
        lv += PitchBend_Scale((char)s[71], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[70] + (int)(char)s[61], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}
/* cc900-module: Int_ClampSignedToRange PitchBend_Scale */
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v)
{
    unsigned char *f, *s;
    int x, lv, t, a, b, r;
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
    x = t;
    x |= 0x7f;
    ram_451e4 = x;
    *(unsigned int *)(v + 60) = x;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    t = 4;
    if (r >= 4) t = r;
    r = t;
    *(unsigned int *)(v + 62) = (a << 8) | (t & 0xff);
    if (f[13] & 0x20) {
        *(unsigned int *)(v + 64) = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
/* ---- channel pan shift: the patch (v + 39) word 24 bit 8 enables it, bit 9 makes it subtract ---- */
/* cc900-module: Int_ClampSignedToRange */
void Voice_WriteChPanShift(unsigned char *v, unsigned char flag)
{
    int l, r;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            int s;
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            int s;
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451e6 = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}
/* cc900-module: Int_ClampSignedToRange */
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            int s;
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            int s;
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451e6 = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}
/* ---- vibrato depth of every voice of a part that shares the slot's byte 14 ---- */
void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    unsigned char *q;
    v = *(unsigned char **)&ram_4308e[slot][0x1f];
    if (v[0] & 8) {
        unsigned char u;
        u = v[14];
        n = u;
        ram_451f8 = (unsigned int)Voice_VibratoDepth_Table[u] << 8 | 0x80;
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
                unsigned char u;
                u = ram_4308e[*q][4];
                p = u;
                switch ((*(unsigned char **)&ram_4136e[u * 0x11f])[16] & 0xc0) {
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
/* ---- the two delay counters of a voice's word 47: the callee's first parameter a byte ---- */
void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    t = *(unsigned int *)(p + 47);
    if (t & 32768) {
        t -= 0x100;
        if ((t & 0x7f00) == 0) {
            ToneGen_WriteSingleReg(*p, *(unsigned int *)(p + 45));
            Voice_Clear_HoldBit(*p);
            t &= ~0x8000;
        }
    }
    if (t & 0x80) {
        t--;
        if ((t & 0x7f) == 0) {
            Voice_Reload_Levels(*p);
            t &= 0x7f;
        }
    }
    *(unsigned int *)(p + 47) = t;
}
/* ---- tone-table ramp, upwards: Voice_ToneTableRamp_Down's twin (the callees' depth a plain char, idiom (c)) ---- */
/* cc900-module: Voice_LoadPitchTable_All Voice_LoadFilterTable_All Voice_LoadToneTable_All */
/* cc900-module: Voice_LoadFilterTable_Ch Voice_LoadPitchTable_Ch Voice_LoadToneTable_Ch */
void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s)
{
    unsigned char k;
    if (s[100] >= 0x4f) {
        s[99] |= 8;
        Voice_LoadPitchTable_All(ch);
    } else {
        ++s[100];
        s[99] &= ~8;
        k = s[100];
        Voice_LoadPitchTable_Ch(ch, Voice_ToneRampPitch_Curve[k]);
    }
    if (s[101] >= 0x96) {
        Voice_LoadFilterTable_All(ch);
        Voice_LoadToneTable_All(ch);
    } else {
        ++s[101];
        s[99] &= ~8;
        k = s[101] / 6;
        Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
        Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
    }
}
/* ---- voice-list walker: only layer type 0x10 does anything; the load of the patch pointer is discarded ---- */
/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: ToneGen_WriteVoice_Reg21_Reg22 */
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 0x20:
            break;
        case 8:
            break;
        case 0x10:
            (void)*(unsigned char **)(v + 19);
            Voice_Calc_LevelPair_FixedAtk(v);
            Voice_WriteChPanShift2(v, 0);
            ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            break;
        }
    }
}
/* ---- audio-channel commands 1, 3 and 2: scale the controller, set the bus bits, refresh the part's voices ---- */
/* cc900-module: AudioMod_Apply_Porta_Curve AudioMod_Apply_BusRouting Pitch_Refresh_Sounding_Voices */
void AudioChannel_Handler_Cmd01(unsigned char part, unsigned int val, unsigned char *m)
{
    if (val & 32768) val &= ~0x8000;
    else val <<= 7;
    AudioMod_Apply_Porta_Curve(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 16, 32);
    Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}
/* cc900-module: AudioMod_Scale_To_Part_1F AudioMod_Apply_BusRouting TVF_Refresh_Sounding_Voices */
void AudioChannel_Handler_Cmd03(unsigned char part, unsigned char val, unsigned char *m)
{
    AudioMod_Scale_To_Part_1F(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 64, 128);
    TVF_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}
/* cc900-module: AudioMod_Scale_To_LevelPairShift AudioMod_Scale_To_LevelPairShf AudioMod_Apply_BusRouting */
/* cc900-module: AudioChannel_AllVoices_Update_PanShift AudioChannel_AllVoices_UpdPan */
void AudioChannel_Handler_Cmd02(unsigned char part, unsigned char val, unsigned char *m)
{
    unsigned char *list;
    AudioMod_Scale_To_LevelPairShf(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 256, 512);
    switch ((*(unsigned char **)&ram_4136e[part * 0x11f])[16] & 0xc0) {
    case 0:
        list = Voice_Query_PartVoices_Mask7F(part);
        break;
    case 0x80:
        list = Voice_Query_PartVoices(part);
        break;
    case 0x40:
    case 0xc0:
        break;
    }
    AudioChannel_AllVoices_UpdPan(list);
}
