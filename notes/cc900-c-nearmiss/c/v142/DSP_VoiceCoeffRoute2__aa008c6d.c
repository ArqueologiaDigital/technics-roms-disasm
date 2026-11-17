/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_T_18b.c (2026-11-17-7-sub-r18)
   sha256 aa008c6d3ee351d97d3215487e374cfb692c1c8d305bd3933562e7a6fd9be487 (name+funcs); compiled at -Xr */
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
/* lane_sub helper T, round 18, form b (KN5000 sub-CPU payload v1.42); written by gen_T_18.py (lane_sub's
   scratch T/).  The functions round 17 left open with a sub_N_17* best attempt, each its best earlier file
   (sub_N_17c, sub_D_8c, sub_D_6c) changed only where said, and two new ones of pool D:
   Flag arrays: as form a with the column doubled by add, (j + j).
   InitFlags: k a register local of the `if (i == 1)` block.
   EFF_SecondaryLinkPath: m an int declared before i.
   EGEnv_Compute_B: (unsigned int)x | (unsigned int)(int)T[..] with an unsigned table (A's second match).
   VoiceParam_Set_Tone_Option: int o; o = (unsigned int)idx; o += 472.
   DSP_VoiceCoeffRoute2: the relocation as (long)RelBase + tbl.
   Debug_Print_Word: as form a with the boot ROM routine unprototyped.
   RingBuf_ReadByte / DSP_RingBuf_Read: *(((unsigned long)i + 6) + (unsigned char *)r) through an unsigned int local.
   DSP1_ResolveStreamPtr: as form a with the locals declared in the reverse order.
   DSP_FlushAllSlots / DSP_InitChannelSlot: the buffer pointer cell an unsigned long (no pointer cast to copy it);
     InitChannelSlot without the second local.
   DSP_WriteAlgoBuffer: the loop counter an unsigned int assigned to nothing else; destination through a pointer local. */
/* cc900-module: DSP_WriteCount_Compute */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 */
/* cc900-module: DSP_VelocityToVolume */
/* cc900-module: DSP_GetEffectRouting */
/* cc900-module: Unsigned_Max_Select */
/* cc900-module: DSP_InitChannelSlot */
/* cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct sv56 { char pad[8]; int on; char pad2[46]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct tgparams { int w[0x22]; };
struct r16 { unsigned char b[16]; };
struct e2 { unsigned char b0, b1; };
struct img295 { unsigned char b[294]; unsigned char last; };
extern unsigned char __near ram_45d4[];
extern unsigned char __near ram_45d6[];
extern unsigned char __near ram_45fa[];
extern unsigned char __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned char __near ram_4930[];
extern struct e50 __near ram_4940[];
extern unsigned char __near ram_4942[];
extern unsigned char __near ram_4944[];
extern unsigned char __near ram_4966[];
extern unsigned int __near DSP_AlgoChangedFlag;
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_41368[]; /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned long ram_4531c;
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];
extern unsigned char EFF_SlotSettleTime_Table[];
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, int len, int *out);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
extern void BootROM_HEX_BYTE_TO_ASCII();
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_ParamEdit_WithDebug(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void DSP_ScheduleDelay(int);
extern unsigned int Unsigned_Max_Select(unsigned int, unsigned int);
extern unsigned int DSP_GetEffectRouting(void);
extern unsigned int DSP_VelocityToVolume(unsigned int);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
extern void Voice_ActiveFlag_CheckAndLoad();
extern void Voice_Part_ResetSlotRouting();
extern void DSP_SlotParam_Write_Slot0();
extern void DSP_SlotParam_Write_Slot1();
extern void DSP_SlotParam_Write_Slot2();
extern void DSP_SlotParam_Write_Slot3();
extern void DSP_SlotParam_Write_Slot4();
extern void VoiceAlloc_Apply_Algo_Group0();
extern unsigned char *Voice_AllocateForSustain();
extern void Voice_AllNotes_SustainRetrigger(unsigned char *v, unsigned int n);
extern unsigned char ram_7800[];
extern unsigned char DSP1_ImageHeader_UserKit[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern void InterCPU_E1_DMA_Transfer(unsigned char *p, unsigned int n, unsigned long dst);
void Debug_Print_Word(unsigned int w);
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p);
struct b58 { unsigned char b[58]; };
struct b11 { unsigned char b[11]; };
struct b426 { unsigned char b[426]; };
struct e80 { unsigned char a[58]; unsigned char x[11]; unsigned char y[11]; };
struct p442 { unsigned char pad[442]; unsigned char x[11]; };
struct p121 { unsigned char pad[121]; unsigned char f[1]; };
extern unsigned char ram_4136e[]; /* Part_PatchRecord_Ptr */
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
unsigned int DSP_WriteCount_Compute(void);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | (unsigned int)(int)EGEnv_ModeBits_Table[p[0] & 3];
}
void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    int o;
    o = (unsigned int)idx;
    o += 472;
    ram_44fce[o] = v;
    switch (idx) {
    case 0:
        Voice_ActiveFlag_CheckAndLoad(part);
        break;
    case 1:
        Voice_Part_ResetSlotRouting(part);
        if (v != 0xf5) DSP_SlotParam_Write_Slot0(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 2:
        DSP_SlotParam_Write_Slot1(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 3:
        DSP_SlotParam_Write_Slot2(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 5:
        DSP_SlotParam_Write_Slot3(part);
        break;
    case 6:
        DSP_SlotParam_Write_Slot4(part);
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(part), 1);
        break;
    }
}
void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    s = sel;
    s &= 15;
    z = (sel & 0xf0) >> 4;
    x = (*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = (unsigned char *)ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = (unsigned char *)ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[25];
    tbl = (long)ToneDB_RelBase + tbl;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w & 0xff));
    __WA = 0;
}
int RingBuf_ReadByte(struct ring4k *r)
{
    unsigned int i;
    int c;
    unsigned int u;
    if (r->n != 0) {
        i = r->r++ & 0xfff;
        u = *(((unsigned long)i + 6) + (unsigned char *)r);
        c = u;
        r->n--;
    } else
        c = -1;
    return c;
}
int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;
    unsigned int u;
    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        u = *(((unsigned long)i + 6) + (unsigned char *)r);
        c = u;
        r->n--;
    } else
        c = -1;
    return c;
}
unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *q;
    unsigned long v;
    unsigned long off;
    unsigned long *tbl;
    unsigned char *base;
    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    tbl += n;
    v = *tbl;
    q = base;
    base += v;
    return base;
}
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n)
{
    unsigned char *t;
    unsigned char *q;
    t = ToneDB_Find_SubToneRecord(rec, (unsigned char)n, 0xff);
    *(struct b58 *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c) = *(struct b58 *)t;
    t = (unsigned char *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c);
    q = t + 16;
    *(struct b11 *)((struct e80 *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c))->x = *(struct b11 *)WaveSel_StageA1_FromToneSlot(0, q, (unsigned char)n, 0xff);
    q[2] &= 0xcf;
    q[2] |= 0x10;
    q = t + 37;
    *(struct b11 *)((struct e80 *)(((unsigned long)n * 80 + 0x4aa7) + ram_4531c))->y = *(struct b11 *)WaveSel_StageA1_FromToneSlot(1, q, (unsigned char)n, 0xff);
    q[2] &= 0xcf;
    q[2] |= 0x10;
}
void DSP_FlushAllSlots(unsigned char a, unsigned char b)
{
    unsigned char *rec;
    unsigned int i;
    rec = (unsigned char *)ToneDB_Find_ToneRecord(a, b);
    *(struct img295 *)(ram_4531c + 0x4980) = *(struct img295 *)rec;
    for (i = 0; i < 0x80; i++) {
        ((struct e2 *)((unsigned long)&((struct e2 *)0x49a7)[i] + ram_4531c))->b1 &= ~0x20;
        ((struct e2 *)((unsigned long)&((struct e2 *)0x49a7)[i] + ram_4531c))->b1 |= 0x20;
    }
    for (i = 0; i < 0x80; i++)
        DSP_InitChannelSlot(rec, i);
    for (i = 0; i < 0x10; i++)
        *(unsigned char *)(((unsigned long)i + 0x4980) + ram_4531c) = DSP1_ImageHeader_UserKit[i];
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);
}
unsigned char DSP_WriteAlgoBuffer(unsigned char part, unsigned char slot)
{
    unsigned char i;
    unsigned char *x;
    unsigned char *d;
    if (part >= 0x1a || slot >= 0x28)
        return 2;
    *(struct b426 *)&((unsigned char *)ram_4531c)[slot * 0x1d6 + 0x10] = *(struct b426 *)*(unsigned char **)&ram_4136e[part * 0x11f];
    for (i = 0; i < 4; i++) {
        d = &((unsigned char *)ram_4531c)[slot * 0x1d6 + i * 11];
        *(struct b11 *)((struct p442 *)d)->x = *(struct b11 *)(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(i) * 37 + 110] + 4));
        x = ((struct p121 *)&((unsigned char *)ram_4531c)[slot * 0x1d6 + i * 81])->f;
        if ((*x & 0xc0) != 0xc0) {
            *x &= 0xcf;
            *x |= 0x10;
        }
    }
    *(unsigned int *)(((unsigned char *)ram_4531c) + 0x72a8) = DSP_WriteCount_Compute();
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);
    return 0;
}
void EFF_VolumeLoop(unsigned long p)
{
    unsigned int i;
    unsigned int d;
    for (i = 0; i < 5; i++) {
        if ((*(unsigned int *)&(ram_4944)[(i) * 50 + ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) << 1)]) == 1) {
            d = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx;
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x3f) {
                ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] - EFF_VolumeReduction_Steps[((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[1]];
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] < 0)
                    ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type, d, p);
        }
    }
}
void EFF_SlotActive_UpdateFlags(unsigned long p)
{
    unsigned int i;
    unsigned int found;
    found = 0;
    if (DSP_AlgoChangedFlag == 1) {
        for (i = 0; i < 5; i++)
            EFF_SlotActiveFlags.active[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (((struct cfg *)p)->f0 == 1 && EFF_SlotActiveFlags.r[i].g[4] == 1) || (EFF_SlotActiveFlags.r[i].g[4] == 1 && found == 1)) {
                EFF_SlotActiveFlags.active[i] = 1;
                (*(unsigned int *)&(ram_4944)[(i) * 50 + ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) << 1)]) = 1;
                EFF_SlotActiveFlags.r[i].g[1] = 1;
                EFF_SlotActiveFlags.r[i].g[2] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->r42[3] != 0x63)
                    EFF_SlotActiveFlags.r[i].g[0] = 1;
            } else
                EFF_SlotActiveFlags.active[i] = 0;
        }
    }
}
void EFF_ParamIterator_Process(unsigned int slot, unsigned long p)
{
    unsigned int i;
    unsigned int n;
    unsigned char *q;
    switch (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type) {
    default:
        n = ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if ((*(unsigned int *)&(ram_4944)[(slot) * 50 + ((i) + (i))]) == 1 && i != ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->idx)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->param[13] & 1) * 11];
        while (*q != 12) {
            if ((*(unsigned int *)&(ram_4944)[(*q) * 2u + (slot) * 50]) == 1)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, *q, p);
            q++;
        }
        break;
    }
}
void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;
    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if ((*(unsigned int *)&(ram_45d4)[(i) * 56 + ((j) + (j))]) != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                (*(unsigned int *)&(ram_4942)[(i) * 50 + ((j) + (j))]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4942)[(i) * 50 + ((j) + (j))]) = 0;
        }
        for (j = 0; j < 17; j++) {
            if ((*(int *)&(ram_45d6)[(i) * 56 + ((j) + (j))]) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                (*(unsigned int *)&(ram_4944)[(i) * 50 + ((j) + (j))]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4944)[(i) * 50 + ((j) + (j))]) = 0;
        }
        for (j = 0; j < 1; j++) {
            if ((*(int *)&(ram_45fa)[(i) * 56 + ((j) + (j))]) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                (*(unsigned int *)&(ram_4966)[(i) * 50 + ((j) + (j))]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4966)[(i) * 50 + ((j) + (j))]) = 0;
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on != (*(int *)&(ram_4600)[i * 56 + 8])) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}
void EFF_DspChannel_InitFlags(unsigned long p)
{
    unsigned int i;
    unsigned int j;
    for (i = 0; i < 5; i++) {
        if (DSP_AlgoChangedFlag == 1)
            ram_4940[i].f0 = 1;
        if (ram_4940[i].f0 == 1) {
            for (j = 0; j < 17; j++)
                (*(unsigned int *)&(ram_4944)[(i) * 50 + ((j) + (j))]) = 1;
            for (j = 0; j < 1; j++)
                (*(unsigned int *)&(ram_4942)[(i) * 50 + ((j) + (j))]) = 1;
            for (j = 0; j < 1; j++)
                (*(unsigned int *)&(ram_4966)[(i) * 50 + ((j) + (j))]) = 1;
            EFF_SlotActiveFlags.r[i].g[0] = 1;
            EFF_SlotActiveFlags.r[i].g[1] = 1;
            EFF_SlotActiveFlags.r[i].g[2] = 1;
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
            if (i == 1) {
                register unsigned int k;
                k = ((struct cfg *)p)->s[0].idx + 1;
                switch (((struct cfg *)p)->s[0].type) {
                default:
                    (*(unsigned int *)&(ram_4930)[k * 2 + 0x14]) = 1;
                    break;
                case 0x0f: case 0x35:
                    k++;
                    (*(unsigned int *)&(ram_4930)[k * 2 + 0x14]) = 1;
                    break;
                }
            }
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x27) {
            if (EFF_SlotActiveFlags.r[i].flags[0] == 1 || EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1) {
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
                EFF_SlotActiveFlags.r[i].flags[1] = 0;
                EFF_SlotActiveFlags.r[i].flags[2] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[3] == 1 || EFF_SlotActiveFlags.r[i].flags[4] == 1 || EFF_SlotActiveFlags.r[i].flags[5] == 1) {
                EFF_SlotActiveFlags.r[i].flags[3] = 1;
                EFF_SlotActiveFlags.r[i].flags[4] = 0;
                EFF_SlotActiveFlags.r[i].flags[5] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[6] == 1 || EFF_SlotActiveFlags.r[i].flags[7] == 1 || EFF_SlotActiveFlags.r[i].flags[8] == 1) {
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[7] = 0;
                EFF_SlotActiveFlags.r[i].flags[8] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[9] == 1 || EFF_SlotActiveFlags.r[i].flags[10] == 1 || EFF_SlotActiveFlags.r[i].flags[11] == 1) {
                EFF_SlotActiveFlags.r[i].flags[9] = 1;
                EFF_SlotActiveFlags.r[i].flags[10] = 0;
                EFF_SlotActiveFlags.r[i].flags[11] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[12] == 1 || EFF_SlotActiveFlags.r[i].flags[13] == 1 || EFF_SlotActiveFlags.r[i].flags[14] == 1) {
                EFF_SlotActiveFlags.r[i].flags[12] = 1;
                EFF_SlotActiveFlags.r[i].flags[13] = 0;
                EFF_SlotActiveFlags.r[i].flags[14] = 0;
            }
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x4f) {
            if (EFF_SlotActiveFlags.r[i].flags[1] == 1) {
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
                EFF_SlotActiveFlags.r[i].flags[1] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[3] == 1) {
                EFF_SlotActiveFlags.r[i].flags[2] = 1;
                EFF_SlotActiveFlags.r[i].flags[3] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[5] == 1) {
                EFF_SlotActiveFlags.r[i].flags[4] = 1;
                EFF_SlotActiveFlags.r[i].flags[5] = 0;
            }
            if (EFF_SlotActiveFlags.r[i].flags[7] == 1) {
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[7] = 0;
            }
        }
        if ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x35 || ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x0f) && EFF_SlotActiveFlags.r[i].flags[13] == 1) {
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[13] == 1) {
                EFF_SlotActiveFlags.r[i].flags[3] = 1;
                EFF_SlotActiveFlags.r[i].flags[8] = 1;
                EFF_SlotActiveFlags.r[i].flags[5] = 1;
                EFF_SlotActiveFlags.r[i].flags[10] = 1;
            } else {
                EFF_SlotActiveFlags.r[i].flags[4] = 1;
                EFF_SlotActiveFlags.r[i].flags[9] = 1;
                EFF_SlotActiveFlags.r[i].flags[6] = 1;
                EFF_SlotActiveFlags.r[i].flags[11] = 1;
            }
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else {
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x3f && (EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1))
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        }
        if (EFF_SlotActiveFlags.r[i].g[3] == 1)
            (*(unsigned int *)&(ram_4944)[(i) * 50 + ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) << 1)]) = 1;
    }
}
void EFF_SecondaryLinkPath(struct cfg *p)
{
    int m;
    int i;
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0)
            m = Unsigned_Max_Select(m, 20);
    if (m != 0)
        DSP_ScheduleDelay(m);
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0) {
            if (i != 3 && i != 2)
                EFF_Disconnect(i, p->f6);
            m = Unsigned_Max_Select(m, EFF_SlotSettleTime_Table[i]);
        }
    if (m != 0)
        DSP_ScheduleDelay(m);
}
