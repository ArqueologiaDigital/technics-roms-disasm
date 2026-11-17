/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_A_5c.c (2026-11-16-65-sub-r5)
   sha256 09c292fa5e91cf282961b4fc5be904dd8de13788233cab2e51d31258c1407768 (name+funcs); compiled at -Xr */
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
/* lane_sub helper A, round 5, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07).  Round-4 misses refined, plus Voice_Clear_HoldBit.  Names are the tree's labels; ram_<hex> is a RAM cell
   (sub-CPU address) the tree has not named.  The 71-byte voice records and 287-byte part records have odd field
   offsets, so they are read through char pointers (B / W / P). */
extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned int ram_100002;
extern int __near ram_293e;
extern int __near ram_2940;
extern int ram_451ce;
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned long ram_45310;
extern unsigned char *ram_45314;
extern int ram_41349;
extern unsigned int Voice_GlobalFlags;
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
extern unsigned int EGEnv_ValueCurve_Simple[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char ram_41368[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned int __near ram_2936[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct pslot { unsigned char *src; unsigned char *tone; };
struct z6 { int w0; char pad[2]; int w4; };
struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };
int TVF_Clamp_Cutoff(int a);
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a);
unsigned int Voice_Slot_CalcAmpNibble(int part, int n, int e);
unsigned int Voice_Slot_FindOctaveOffset(int part, int n, int e);
struct pkt *Voice_Query_AllChannels(void);
void Voice_NoteState_Clear(int n);
void Voice_Reprioritise(unsigned char *p);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
/* ---- round-4 misses ---- */
int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d, r;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = (int)a - (int)b;
    r = s;
    r *= d;
    r >>= 5;
    return r;
}
int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d, r;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = (int)a - (int)b;
    r = s;
    r *= d;
    r >>= 5;
    return r;
}
int PitchBend_Scale(char a, unsigned char b, unsigned char e)
{
    int r;
    b &= 0x7f;
    if (a < 0) {
        b = (unsigned int)Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    r = PitchBend_ScaleCoeff_Table[b];
    r *= a;
    return r >> (e & 0xf);
}
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    int d, k;
    t = (*(unsigned char **)((v) + (23)));
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += (int)d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int lo, hi, n;
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
void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ((unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12))[(unsigned int)c];
    y = ((unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12))[(unsigned int)c + 4];
    ((unsigned char *)(unsigned long)(ram_24e6 + (int)y * 12))[(unsigned int)c] = x;
    ((unsigned char *)(unsigned long)(ram_24e6 + (int)x * 12))[(unsigned int)c + 4] = y;
    ((unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12))[(unsigned int)c] = a;
    ((unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12))[(unsigned int)c + 4] = a;
}
void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    ((struct pslot *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])->tone =
        Voice_DefaultToneRecord;
}
void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned char *q;
    unsigned int *f;
    q = &ram_41368[part * 287 + 258];
    f = (unsigned int *)(ram_41368 + part * 287) + 1;
    if ((*(unsigned int *)((q) + (0))) != 0) *f |= 1; else *f &= ~1;
    if ((*(unsigned int *)((q) + (2))) != 0) *f |= 2; else *f &= ~2;
    if ((*(unsigned int *)((q) + (4))) != 0) *f |= 4; else *f &= ~4;
    if ((*(unsigned int *)((q) + (6))) != 0) *f |= 8; else *f &= ~8;
}
void Voice_PortamentoTargets_SetAll(unsigned char part)
{
    unsigned int i;
    unsigned int v;
    for (i = 0; i < 4; i++) {
        v = (*(unsigned char **)&(ram_41368 + (int)part * 287)[(unsigned long)i * 37 + 0x6e])[2];
        v |= (unsigned int)(*(unsigned char **)&(ram_41368 + (int)part * 287)[(unsigned long)i * 37 + 0x6e])[3] << 8;
        *(unsigned int *)&(ram_41368 + (int)part * 287)[(unsigned long)i * 2 + 0x102] = v & 0xfff;
    }
}
/* cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
void WaveSel_StageB_Reg040_Footage(unsigned char *v)
{
    struct z6 *t;
    unsigned int w;
    t = (struct z6 *)(*(unsigned char **)((*(unsigned char **)((v) + (31))) + 5) + ram_45310);
    if (v[3] == 0) t += Voice_KeyIndex_Pack3Nibbles(Voice_Slot_CalcAmpNibble(v[4], v[0], v[3]));
    else if (v[3] < 3) t += Voice_KeyIndex_Pack3Nibbles(Voice_Slot_FindOctaveOffset(v[4], v[0], v[3]));
    else t += ((unsigned int *)((*(unsigned char **)((v) + (35))) + 0x102))[v[3]];
    (*(unsigned char **)((v) + (15))) = (unsigned char *)t;
    (*(unsigned int *)((v) + (1))) |= 0x4000;
    ram_451ce = t->w0;
    ram_293e = t->w4;
    if (Voice_GlobalFlags & 4) {
        w = (ram_451ce & 0xf000) << 1;
        ram_451ce &= 0xfff;
        ram_451ce |= w;
    }
}
unsigned long EGEnv_Compute_A_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_4424e[(int)n * 27];
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
unsigned long EGEnv_Compute_A_Simple_Dup(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_4424e[(int)n * 27];
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
unsigned long EGEnv_Compute_B_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)((unsigned long)ram_44257 + (int)n * 27);
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
    p = (unsigned char *)((unsigned long)ram_44257 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    return r;
}
void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)((unsigned long)ram_44260 + (int)n * 27);
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
    p = (unsigned char *)((unsigned long)ram_44260 + (int)n * 27);
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
/* ---- tone-generator writers ---- */
void ToneGen_SilenceChannel(unsigned char ch)
{
    unsigned char c;
    __IZ = ch;
    c = __IZ;
    ram_18 &= 0x7f;
    ram_100000 = (unsigned char)(c + 0xc0);
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= 0x7f;
    ram_100000 = c;
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
    for (i = 0; i < 0x1a; i++) Voice_NoteState_Clear(i);
    __XIZ = (unsigned long)((unsigned char *)Voice_Query_AllChannels() + 5);
    for (; *(unsigned char *)__XIZ < 0x40; __XIZ++) {
        ram_18 &= 0x7f;
        ram_100000 = *(unsigned char *)__XIZ + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= 0x7f;
        ram_100000 = *(unsigned char *)__XIZ + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}
/* ---- new in round 5 ---- */
void Voice_Clear_HoldBit(unsigned char n)
{
    unsigned char c;
    c = n;
    ram_14af[(int)c * 39] &= 0x7f;
    ram_2936[c >> 4] &= ~(1 << (c & 0xf));
    Voice_Reprioritise(ram_148d + (int)c * 39);
}
void Voice_Slot_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned char *t23;
    unsigned char *t31;
    int p;
    s = (*(unsigned char **)((v) + (35)));
    t23 = (*(unsigned char **)((v) + (23)));
    t31 = (*(unsigned char **)((v) + (31)));
    p = ((int)(v[5] & 0x7f) << 8) + 0x80 + *(int *)(s + 274) + ram_41349 + ((int)(char)s[22] << 8)
        + ((int)(char)s[109] << 8);
    *(unsigned int *)(v + 8) = Pitch_Saturate_15bit(p);
    p -= ((int)t31[11] << 8) + 0x80;
    p += *(int *)(t31 + 12);
    p += (int)(char)t23[3] << 8;
    p += (char)t23[4];
    *(int *)(v + 6) = Pitch_Fold_Octaves_Into_Range(p, t31[9], t31[10]);
}
void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    ((struct pslot3 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])->pitch =
        (unsigned long)w * k + l + ram_45310;
}
