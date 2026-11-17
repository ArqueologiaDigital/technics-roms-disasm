/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
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
/* sub_R_17a.c -- lane_sub helper R, round 17, form a (KN5000 sub-CPU payload v1.42; core/08_voice_noteon_and_tonegen.s
   and core/10_dsp_voice_params.s, pool C).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).

   What this form tries (the earlier attempts' first differences are named per function):
   - a row of the 287-byte part records / the 39-byte algorithm descriptors is `(struct T *)(array + int)`, as in
     DSP_SlotParam_Read_To_Cache's matched head: the ROM has `lda base; exts; add` there, and helper D's
     `(unsigned long)array + (long)int` spelling gave a register copy instead;
   - a byte at +N of an indexed 5-byte / 2-byte entry (`lda x,(x+i)` then `(x+N)`) through a struct view of the entry;
   - the edit buffer (0x44fce) rows whose constant offset stays in the 16-bit index (`muls wa,5; add wa,480`): the
     index through `(int)(unsigned int)(...)`, so that V4.23 does not fold the constant into the symbol;
   - BlockCopy_Words_BC_to_HL's second argument is a word pointer: the ROM computes it in XWA and copies it to XBC
     (a pointer conversion), `(unsigned int *)(ram_44fce + int)`;
   - the ToneDB walks statement by statement, the directory offset in a long local (XHL), the index in the
     parameter `b` itself (`sll bc,7; add bc,wa; add bc,bc`);
   - local declaration orders chosen for the ROM's registers (r first in the channel-frequency packets). */
/* cc900-module: BlockCopy_Words_BC_to_HL */
/* cc900-module: WaveSel_StageA1_FindVelSplit */
/* cc900-module: WaveSel_StageA2_FindSetDesc */
/* cc900-module: DSP_ParamWrite_BlockCopy */
/* cc900-module: Algo_SubTable_DispatchA */
/* cc900-module: Algo_SubTable_DispatchB */
/* cc900-module: Algo_SubTable_DispatchC */
/* cc900-module: Algo_SubTable_PanTrim_From_PartFlags */
/* cc900-module: AlgoFlag_Write */
/* cc900-module: AlgoFlag_Write_Bit3 */
/* cc900-module: EFF_RoutingInit */
/* cc900-data: Algo_SubTable_DispatchB 1 = Algo_SubTable_DispatchB_CaseOffsets */
/* cc900-data: Algo_SubTable_DispatchC 1 = Algo_SubTable_DispatchC_CaseOffsets */
/* cc900-data: Algo_SubTable_Bit15Dispatch 1 = Algo_SubTable_Bit15Dispatch_CaseOffsets */
extern unsigned char ram_41368[]; /* Part_Record_Base */
extern unsigned char ram_4136e[]; /* Part_PatchRecord_Ptr */
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_413c7[];
extern unsigned char ram_413c9[];
extern unsigned char ram_44fce[]; /* the tone edit buffer */
extern unsigned char ram_451a7;
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoDescriptor_SelIdx[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
extern unsigned char DSP_AlgoChannel_SelectorByte4[][6];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_Packet1_Curve[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern unsigned char DSP_ChanFreq_IndexMap[];
extern int EGEnv_ModeBits_Table[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct slottail { unsigned char pad[32]; unsigned char f32; unsigned char f33; unsigned char f34; };
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern unsigned char *WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern void WaveSel_Cache_SetDescPtr();
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
/* cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
extern char Algo_PanTrim_From_PartFlags(unsigned char, unsigned char);
/* ---- core/10_dsp_voice_params.s ---- */
/* sub_C_4b stopped at +100: the looked-up word was in DE, the ROM has it in HL.  Here r is declared first. */
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned int r;
    unsigned char t;
    unsigned char sel;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)sel * 0x66))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
/* new: the same shape with two bodies (type 6, then type 7); the ROM has t in L, sel in W, r in HL. */
void DSP_ChanFreq_WritePacket1(unsigned char part)
{
    unsigned char t;
    unsigned char sel;
    unsigned int r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]]
            | EGEnv_ModeBits_Table[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        break;
    case 7:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[DSP_AlgoDescriptor_SelIdx[t * 0x27]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c7 + part * 0x11f) = r;
}
/* sub_D_11b stopped at +58: the descriptor row base (see the head comment). */
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0x40) {
                if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)k * 5 + 0x13] & 2)
                    r = 0xc000;
                else
                    r = 0x4000;
            } else
                r = 0x4000;
        }
        break;
    }
    return r;
}
/* sub_D_11b stopped at +48: the same row base; the entry's byte 1 through a struct view. */
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f1;
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[96];
        break;
    }
    return r;
}
/* sub_D_12b / sub_D_13a stopped at +48 / +35: the same row base. */
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f2;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[96] << 1;
        break;
    case 4: case 5:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[98] << 1;
        break;
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[95] << 1;
        break;
    }
    return r;
}
unsigned char Algo_SubTable_DispatchC(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f3;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[98] - 100;
        r += Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 4: case 5:
        r = Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 6: case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[97] - 100;
        break;
    }
    return r;
}
unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
        r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f4;
        switch (t) {
        case 0: case 1: case 2: case 3:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[97]];
            break;
        case 4: case 5:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[99]];
            break;
        case 8:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
            break;
        }
    } else
        r = 0;
    return r;
}
/* sub_D_9b stopped at +47: the ROM masks the type in C, copies it to r (L) and switches on C. */
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    switch (r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[r * 0x27];
        else
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[100];
        break;
    default:
        r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[100];
        break;
    }
    return r;
}
/* sub_D_11b stopped at +22: the part row base. */
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;
    x = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->p0[2];
    y = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->p0[3];
    return WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41381[part * 0x11f], part);
}
/* sub_D_11b stopped at +22: the part row base; the velocity record is the pointer at +4 of the slot row, its pair
   z at byte 3 + 2 * z. */
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;
    lo = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3];
    hi = ((struct b5 *)&((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3])->f1;
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
/* sub_D_11b stopped at +48: the part row base (pointer + int, then + the long slot offset). */
void Voice_Part_ResetSlotRouting(unsigned char part)
{
    unsigned int k;
    if (ram_451a7 != 0xf5) {
        for (k = 0; k < 4; k++) {
            (*(unsigned char **)((ram_41368 + (int)part * 0x11f) + ((unsigned long)k * 37 + 110)))[6] &= 7;
            (*(unsigned char **)((ram_41368 + (int)part * 0x11f) + ((unsigned long)k * 37 + 110)))[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)((ram_41368 + (int)part * 0x11f) + ((unsigned long)k * 37 + 110)))[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
/* sub_D_11b stopped at +87: the part row base; bytes 32..34 of the slot row through a struct view. */
void VoiceNoteParam_UpdateLoop(unsigned char part)
{
    unsigned char s;
    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        for (s = 0; s < 4; s++) {
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f32 = Algo_SubTable_DispatchA(part, s);
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f33 = Algo_SubTable_DispatchB(part, s);
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f34 = Algo_SubTable_DispatchC(part, s);
        }
    } else {
        for (s = 0; s < 4; s++) {
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f32 = 0;
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f33 = 0;
            ((struct slottail *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[s])->f34 = 0;
        }
    }
}
/* sub_C_6a's first real difference (behind the jump displacement at +43): the ROM loads the patch pointer, then
   adds the extended offset; ours extended the offset first and added the pointer from memory. */
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f) + off,
                                 buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f) + off,
                                 buf);
        return n;
    case 0xc0:
        return 0;
    }
}
/* sub_D_9c stopped at +37: the offset table and the row size had each other's register (XIY / IX; the ROM has
   XIX / IY).  Here the locals are declared base, m, off, and the index is built in b. */
unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel)
{
    unsigned long base;
    unsigned int m;
    unsigned long off;
    switch (sel) {
    case 0x00:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0x40:
        base = ToneDB_RootPtr[5];
        off = ToneDB_RootPtr[8];
        m = ((unsigned int *)ToneDB_RootPtr)[120];
        break;
    case 0x80:
        base = ToneDB_RootPtr[4];
        off = ToneDB_RootPtr[7];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0xc0:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    }
    b = (b << 7) + a;
    b += b;
    return (unsigned char *)((unsigned long)m * (unsigned int)*(unsigned long *)((unsigned long)b + base + ToneDB_RelBase)
                             + off) + ToneDB_RelBase;
}
/* sub_D_8c stopped at +0: the ROM keeps the bank byte and the record number in the parameter b (BC) and the
   directory offset in XHL. */
unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b)
{
    unsigned long p;
    b = *(unsigned char *)(ToneDB_RootPtr[27] + (unsigned long)b + ToneDB_RelBase);
    p = ToneDB_RootPtr[27] + 0x80;
    b = (b << 7) + a;
    b += b;
    b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
    p = ToneDB_RootPtr[2];
    p = *(unsigned long *)((unsigned long)(b << 2) + p + ToneDB_RelBase);
    return (unsigned char *)(ToneDB_RelBase + p);
}
/* new: the same walk through directory 1 for the preset banks, then the user / kit buffers. */
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned long p;
    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        b = *(unsigned char *)(ToneDB_RootPtr[1] + (unsigned long)b + ToneDB_RelBase);
        p = ToneDB_RootPtr[1] + 0x80;
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
        p = ToneDB_RootPtr[2];
        p = *(unsigned long *)((unsigned long)(b << 2) + p + ToneDB_RelBase);
        return (unsigned char *)(ToneDB_RelBase + p);
    }
    if (b == 0x10)
        return ((unsigned long)a * 0x1d6 + 0x10) + ram_4531c;
    if (b == 0x15)
        return ((unsigned long)a * 0x1d6 + 0x10) + ram_45318;
    if (b == 0x50)
        return &ram_4531c[18816];
    if (b == 0x55)
        return ((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318;
    p = ToneDB_RootPtr[2];
    p = *(unsigned long *)(ToneDB_RelBase + p);
    return (unsigned char *)(ToneDB_RelBase + p);
}
/* ---- core/08_voice_noteon_and_tonegen.s ---- */
/* sub_C_9a stopped at +43: its int local for the cache row made a copy (`ld bc,wa; add bc,480`); sub_C_4b's plain
   sum was folded into the symbol.  The ROM adds 480 to the index in place. */
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot];
    q = (&ram_44fce[(int)(unsigned int)((int)slot * 5 + 480)]);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}
/* sub_C_4b stopped at +39 (the record address; sub_C_9a's spelling of it is used here), then the cache row. */
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = (&ram_44fce[(int)(unsigned int)((int)slot * 5 + 500)]);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
/* sub_C_9a stopped at +43: the cache row, as above. */
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot];
    q = (&ram_44fce[(int)(unsigned int)((int)slot * 5 + 480)]);
    if ((rec[54] & 7) == *q) {
        for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        return;
    }
    switch (*q) {
    case 1:
    case 3:
        if ((rec[54] & 7) == 5) {
            rec[77] = 0;
            rec[78] = 1;
            rec[79] = q[1];
            rec[80] = q[2];
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        }
        break;
    case 2:
    case 4:
        if ((rec[54] & 7) == 5) {
            rec[77] = q[1];
            rec[78] = q[2];
            rec[79] = 127;
            rec[80] = 1;
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        }
        break;
    case 5:
        switch (rec[54] & 7) {
        case 1:
        case 3:
            rec[77] = q[3];
            rec[78] = q[4];
            rec[79] = 64;
            rec[80] = 135;
            break;
        case 2:
        case 4:
            rec[77] = q[1];
            rec[78] = q[2];
            rec[79] = 64;
            rec[80] = 7;
            break;
        }
        break;
    }
}
/* sub_C_9a stopped at +52: the cache row, as above. */
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = (&ram_44fce[(int)(unsigned int)((int)slot * 5 + 500)]);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        return;
    }
    switch (*q) {
    case 1:
    case 3:
        if ((rec[15] & 7) == 5) {
            rec[17] = 0;
            rec[18] = 1;
            rec[19] = q[1];
            rec[20] = q[2];
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        }
        break;
    case 2:
    case 4:
        if ((rec[15] & 7) == 5) {
            rec[17] = q[1];
            rec[18] = q[2];
            rec[19] = 127;
            rec[20] = 1;
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        }
        break;
    case 5:
        switch (rec[15] & 7) {
        case 1:
        case 3:
            rec[17] = q[3];
            rec[18] = q[4];
            rec[19] = 64;
            rec[20] = 135;
            break;
        case 2:
        case 4:
            rec[17] = q[1];
            rec[18] = q[2];
            rec[19] = 64;
            rec[20] = 7;
            break;
        }
        break;
    }
}
/* sub_C_9b stopped at +16: the ROM adds 426 in place, extends, adds the base and copies the sum into the pointer's
   register (XDE), then advances that pointer by the low six bits. */
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;
    p = (unsigned char *)((unsigned int *)(ram_44fce + ((int)((m[2] & 0xc0) >> 6) * 11 + 426)));
    p += m[2] & 0x3f;
    *p = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
/* sub_C_4b stopped at +19: the ROM extends the offset byte twice (`extz bc; extz xbc`: unsigned int, then long)
   where `(unsigned long)m[2]` cleared XBC first; the echo address has the offset evaluated before main RAM's row. */
void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    unsigned char *mm;
    p = *(unsigned char **)(ram_4136e + m[1] * 0x11f);
    p += (unsigned int)m[2];
    *p = m[4];
    mm = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(p, 1, (unsigned int)m[2] + &mm[0x4980]);
}
/* sub_C_4b / sub_C_2a stopped at +0 / +10: main RAM's address was in XHL and the length in DE (ROM: XIX, HL), and
   the product was 8 bits wide in sub_C_2a.  Here the length is declared first. */
void InterCPU_SendEditBufferToMain(unsigned char part)
{
    unsigned int n;
    unsigned char *mm;
    mm = (unsigned char *)0x1e0000;
    n = 470;
    InterCPU_E1_DMA_Transfer(&ram_4531c[(int)part * 80 + 19111], n, mm + (long)((int)part * 80 + 19111));
}
/* sub_C_7a stopped at +32: the destination row (see the head comment). */
void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             ((unsigned int *)(ram_44fce + ((int)c * 11 + 426))),
                             ((unsigned int *)ToneDB_RootPtr)[117]);
}
/* sub_C_8c stopped at +26: the ROM takes the edit buffer's address into XWA and copies it to XBC. */
void VoiceStruct_BulkInit(unsigned char part)
{
    unsigned char k;
    BlockCopy_Words_BC_to_HL(*(unsigned char **)(ram_4136e + part * 0x11f), (unsigned int *)ram_44fce, 0x66);
    for (k = 0; k < 4; k++)
        BlockCopy_Words_BC_to_HL(*(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[k], ((unsigned int *)(ram_44fce + ((int)k * 0x51 + 0x66))), 0x51);
}
/* sub_C_9c stopped at +66: its `(unsigned long)` casts copied the slot row's address (XDE to XHL); the ROM takes
   it straight into XHL.  The slot row and the velocity pair through struct views. */
/* cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    tbl = (struct e16 *)(ToneDB_RelBase + ToneDB_RootPtr[25]);
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3] = tbl[idx].a;
    ((struct b5 *)&((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3])->f1 = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}
/* sub_C_5a's first real difference (behind the jump displacement at +26): the ROM adds the edit-buffer pointer
   from memory to the row offset (`add xhl,(mem)`); ours converted the offset, loaded the pointer and added. */
void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    ram_4531c[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = (unsigned char *)((unsigned long)k * 21) + (int)sel * 80;
        rec += (unsigned long)ram_4531c;
        rec = &rec[19127];
        q = ram_44fce + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
