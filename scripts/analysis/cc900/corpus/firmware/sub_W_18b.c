/* sub_W_18b.c -- lane_sub helper W, round 18, form b (KN5000 sub-CPU payload v1.42; core/08_voice_noteon_and_tonegen.s
   and core/10_dsp_voice_params.s, pool C).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).
   ram_45310 / ram_45314 are ToneDB_RelBase / ToneDB_RootPtr seen as byte pointers (the spelling that matched in
   v142/subcpu/cc900/voice_noteon_and_tonegen_c_12b.c).

   Part 1: the functions round 17 left open with a sub_R_17* best attempt; each comment names the remaining
   difference of that attempt (read with an instruction-level diff) and what this form changes.
   Part 2: new functions (jump-table dispatch heads with their arms, AlgoFlag_Write / _Bit3,
   ToneDB_Resolve_NamedToneRecord).

   The functions and comments are form a's; what this form changes against form a:
   - the ChanFreq packets are void again and r first holds the doubled index (`r = byte; r += r;`);
   - DispatchB: `r = part; r += part;`; Fetch2 and Packet1: the descriptor columns as [][39] arrays;
   - DSP_WriteVoiceParam: `pointer + (unsigned long)off`; SelectTables: `m * (unsigned long)(unsigned int)word`;
   - the ToneDB walks with an unsigned long directory variable (still the returned one), `b * 4`;
   - Read_To_Cache_B: `&ram_4531c[..]` then `rec = &rec[19127]`; DSPGlobal_Param_Store: the row as a byte pointer;
   - PatchByte_Write_And_Echo: one parameter, mm declared before p; SendEditBufferToMain: one parameter and the
     source through an unsigned long local (unprototyped callee in this file);
   - BulkInit: s declared first, PATCH(); Catalog64: the directory through a local declared last;
   - CustomTone_Select / Resolve_NamedToneRecord: the pointer sum in two statements;
   - Second_A without the empty cases 8 / 9; AlgoFlag_Write: the entry address through `(unsigned long) + 39`,
     one `&&` test; Resolve_NamedToneRecord: `switch (b & 0x20)`, the product in one expression. */

/* cc900-module: BlockCopy_Words_BC_to_HL */
/* cc900-module: DSP_ParamWrite_BlockCopy */
/* cc900-module: DSP_EffParam_Copy_V0 */
/* cc900-module: DSP_EffParam_Copy_V1 */
/* cc900-module: DSP_EffParam_Copy_V2 */
/* cc900-module: DSP_EffParam_Copy_V3 */
/* cc900-module: DSP_EffParam_Copy_V4 */
/* cc900-module: DSP_EffParam_Copy_V5 */
/* cc900-module: DSP_EffParam_Copy_V6 */
/* cc900-module: DSP_EffParam_Copy_V7 */
/* cc900-data: Algo_SubTable_DispatchB 1 = Algo_SubTable_DispatchB_CaseOffsets */
/* cc900-data: Voice_DSPOut_Apply_A 1 = VOICE_DSPOUT_A_JUMPTABLE */
/* cc900-data: Voice_DSPOut_Apply_B 1 = VOICE_DSPOUT_B_JUMPTABLE */
/* cc900-data: Voice_DSPOut_Second_A 1 = VOICE_DSPOUT_SECOND_A_JUMPTABLE */
/* cc900-data: DSP_EffParam_Apply_By_AlgoType 1 = DSP_EFFPARAM_APPLY_JUMPTABLE */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_413c7[];
extern unsigned char ram_413c9[];
extern unsigned char ram_44fce[];               /* the tone edit buffer */
extern unsigned char *ram_45310;                /* ToneDB_RelBase as a byte pointer */
extern unsigned char *ram_45314;                /* ToneDB_RootPtr as a byte pointer */
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoDescriptor_SelIdx[][39];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[][39];
extern unsigned char DSP_AlgoDescriptor_ValueAB[][39];
extern unsigned char DSP_AlgoChannel_SelectorByte4[][6];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_Packet1_Curve[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern int EGEnv_ModeBits_Table[];

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
#define PREC(p) ((struct partrec *)(ram_41368 + (p) * 0x11f))
#define SLOT(p, s) ((struct slotrec *)PREC(p)->partial[s])
#define AREC(t) ((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))
#define AENT(t, k) ((struct b5 *)((unsigned long)&AREC(t)->b[(int)(k) * 5 + 0x13]))
#define EDIT_AT(i) (&ram_44fce[(int)(unsigned int)(i)])
#define EDIT_W(i) ((unsigned int *)&ram_44fce[(int)(unsigned int)(i)])

extern void InterCPU_E1_DMA_Transfer();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern void WaveSel_Cache_SetDescPtr();
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
extern void Voice_DSP_OutputConfig(unsigned int part, unsigned int slot);
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);
extern void Voice_DSP_SimpleCopy(unsigned int part);
extern void Voice_DSP_SimpleCopy2(unsigned int part);
extern void DSP_EffParam_Copy_V0(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V1(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V2(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V3(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V4(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V5(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V6(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V7(unsigned int part, unsigned int d);

/* ================= Part 1: round 17's open functions ================= */

/* sub_R_17a/b/c: the whole body matched except the result word's register: ours DE, the ROM HL (the index is
   doubled in HL and the word is loaded over it).  Here the function returns r. */
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned int r;
    unsigned char sel;
    unsigned char t;

    t = PATCH(part)[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = PATCH(part)[95];
        r += r;
        r = *(unsigned int *)((DSP_ChanFreq_CurvePool + (int)sel * 0x66) + (int)r);
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}

/* sub_R_17b: the same register (DE for HL), and `t * 0x27` was multiplied in 8 bits (the ROM extends, then
   multiplies in 16).  Returns r; the index through (int). */
void DSP_ChanFreq_WritePacket1(unsigned char part)
{
    unsigned int r;
    unsigned char t;
    unsigned char sel;

    t = PATCH(part)[93] & 0xf;
    switch (t) {
    case 6:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = PATCH(part)[94];
        r += r;
        r = *(unsigned int *)((DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66) + (int)r);
        r |= EGEnv_ModeBits_Table[PATCH(part)[96]];
        break;
    case 7:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = DSP_AlgoDescriptor_SelIdx[t][0];
        r += r;
        r = *(unsigned int *)((DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66) + (int)r);
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c7 + part * 0x11f) = r;
}

/* sub_R_17c: only the arms differ: the ROM loads the byte into A, copies it to L and adds A (ours loaded L and
   shifted it).  Here the byte goes through the dead parameter and is added to itself. */
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = PATCH(part)[93] & 0xf;
    r = AENT(t, k)->f2;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1) {
            part = PATCH(part)[96];
            r = part;
            r += part;
        }
        break;
    case 4: case 5:
        if (k == 1) {
            part = PATCH(part)[98];
            r = part;
            r += part;
        }
        break;
    case 8:
        if (k == 1) {
            part = PATCH(part)[95];
            r = part;
            r += part;
        }
        break;
    }
    return r;
}

/* sub_R_17b: only the two `r * 0x27` indexes differ (8-bit multiply; the ROM extends first). */
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    unsigned char t;

    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    t = PATCH(part)[93] & 0xf;
    r = t;
    switch (t) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[r][0] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[r][0];
        else
            r = PATCH(part)[100];
        break;
    default:
        r = PATCH(part)[100];
        break;
    }
    return r;
}

/* sub_R_17a/c: the ROM loads the patch pointer into XBC, then extends the offset in XWA and adds; ours extended
   the offset in XBC and added the pointer from memory, whichever operand came first.  Here the pointer is
   converted to a number before the add. */
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                     + (unsigned long)off, buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                     + (unsigned long)off, buf);
        return n;
    case 0xc0:
        return 0;
    }
}

/* sub_R_17b: only the tail differs: the ROM has the row size in BC, multiplies XBC by the looked-up word in WA
   and adds the offset in XBC; ours moved the word to BC and multiplied in XWA.  Here the looked-up word is the
   left operand. */
unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel)
{
    unsigned int m;
    unsigned long off;
    unsigned long base;

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
    b = ((b << 7) + a) * 2;
    return (unsigned char *)(m * (unsigned long)(unsigned int)*(unsigned long *)((unsigned long)b + base + ToneDB_RelBase)
                             + off) + ToneDB_RelBase;
}

/* sub_R_17a (closest): the ROM copies the bank number to DE and extends it there, loads directory 27 into XBC
   and adds; keeps the directory in XHL (ours XDE); scales the record number in a copy (`ld wa,bc; sll 2,wa`;
   ours shifted BC in place); builds the result in XWA and moves it to XHL.  Here the directory is a byte pointer
   indexed by the unsigned ints, and it is the returned variable. */
unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b)
{
    unsigned long p;

    b = *((unsigned char *)ToneDB_RootPtr[27] + b + ToneDB_RelBase);
    p = ToneDB_RootPtr[27] + 0x80;
    b = (b << 7) + a;
    b += b;
    b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
    p = ToneDB_RootPtr[2];
    p = *(unsigned long *)((unsigned long)(b * 4) + p + ToneDB_RelBase);
    p = ToneDB_RelBase + p;
    return (unsigned char *)p;
}

/* sub_R_17c: the same three differences in the directory walk, and the ROM leaves every branch by a jump to one
   `ret` (ours returned in place): one result variable, an if / else chain, one return. */
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned long p;

    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        b = *((unsigned char *)ToneDB_RootPtr[1] + b + ToneDB_RelBase);
        p = ToneDB_RootPtr[1] + 0x80;
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
        p = ToneDB_RootPtr[2];
        p = *(unsigned long *)((unsigned long)(b * 4) + p + ToneDB_RelBase);
        p = ToneDB_RelBase + p;
    } else if (b == 0x10)
        p = (unsigned long)(((unsigned long)a * 0x1d6 + 0x10) + ram_4531c);
    else if (b == 0x15)
        p = (unsigned long)(((unsigned long)a * 0x1d6 + 0x10) + ram_45318);
    else if (b == 0x50)
        p = (unsigned long)&ram_4531c[18816];
    else if (b == 0x55)
        p = (unsigned long)(((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318);
    else {
        p = ToneDB_RootPtr[2];
        p = *(unsigned long *)(ToneDB_RelBase + p);
        p = ToneDB_RelBase + p;
    }
    return (unsigned char *)p;
}

/* sub_R_17a: only the record address differs: ours built the sum in XWA and added 19127 into XDE; the ROM puts
   the sum in XDE and adds 19127 there: two statements. */
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;

    rec = &ram_4531c[(int)ram_4531c[29351] * 80 + (int)slot * 21];
    rec = &rec[19127];
    q = EDIT_AT((int)slot * 5 + 500);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

/* sub_R_17a / 17c: form a had the right statements but its row address was folded into the symbol; form c had the
   right row address but indexed the store.  Here form a's statements on form c's row address. */
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;

    p = EDIT_AT((int)((m[2] & 0xc0) >> 6) * 11 + 426);
    p += m[2] & 0x3f;
    *p = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

/* sub_R_17a/c: the ROM has the patch pointer in XHL and main RAM's base in XDE (ours the reverse), extends the
   offset into XBC by a copy, then takes base + 0x4980 through XWA into XDE and adds the offset; ours folded
   0x4980 into the offset.  Here two unused parameters (BC, DE: is DE then kept from the locals?), and the offset
   as a long added to the row address. */
void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *mm;
    unsigned char *p;

    p = *(unsigned char **)(ram_4136e + m[1] * 0x11f);
    p += (unsigned int)m[2];
    *p = m[4];
    mm = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(p, 1, (mm + 0x4980) + (unsigned long)(unsigned int)m[2]);
}

/* sub_R_17a/b/c: the ROM has main RAM's base in XIX and the length in HL, and uses DE for the index and to hold
   the source address (ours: XHL, DE, and IX as the scratch).  Here two unused parameters, as above. */
void InterCPU_SendEditBufferToMain(unsigned char part)
{
    unsigned long s;
    unsigned int n;
    unsigned char *mm;

    mm = (unsigned char *)0x1e0000;
    n = 470;
    s = (unsigned long)&ram_4531c[(int)part * 80 + 19111];
    InterCPU_E1_DMA_Transfer(s, n, (long)((int)part * 80 + 19111) + mm);
}

/* sub_R_17a/c: the ROM loads each source pointer into XDE BEFORE it builds the destination (ours kept the index
   and loaded the pointer after).  Here the source goes through a local. */
void VoiceStruct_BulkInit(unsigned char part)
{
    unsigned char *s;
    unsigned char k;

    s = PATCH(part);
    BlockCopy_Words_BC_to_HL(s, (unsigned int *)ram_44fce, 0x66);
    for (k = 0; k < 4; k++) {
        s = *(unsigned char **)PREC(part)->partial[k];
        BlockCopy_Words_BC_to_HL(s, EDIT_W((int)k * 0x51 + 0x66), 0x51);
    }
}

/* sub_R_17c: one difference: the ROM loads directory 25 into XHL, then the base into XIX and adds the register;
   ours added the directory from memory.  Here the spelling of the Apply_Catalog94 / 80 siblings that match. */
/* cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    unsigned long off;

    off = ToneDB_RootPtr[25];
    tbl = (struct e16 *)(ToneDB_RelBase + off);
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    SLOT(part, lo)->vel[(int)hi * 2 + 3] = tbl[idx].a;
    *(unsigned char *)((unsigned long)&SLOT(part, lo)->vel[(int)hi * 2 + 3] + 1) = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}

/* sub_R_17a/c: one difference: the ROM adds the edit-buffer pointer from memory (`add xhl,(mem)`); ours loaded
   it into XWA first.  Here the pointer is the right operand of a number + pointer sum, the spelling that gives
   `add xhl,(mem)` in ToneDB_Find_PatchRecord. */
void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;

    ram_4531c[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = (unsigned char *)((unsigned long)k * 21) + (int)sel * 80;
        rec = (unsigned long)rec + ram_4531c;
        rec += 19127;
        q = ram_44fce + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}

/* ================= Part 2: new functions ================= */

/* new: head + the four arms Voice_DSPOut_A_Type0To3 / Type4To5 / Type6 / Type7 (the part is kept at (xsp)). */
void Voice_DSPOut_Apply_A(unsigned char part)
{
    switch (PATCH(part)[93] & 0xf) {
    case 0: case 1: case 2: case 3:
        Voice_DSP_OutputConfig(part, 0);
        Voice_DSP_OutputConfig(part, 1);
        break;
    case 4: case 5:
        Voice_DSP_OutputConfig(part, 0);
        break;
    case 6:
        Voice_DSP_SimpleCopy(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x4000)
            Voice_DSP_OutputConfig(part, 0);
        break;
    }
}

/* new: the second bank's twin; type 7 also copies. */
void Voice_DSPOut_Apply_B(unsigned char part)
{
    switch (PATCH(part)[93] & 0xf) {
    case 0: case 1: case 2: case 3:
        Voice_DSP_OutputConfig2(part, 0);
        Voice_DSP_OutputConfig2(part, 1);
        break;
    case 4: case 5:
        Voice_DSP_OutputConfig2(part, 0);
        break;
    case 6:
        Voice_DSP_SimpleCopy2(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x4000) {
            Voice_DSP_OutputConfig2(part, 0);
            Voice_DSP_SimpleCopy2(part);
        }
        break;
    }
}

/* new: types 4..11 (the ROM subtracts 4 and tests 0..7); arms Slot1, Simple, Gated, Slot0, None in that order,
   every call a tail jump. */
void Voice_DSPOut_Second_A(unsigned char part)
{
    switch (PATCH(part)[93] & 0xf) {
    case 4: case 5:
        Voice_DSP_OutputConfig(part, 1);
        break;
    case 6:
        Voice_DSP_SimpleCopy(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x4000)
            Voice_DSP_OutputConfig(part, 1);
        break;
    case 10: case 11:
        Voice_DSP_OutputConfig(part, 0);
        break;
    }
}

/* new: twelve arms, each a tail jump (jrl) to a copy routine of the module with the type as descriptor index. */
void DSP_EffParam_Apply_By_AlgoType(unsigned char part)
{
    switch (PATCH(part)[93] & 0xf) {
    case 0: DSP_EffParam_Copy_V0(part, 0); break;
    case 1: DSP_EffParam_Copy_V0(part, 1); break;
    case 2: DSP_EffParam_Copy_V0(part, 2); break;
    case 3: DSP_EffParam_Copy_V0(part, 3); break;
    case 4: DSP_EffParam_Copy_V1(part, 4); break;
    case 5: DSP_EffParam_Copy_V1(part, 5); break;
    case 6: DSP_EffParam_Copy_V2(part, 6); break;
    case 7: DSP_EffParam_Copy_V3(part, 7); break;
    case 8: DSP_EffParam_Copy_V4(part, 8); break;
    case 9: DSP_EffParam_Copy_V5(part, 9); break;
    case 10: DSP_EffParam_Copy_V6(part, 10); break;
    case 11: DSP_EffParam_Copy_V7(part, 11); break;
    }
}

/* new: the routing flag byte of (group c, unit e) is at +39 + 16 c + 4 e of the part record; bits 0 / 1 are
   rebuilt from the four partials' routing bytes (+6, +38 or +56 of the tone record by group).  The ROM also loads
   the patch pointer and never uses it (p). */
void AlgoFlag_Write(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *p;
    unsigned char w;
    unsigned char b;

    q = (unsigned char *)((unsigned long)&((unsigned char *)PREC(part))[(int)c * 16 + (int)e * 4] + 39);
    p = PATCH(part);
    *q &= 0xfc;
    if (q[3] != 0 && (q[1] & 0x55)) {
        *q |= 2;
    } else {
        for (w = 0; w < 4; w++) {
            switch (c) {
            case 0:
                b = (*(unsigned char **)PREC(part)->partial[w])[6];
                break;
            case 1:
                b = (*(unsigned char **)PREC(part)->partial[w])[38];
                break;
            case 2:
                b = (*(unsigned char **)PREC(part)->partial[w])[56];
                break;
            }
            if ((b & 0x20) && ((b & 0xc0) >> 6) == e)
                *q |= 1;
        }
    }
}

/* new: the twin for bits 2 / 3 (tests byte 2 of the flag entry). */
void AlgoFlag_Write_Bit3(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *p;
    unsigned char w;
    unsigned char b;

    q = (unsigned char *)((unsigned long)&((unsigned char *)PREC(part))[(int)c * 16 + (int)e * 4] + 39);
    p = PATCH(part);
    *q &= 0xf3;
    if (q[2] != 0 && (q[1] & 0x55)) {
        *q |= 8;
    } else {
        for (w = 0; w < 4; w++) {
            switch (c) {
            case 0:
                b = (*(unsigned char **)PREC(part)->partial[w])[6];
                break;
            case 1:
                b = (*(unsigned char **)PREC(part)->partial[w])[38];
                break;
            case 2:
                b = (*(unsigned char **)PREC(part)->partial[w])[56];
                break;
            }
            if ((b & 0x20) && ((b & 0xc0) >> 6) == e)
                *q |= 4;
        }
    }
}

/* new: bank bit 5 clear: the factory record through directories 29 / 30 and the row size at word 119 of the root;
   bit 5 set: the user edit buffer's row, or the kit buffer's when the part's patch pointer is above &ram_45318
   and part is not 0xff.  part is the stack parameter. */
unsigned char *ToneDB_Resolve_NamedToneRecord(unsigned int a, unsigned int b, unsigned char e, unsigned char part)
{
    unsigned char *r;
    unsigned int lo;
    unsigned int hi;
    unsigned long base;
    unsigned long off;
    unsigned int m;

    lo = a & 0x7f;
    hi = b & 0x1f;
    switch (b & 0x20) {
    case 0:
        base = ToneDB_RootPtr[29];
        off = ToneDB_RootPtr[30];
        m = ((unsigned int *)ToneDB_RootPtr)[119];
        r = (unsigned char *)((unsigned long)m
                              * (unsigned int)*(unsigned long *)((unsigned long)(((hi << 7) + lo) * 2) + base + ToneDB_RelBase)
                              + off + ToneDB_RelBase);
        break;
    case 0x20:
        if (PATCH(part) < (unsigned char *)&ram_45318 || part == 0xff) {
            r = ram_4531c + ((int)e * 80 + 19111);
        } else {
            r = (unsigned char *)((unsigned long)(unsigned int)ram_41381[part * 0x11f] * 0x2927) + (int)e * 80;
            r = (unsigned long)r + ram_45318;
            r += 19111;
        }
        break;
    }
    return r;
}
