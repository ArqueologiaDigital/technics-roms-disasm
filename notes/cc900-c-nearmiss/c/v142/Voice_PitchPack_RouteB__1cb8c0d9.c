/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_A_8b.c (2026-11-16-82-sub-r8)
   sha256 1cb8c0d97ee0913d1788071e80204ef95aa7b7d7498545a92c7b1647e6250df4 (name+funcs); compiled at -Xr */
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
/* lane_sub helper A, round 8, form b (alternatives to form a): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07) that call module-local routines (calr / jr / jrl), plus round-5 misses refined.  Names are the tree's
   labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.  The 71-byte voice records, 39-byte
   node records and 287-byte part records have odd field offsets, so they are read through char pointers
   (B / W / SW / P). */
/* cc900-module: Voice_List_MoveToPool */
/* cc900-module: Voice_List_MoveToPartList */
/* cc900-module: Voice_PerVoice_PortamentoPitchUpdate */
/* cc900-module: Voice_Demote_Decayed */
/* cc900-module: Voice_Reprioritise */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 */
/* cc900-module: Voice_UpdateFlagsFromSlot */
/* cc900-module: Voice_Selector_ComputeMixWeights */
/* cc900-module: Pitch_Saturate_15bit */
/* cc900-module: Pitch_Fold_Octaves_Into_Range */
/* cc900-module: TVF_Calc_Cutoff_NoKeyFollow */
/* cc900-module: TVF_Bias_Clamp_Amount */
/* cc900-module: TVF_Lookup_Depth_Amount */
/* cc900-module: TVF_Clamp_Cutoff */
/* cc900-module: Voice_Clamp_Byte_WA */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: DList_Unlink_SelfLink */
/* cc900-module: DList_InsertAfter_Offsets0 */
/* cc900-module: DList_Unlink_SelfLink_Offsets8 */
/* cc900-module: DList_InsertAfter_Offsets8 */
extern int __near ram_293e;
extern int __near ram_2940;
extern int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451da;
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned long ram_45310;
extern int ram_41347;
extern unsigned int Voice_GlobalFlags;
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char ram_41368[];
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
extern unsigned int __near ram_2936[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct z6 { int w0; char pad[2]; int w4; };
struct pkt *Voice_Query_AllChannels(void);
void Voice_SetMasterTune(int a);
void Voice_SetKeyShiftEnable(int a);
void Pitch_Refresh_Sounding_Voices(struct pkt *q);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
void Voice_PerVoice_PortaPitchUpd(int n);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_Reprioritise(unsigned char *p);
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
int TVF_Clamp_Cutoff(int a);
int Voice_Clamp_Byte_WA(int a);
void DList_Unlink_SelfLink(unsigned char *n);
void DList_InsertAfter_Offsets0(unsigned char *n, unsigned char *q);
void DList_Unlink_SelfLink_Offsets8(unsigned char *n);
void DList_InsertAfter_Offsets8(unsigned char *n, unsigned char *q);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a);
unsigned int Voice_Slot_CalcAmpNibble(int part, int n, int e);
unsigned int Voice_Slot_FindOctaveOffset(int part, int n, int e);
/* ---- round-5 misses ---- */
unsigned long EGEnv_Compute_B_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(void *)(ram_44257 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
unsigned long Voice_Freq_ComputeLeft_Raw(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(void *)(ram_44257 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    return r;
}
void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
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
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}
void Voice_Clear_HoldBit(int n)
{
    unsigned char c;
    c = n;
    ram_14af[(int)c * 39] &= 0x7f;
    ram_2936[(int)(c >> 4)] &= ~(1 << (c & 0xf));
    Voice_Reprioritise(ram_148d + (int)c * 39);
}
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    int d, k;
    unsigned char *t;
    t = (*(unsigned char **)((v) + (23)));
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
/* ---- module-local callers ---- */
void Voice_Demote_Decayed(unsigned char *p)
{
    if ((p[34] & 3) == 0) {
        p[34] &= 0xf3;
        p[34] |= 2;
        Voice_List_MoveToPool(p, (*(unsigned char **)((p) + (29))), 6);
    }
}
void Voice_AllVoices_PortamentoUpdate(void)
{
    unsigned char i;
    for (i = 0; i < 0x1a; i++) Voice_PerVoice_PortaPitchUpd(i);
}
void Voice_Reprioritise(unsigned char *p)
{
    if (p[34] & 0x80) return;
    if (p[37] < 0x80) Voice_Demote_Decayed(p);
    else if (p[34] & 8) {
        p[34] &= ~8;
        p[34] |= 4;
        Voice_List_MoveToPool(p, (*(unsigned char **)((p) + (29))), p[38]);
    }
}
void VoiceSlot_NoteOff(unsigned char n)
{
    unsigned char *v;
    if (n < 0x40) {
        v = &ram_148d[(int)n * 39];
        Voice_List_MoveToPartList(v, (*(unsigned char **)((v) + (24))), 1);
        Voice_Reprioritise(v);
        if (v != (*(unsigned char **)((v) + (16)))) DList_Unlink_SelfLink_Offsets16(v);
    }
}
void Voice_InitFromSlot(unsigned char part)
{
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
    ram_41472[(int)part * 287] = 0;
    ram_41473[(int)part * 287] = 0;
    ram_41474[(int)part * 287] = 0;
    ram_41475[(int)part * 287] = 0;
}
void Voice_SetArticWord0_LowByte(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (0))) &= 0xff00;
    (*(unsigned int *)((q) + (0))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
void Voice_Artic_SetWord1Nibble2_And_Word3(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (2))) &= 0xf0ff;
    (*(unsigned int *)((q) + (2))) |= (unsigned int)(b & 0xf) << 8;
    b >>= 4;
    (*(unsigned int *)((q) + (6))) = b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
/* cc900-name: Voice_Artic_SetW2W1_Nibble1=Voice_Artic_SetWord2Word1_Nibble1 */
void Voice_Artic_SetW2W1_Nibble1(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (4))) &= 0xff0f;
    (*(unsigned int *)((q) + (4))) |= (unsigned char)(b << 4);
    (*(unsigned int *)((q) + (2))) &= 0xff0f;
    b &= 0xf0;
    (*(unsigned int *)((q) + (2))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
void Voice_Artic_SetWord2Word1_Nibble0(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (4))) &= 0xfff0;
    (*(unsigned int *)((q) + (4))) |= b & 0xf;
    (*(unsigned int *)((q) + (2))) &= 0xfff0;
    b >>= 4;
    (*(unsigned int *)((q) + (2))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
void Voice_Artic_SetWord0Word2_Nibble2(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (0))) &= 0xf0ff;
    (*(unsigned int *)((q) + (0))) |= (unsigned int)(b & 0xf) << 8;
    (*(unsigned int *)((q) + (4))) &= 0xf0ff;
    b &= 0xf0;
    (*(unsigned int *)((q) + (4))) |= (unsigned int)b << 4;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
/* cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v)
{
    int d;
    d = (*(int *)((v) + (10))) + ram_41347;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x10) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x20) d -= (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
        else d += (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
    }
    ram_451da = Pitch_Saturate_15bit(d);
}
void Voice_Pitch_CopyBase(unsigned char *v)
{
    unsigned char *t;
    int p;
    t = (*(unsigned char **)((v) + (23)));
    p = (*(int *)(((*(unsigned char **)((v) + (31)))) + (12)));
    (*(int *)((v) + (8))) = p;
    p += (int)(char)t[3] << 8;
    p += (int)(char)t[4] * 2;
    (*(int *)((v) + (6))) = Pitch_Fold_Octaves_Into_Range(p, (*(unsigned char **)((v) + (31)))[9], (*(unsigned char **)((v) + (31)))[10]);
}
void Voice_PitchPack_RouteC(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    t = (*(unsigned char **)((v) + (23)));
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    (*(int *)((v) + (66))) = r | (((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10));
    (*(int *)((v) + (68))) = r;
    ram_2940 = 0;
}
void Voice_PitchPack_RouteD(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    t = (*(unsigned char **)((v) + (23)));
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    (*(int *)((v) + (66))) = (r | (((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10))) | 0x80;
    r |= 0x80;
    (*(int *)((v) + (68))) = r;
    ram_2940 = 0;
}
void Voice_PitchPack_RouteE(unsigned char *v)
{
    unsigned char *t;
    unsigned int r1, r2;
    t = (*(unsigned char **)((v) + (23)));
    r1 = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    r2 = TVF_Calc_Cutoff_NoKeyFollow(v, t[19]);
    (*(int *)((v) + (66))) = (r1 | (((unsigned int)t[18] << 13) | ((unsigned int)t[20] << 10))) | 0x80;
    (*(int *)((v) + (68))) = r2;
    ram_2940 = 0;
}
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (t = (*(unsigned char **)((v) + (23))))[17]);
    (*(int *)((v) + (66))) = r | (((unsigned int)t[18] << 13) | 0x400);
    r = TVF_Bias_Clamp_Amount(t[19]);
    (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(t[20]);
}
void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (t = (*(unsigned char **)((v) + (23))))[17]);
    (*(int *)((v) + (66))) = (r | (((unsigned int)t[18] << 13) | 0x400)) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(t[20]);
}
void Voice_Retire_ToFreePool(unsigned char *v)
{
    if (!(v[34] & 1)) {
        if ((*(unsigned char **)((v) + (29)))[1] != 0) (*(unsigned char **)((v) + (29)))[1]--;
        Voice_List_MoveToPool(v, ram_132b, 6);
        Voice_List_MoveToPartList(v, ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        if ((*(unsigned char **)((v) + (29)))[1] < (*(unsigned char **)((v) + (29)))[0]) (*(unsigned char **)((v) + (29)))[1]++;
    }
}
void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    int d;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) d = ((*(int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31];
        else d = ((*(int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31];
        d = TVF_Clamp_Cutoff(d);
        ram_451d4 = ((*(int *)((v) + (66))) & 0xff80) | d;
    } else ram_451d4 = (*(int *)((v) + (66)));
    ram_451d6 = (*(int *)((v) + (68)));
}
void TVF_Emit_Offset_Both(unsigned char *v)
{
    int d;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) d = ((*(int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31];
        else d = ((*(int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31];
        d = TVF_Clamp_Cutoff(d);
        ram_451d4 = ((*(int *)((v) + (66))) & 0xff80) | d;
        ram_451d6 = ((*(int *)((v) + (68))) & 0xff80) | d;
    } else {
        ram_451d4 = (*(int *)((v) + (66)));
        ram_451d6 = (*(int *)((v) + (68)));
    }
}
void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (12)));
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (16)));
    b += (*(int *)((v) + (51)));
    b = Voice_Clamp_Byte_WA(b);
    b = Voice_OutputLevel_Table[b] * 2;
    if ((*(unsigned char **)((v) + (15)))[2] & 0x80) w = ((unsigned int)(*(unsigned char **)((v) + (15)))[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[(*(unsigned int *)((v) + (6))) >> 8];
    ram_451d0 = b | w | 0x8000;
}
unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_4424e + (int)n * 27;
    x = EGEnv_BaseCurve_A[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_44257 + (int)n * 27;
    x = EGEnv_BaseCurve_B[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    int x, k;
    unsigned char *t;
    unsigned int w;
    x = d;
    t = (*(unsigned char **)((v) + (23)));
    if (x != 0) {
        k = TVF_KeyFollow_Curves[(t[54] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        x = x * k >> 5;
        c += x;
    }
    if (s != 0) {
        w = ((*(unsigned int *)((v) + (8))) & 0x7f00) >> 8;
        if (w > t[59]) w = t[59];
        else if (w < t[58]) w = t[58];
        w -= t[57];
        c += (s * (int)w) >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
/* cc900-name: VList_MoveToPool=Voice_List_MoveToPool */
void VList_MoveToPool(unsigned char *n, unsigned char *list, unsigned char k)
{
    unsigned char *o;
    unsigned char c;
    o = (*(unsigned char **)((n) + (29)));
    c = n[33];
    if (((unsigned char **)(o + 2))[c] == n) {
        if ((*(unsigned char **)((n) + (0))) != n) ((unsigned char **)(o + 2))[c] = (*(unsigned char **)((n) + (0)));
        else ((unsigned char **)(o + 2))[c] = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 2)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 2)) = n;
        DList_Unlink_SelfLink(n);
    } else DList_InsertAfter_Offsets0(n, *(unsigned char **)(list + ((int)k * 4 + 2)));
    (*(unsigned char **)((n) + (29))) = list;
    n[33] = k;
}
/* cc900-name: VList_MoveToPartList=Voice_List_MoveToPartList */
void VList_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k)
{
    unsigned char *o;
    unsigned char c;
    o = (*(unsigned char **)((n) + (24)));
    c = n[28];
    if (((unsigned char **)(o + 4))[c] == n) {
        if ((*(unsigned char **)((n) + (8))) != n) ((unsigned char **)(o + 4))[c] = (*(unsigned char **)((n) + (8)));
        else ((unsigned char **)(o + 4))[c] = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 4)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 4)) = n;
        DList_Unlink_SelfLink_Offsets8(n);
    } else DList_InsertAfter_Offsets8(n, *(unsigned char **)(list + ((int)k * 4 + 4)));
    (*(unsigned char **)((n) + (24))) = list;
    n[28] = k;
}
