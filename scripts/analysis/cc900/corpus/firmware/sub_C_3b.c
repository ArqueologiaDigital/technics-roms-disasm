/* lane_sub probe round 3, helper C, form b: other spellings of sub_C_3a.c's functions, plus five tone-generator
   writers whose inline assembly uses a real TAB character (sub_C_3c.c has them with a leading space), for the KN5000
   sub-CPU payload v1.42 (core/08_voice_noteon_and_tonegen.s, core/10_dsp_voice_params.s).  Names are the tree's labels;
   ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   Round 2 showed (run 2026-11-16-47-sub-r2):
   - V4.23 rounds every struct to an even size (a 5-char struct is 6 bytes), so the payload's odd strides (287-byte
     part records, 39-byte algorithm descriptors, 37-byte partials, 5-byte rows) cannot be arrays of structs.  Here
     they are char rows (`unsigned char x[][N]`) or a struct laid over a computed pointer.
   - an explicit `uchar * 80` becomes V4.23's 8-bit `mul`; the ROM's `extz` + `muls` is array-index scaling, so
     the multiplications by 5 / 6 / 37 / 80 / 102 are written as indexing.
   - locals seem to take XIX, XIY, XHL in declaration order (DSP_SetCoeff_CopyDirect). */

extern unsigned int ram_41343;                  /* Voice_GlobalFlags */
extern unsigned char ram_41368[];               /* Part_Record_Base: flags word */
extern unsigned char ram_4136a[];               /* Part_PresentWord */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413c9[];
extern unsigned char ram_413d0[];
extern unsigned char ram_413d1[];
extern unsigned char ram_413d2[];
extern unsigned char ram_413d3[];
extern unsigned char ram_413d4[];
extern unsigned char ram_413d6[];
extern unsigned char ram_413fb[];
extern unsigned char ram_41420[];
extern unsigned char ram_41445[];
extern unsigned char ram_451a4;
extern char ram_451a7;
extern char ram_451a8;
extern char ram_451a9;
extern char ram_451ab;
extern char ram_451ac;
extern unsigned char *ram_45310;
extern long *ram_45314;

struct dspglob { unsigned char pad[426]; unsigned char t11[4][11]; unsigned char pad2[10]; unsigned char t5[4][5];
                 unsigned char t5b[4][5]; };
extern struct dspglob ram_44fce;

struct editbuf { unsigned char pad[19111]; unsigned char rows[16][80]; };
extern struct editbuf *ram_4531c;
struct mainmem { unsigned char pad[0x4980]; unsigned char edit[470]; };
struct patchrec { unsigned char b[1]; };

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct partial { unsigned char pad[54]; unsigned char f54; unsigned char pad2[22]; unsigned char a77[4]; };
struct cache5 { unsigned char key; unsigned char v[4]; };
struct algrec { unsigned char pad[0x13]; unsigned char s[4][5]; };
struct slotrt { unsigned char pad[26]; unsigned int w[8]; };

extern unsigned char DSP_AlgoDescriptor_Records[][0x27];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned int DSP_ChanFreq_CurvePool[][51];

extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, long dst);

#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
#define PART_PRESENT(p) (*(unsigned int *)(ram_4136a + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define PART_PTR(a, p)  (*(unsigned char **)((a) + (p) * 0x11f))

void DSP_SlotParam_Write_Slot0(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d0[part * 0x11f] = ram_451a7 * 2;
    else ram_413d0[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot1(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d1[part * 0x11f] = ram_451a8 * 2;
    else ram_413d1[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot2(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d2[part * 0x11f] = ram_451a9 * 2;
    else ram_413d2[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab * 2;
    else ram_413d3[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d4[part * 0x11f] = ram_451ac * 2;
    else ram_413d4[part * 0x11f] = 0;
}

void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = ch | 0xc0;
        else p->w[slot] = ch | 0x40;
    }
}

void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = (unsigned int)ch | 0xc000;
        else p->w[slot] = (unsigned int)ch | 0x4000;
    }
}

void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = ch | 0x3300;
        else p->w[slot] = ch | 0x1100;
    }
}

void DSP_SetCoeff_CopyDirect(unsigned int k)
{
    unsigned int i;
    unsigned char *src;
    unsigned int n;
    src = ram_45310 + ram_45314[32];
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void DSP_SetCoeff_CopyDirect2(unsigned int k)
{
    unsigned int i;
    unsigned char *src;
    unsigned int n;
    src = ram_45310 + ram_45314[35];
    n = 13;
    for (i = 0; i < n; i++) ((unsigned char *)0x45210)[i + 6] = src[((unsigned long)k << 4) + i];
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *row;
    row = ram_44fce.t11[(m[2] & 0xc0) >> 6];
    row[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) > 10) return;
    return;
}

void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    p = PART_PATCH(m[1]);
    p += m[2];
    *p = m[4];
    InterCPU_E1_DMA_Transfer(p, 1, (long)((unsigned char *)0x1e0000 + 0x4980 + (unsigned long)m[2]));
}

void InterCPU_SendEditBufferToMain(unsigned char part)
{
    struct editbuf *mm = (struct editbuf *)0x1e0000;
    unsigned int n = 470;
    InterCPU_E1_DMA_Transfer(ram_4531c->rows[part], n, (long)mm->rows[part]);
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = PART_PATCH(part)[93] & 0xf;
    r = ((struct algrec *)DSP_AlgoDescriptor_Records[t])->s[slot][1];
    if (t == 8 && slot == 1) r = PART_PATCH(part)[96];
    return r;
}

unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial)
{
    switch (partial) {
    case 0:
        if (PART_PRESENT(part) & 0x4000) return PART_PTR(ram_413fb, part)[1];
        else return PART_PTR(ram_413d6, part)[1];
    case 1:
        if (PART_PRESENT(part) & 0x8000L) return PART_PTR(ram_413d6, part)[1];
        else return PART_PTR(ram_413fb, part)[1];
    case 2:
        return PART_PTR(ram_41420, part)[1];
    case 3:
        return PART_PTR(ram_41445, part)[1];
    }
}

void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char sel;
    unsigned int r;
    t = PART_PATCH(part)[93] & 0xf;
    if (t == 7 || t == 6) {
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = DSP_ChanFreq_CurvePool[sel][PART_PATCH(part)[95]];
    } else r = 0;
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    struct partial *rec;
    struct cache5 *q;
    unsigned int i;
    rec = *(struct partial **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = (struct cache5 *)ram_44fce.t5[slot];
    if ((rec->f54 & 7) == q->key) {
        for (i = 0; i < 4; i++) q->v[i] = rec->a77[i];
    }
}

void Voice_NoteState_Clear(unsigned char part)
{
    unsigned int i;
    unsigned int j;
    if (ram_41343 & 1) return;
    *(unsigned int *)(ram_41385 + part * 0x11f) = 0;
    ram_41387[part * 0x11f] = 0;
    ram_41388[part * 0x11f] = 0;
    ram_41383[part * 0x11f] = 0x40;
    ram_41384[part * 0x11f] = 0x40;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 3; j++) {
            (*(unsigned char (*)[3][4][4])(ram_41368 + part * 0x11f + 41))[j][i][0] = 0;
            (*(unsigned char (*)[3][4][4])(ram_41368 + part * 0x11f + 41))[j][i][1] = 0;
        }
    }
}

/* Tone-generator writers (see sub_C_3c.c): the inline-assembly strings hold a real TAB character, and the `jr` to the
   next instruction is written as its two bytes. */
extern unsigned char __tiny ram_18;            /* P6 */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
#define TG_WAIT2 __ASM("	db	0x68,0x00"); __ASM("	nop"); __ASM("	nop"); __ASM("	nop")
#define TG_WRITE(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("	nop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT2

void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v)
{
    TG_WRITE(reg, v);
}

void ToneGen_WriteExtParam_600_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x580, 0x8100);
}

void ToneGen_WriteExtParam_540_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x540, 0x8100);
}

void ToneGen_Mute_Reg05C0(unsigned int reg)
{
    TG_WRITE(reg + 0x5c0, 0x8100);
}

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
void TG_WriteExtParam_Mute_TypeDisp(unsigned int reg)
{
    if (reg < 0x40) {
        TG_WRITE(reg + 0x540, 0x8100);
    } else {
        TG_WRITE(reg + 0x580, 0x8100);
    }
}
