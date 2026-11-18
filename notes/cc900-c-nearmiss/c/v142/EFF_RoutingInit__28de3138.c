/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AI_21a.c (2026-11-18-19-sub-r21b-staged)
   sha256 28de3138f83f8ba5dc56f6b6558142886ccd9667bf1bc62fdaa02e6a4566ee82 (tar-sha256); compiled at -Xr */
/* lane_sub round 21: sub_AI_20a.c without ToneGen_ReadPitch_AndScale, whose __IZ crashed V4.23 and lost the whole file in run 2026-11-18-18-sub-r21a (bug candidate 12) */
/* sub_AI_20a.c -- lane_sub helper AI, round 20, form a (KN5000 sub-CPU payload v1.42; core/08_voice_noteon_and_tonegen.s
   and core/10_dsp_voice_params.s).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).
   None of these functions was compiled before.  Every call here is an absolute `call` in the ROM except
   EFF_RoutingInit's four calr callees (the module lines below; nothing else here calls them).
   ToneGen_ReadPitch_AndScale uses __IZ (syntax_check.sh flags every __IZ file as BAD: gcc does not know the
   pseudo-register; checked instead with -D'__IZ=(*(unsigned int *)0)').  CheckStatusBits_Zero (no caller, not in
   any pool: survey.tsv counts its bytes in ToneGen_ReadPitch_AndScale's extent) is CheckStatusBits_40's form.

   Form a: the plain spelling.
   - VoiceAlloc_Apply_Algo_Group0/1/2: AudioChannel_Handler_Cmd04_07's matched else-branch shape (helper AD,
     round 20): `i = list[j]; i &= 0xff;` gives `ld iz,(xwa); ld IZH,0`.  The ROM's EFF_RoutingInit loop counter
     is a byte in QIZH, so it is its own unsigned char k here.  Group0 keeps j on the stack, Group1/2 in QIZ:
     the three forms try three declaration orders / scopes for the same three functions (a: list, j, k, i).
   - DSP_VoiceParam_Dispatch / DSP_SetVoiceCoefficients: DSP_RouteCoeffs_TypeA's matched switch shape
     (dsp_algo_select.c); switch compares in reverse source order (idiom t).
   - RoutingFlag_Encode: SlotRouting_* (dsp_voice_params.c) inlined under a switch on the slot; stack
     parameters pushed left to right (idiom h): slot at +14, ch at +12.
   - DSP_VoiceParamReadWrite: long multiplies (Math_Multiply32) and `ld xR, sym` (pointer + long) as in
     sub_R_17a's listing; the returned local is never set in the ROM either. */

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_44fce[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern unsigned char *ram_45310;
struct tdbr { char pad[76]; unsigned long o76; char p2[44]; unsigned long o124; unsigned long o128; char p3[8];
              unsigned long o140; char p4[32]; unsigned long o176; };
extern struct tdbr *ram_45314;
extern unsigned char *ram_4531c;
extern unsigned char ram_45210[];
extern unsigned char ram_4136a[];
extern unsigned char ram_41372[];
extern unsigned char ram_413ee[];
extern unsigned char ram_41413[];
extern unsigned char ram_41438[];
extern unsigned char ram_4145d[];
extern unsigned char ram_430bb[];
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };
extern unsigned int VoiceChanScan_SlotEnableMask[];
extern unsigned int SlotEnableMaskA[];
extern unsigned int SlotEnableMaskB[];
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_15(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Banked(int, unsigned int *);
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define PART_PRESENT(p) (*(unsigned int *)(ram_4136a + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41372 + (p) * 0x11f))
#define PART_WORD(a, p) (*(unsigned int *)((a) + (p) * 0x11f))

/* cc900-module: RoutingFlag_Encode */
/* cc900-module: SlotRouting_WriteSingle */
/* cc900-module: SlotRouting_Chan1 */
/* cc900-module: SlotRouting_Chan3 */

void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;

    AlgoFlag_Write(part, 0, slot);
    AlgoFlag_Write_Bit3(part, 0, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 0);
    list = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
        ram_4520c = EGEnv_Compute_A((unsigned char)i);
        ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
        ToneGen_WriteExtParams_56(i, ram_451cc);
    }
}

void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;

    AlgoFlag_Write(part, 1, slot);
    AlgoFlag_Write_Bit3(part, 1, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 1);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 0);
    for (j = 0; (list[j] & 0xff) < 0x40; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
        ram_45204 = EGEnv_Compute_B((unsigned char)i);
        ram_45206 = EGEnv_Compute_B_Simple((unsigned char)i);
        ToneGen_WriteExtParams_15(i, ram_451cc);
    }
}

void VoiceAlloc_Apply_Algo_Group2(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;

    AlgoFlag_Write(part, 2, slot);
    AlgoFlag_Write_Bit3(part, 2, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 2);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
        Voice_Freq_WriteLeft((unsigned char)i);
        Voice_Freq_WriteRight((unsigned char)i);
        ToneGen_WriteExtParams_15_Banked(i, ram_451cc);
    }
}

unsigned int DSP_VoiceParam_Dispatch(unsigned int a, unsigned int b, unsigned char *d)
{
    unsigned char *s;
    unsigned int h;
    unsigned int row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int n, i;

    switch (b & 0x20) {
    case 0:
        a &= 0x7f;
        h = b & 0x1f;
        switch (b & 0xc0) {
        case 0:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ram_45314->o124;
            break;
        }
        row = *(unsigned long *)(((h << 7) + a) * 2 + off + ram_45310);
        off = ram_45314->o128;
        t = (unsigned char (*)[16])(ram_45310 + off);
        s = t[row];
        break;
    case 0x20:
        s = ToneDB_Find_ToneRecord(a, b);
        break;
    }
    n = 13;
    for (i = 0; i < n; i++) *d++ = s[i];
    return n;
}

void DSP_SetVoiceCoefficients(unsigned char part, unsigned char sel, unsigned char *out)
{
    unsigned char *s = 0;
    unsigned long off = 0;
    unsigned char *rec;
    unsigned int a, b, h, row, n, i;

    rec = ToneDB_Find_ToneRecord(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
    a = rec[sel * 2 + 0x27];
    b = (&rec[sel * 2 + 0x27])[1];
    switch (b & 0x20) {
    case 0:
        a &= 0x7f;
        h = b & 0x1f;
        switch (b & 0xc0) {
        case 0:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ram_45314->o124;
            break;
        }
        row = *(unsigned long *)(((h << 7) + a) * 2 + off + ram_45310);
        off = ram_45314->o176;
        s = ram_45310 + off;
        s += (unsigned long)row * 10;
        break;
    case 0x20:
        s = ToneDB_Find_SubToneRecord(rec, sel, 0xff);
        break;
    }
    n = 10;
    for (i = 0; i < n; i++) *out++ = *s++;
}

unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char w;
    unsigned char b;

    if (ram_41382[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & PART_PATCH(part)[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & PART_PATCH(part)[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}

void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch)
{
    if (SlotEnableMaskA[e] & q[1]) {
        if (SlotEnableMaskB[e] & q[1]) {
            switch (slot) {
            case 0:
                p->w[slot] = (unsigned int)ch | 0xc0;
                break;
            case 1:
                p->w[slot] = ch | 0xc000;
                break;
            case 2:
                p->w[slot] = ch | 0x3300;
                break;
            }
        } else {
            switch (slot) {
            case 0:
                p->w[slot] = (unsigned int)ch | 0x40;
                break;
            case 1:
                p->w[slot] = ch | 0x4000;
                break;
            case 2:
                p->w[slot] = ch | 0x1100;
                break;
            }
        }
    }
}

int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out)
{
    int r;
    unsigned int k;
    unsigned int cnt;

    cnt = 0;
    if (*(unsigned int *)(ram_41368 + (unsigned long)part * 0x11f) & 1) {
        *out = ram_44fce[(unsigned long)idx + 0x1d8];
    } else {
        for (k = 0; k < 4; k++) {
            if (((*(unsigned char **)(ram_41368 + (unsigned long)part * 0x11f + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0
                && ((*(unsigned char **)(ram_41368 + (unsigned long)part * 0x11f + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20) == 0)
                cnt++;
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}

void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp)
{
    struct slotrt *p;
    unsigned char *q;
    unsigned char k;

    p = (struct slotrt *)((ram_41368 + part * 287) + (slot * 37 + 0x6e));
    p->w[grp] = 0;
    for (k = 0; k < 4; k++) {
        q = (ram_41368 + part * 287 + (grp * 16 + k * 4)) + 39;
        if (*q & 0x0a) {
            RoutingFlag_Encode(p, q, slot, grp, k);
        } else if (*q & 5) {
            switch (grp) {
            case 0:
                SlotRouting_WriteSingle(p, grp, k, (*(unsigned char **)((ram_41368 + part * 287) + (slot * 37 + 0x6e)))[6]);
                break;
            case 1:
                SlotRouting_Chan1(p, grp, k, (*(unsigned char **)((ram_41368 + part * 287) + (slot * 37 + 0x6e)))[38]);
                break;
            case 2:
                SlotRouting_Chan3(p, grp, k, (*(unsigned char **)((ram_41368 + part * 287) + (slot * 37 + 0x6e)))[56]);
                break;
            }
        }
    }
}

void DSP_SetCoeff_RouteComplex(unsigned char part, unsigned char sel)
{
    unsigned char *rec;
    unsigned int a, h, f, row, n, i;
    unsigned long off;
    unsigned char (*t)[16];

    rec = PART_PATCH(part);
    a = rec[sel * 2 + 39] & 0x7f;
    h = (&rec[sel * 2 + 39])[1] & 0x1f;
    f = (&rec[sel * 2 + 39])[1] & 0x20;
    off = ram_45314->o124;
    row = *(unsigned long *)(((h << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o128;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    switch (f) {
    case 0:
        for (i = 0; i < n; i++) ram_45210[i + 6] = t[row][i];
        break;
    case 0x20:
        for (i = 0; i < n; i++) ram_45210[i + 6] = (ram_4531c + (sel * 80 + 19111))[i];
        break;
    }
    ram_45210[n + 6] = t[row][13];
    n++;
    ram_45210[n + 6] = row & 0xff;
    n++;
    ram_45210[n + 6] = row >> 8;
    n++;
}

void DSP_SetCoeff_RouteWithCallback(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *r;
    unsigned int a, h, row, n, i;
    unsigned long off;
    unsigned char (*t)[16];

    e &= 0x0f;
    r = ToneDB_Find_SubToneRecord(PART_PATCH(part), c, part);
    r += e * 21 + 16;
    a = r[1] & 0x7f;
    h = r[2] & 0x0f;
    switch (r[2] & 0xc0) {
    case 0:
    case 0x40:
    case 0x80:
    case 0xc0:
        off = ram_45314->o76;
        break;
    }
    row = *(unsigned long *)(((h << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o140;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++) ram_45210[i + 6] = t[row][i];
    ram_45210[n + 6] = t[row][13];
    n++;
    ram_45210[n + 6] = row & 0xff;
    n++;
    ram_45210[n + 6] = row >> 8;
    n++;
}

void Partial_Build_Present_Word(unsigned char part)
{
    unsigned int w;
    unsigned char l;

    w = PART_PRESENT(part) & 0xffff3ff0;
    l = PART_PATCH(part)[18];
    if (PART_PATCH(part)[17] & 1) w |= 1;
    else if (PART_W72(part) & 0x8000L) {
        if (PART_PATCH(part)[17] & 4) {
            switch (PART_PATCH(part)[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x4001;
            }
        }
    }
    if ((l & 3) == 1) PART_WORD(ram_413ee, part) |= 0x8000;
    else PART_WORD(ram_413ee, part) &= 0x7fff;
    if (PART_PATCH(part)[17] & 4) w |= 2;
    else if (PART_W72(part) & 0x8000L) {
        if (PART_PATCH(part)[17] & 1) {
            switch (PART_PATCH(part)[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x8002;
            }
        }
    }
    if ((l & 0xc) == 4) PART_WORD(ram_41413, part) |= 0x8000;
    else PART_WORD(ram_41413, part) &= 0x7fff;
    if (PART_PATCH(part)[17] & 0x10) w |= 4;
    if ((l & 0x30) == 0x10) PART_WORD(ram_41438, part) |= 0x8000;
    else PART_WORD(ram_41438, part) &= 0x7fff;
    if (PART_PATCH(part)[17] & 0x40) w |= 8;
    if ((l & 0xc0) == 0x40) PART_WORD(ram_4145d, part) |= 0x8000;
    else PART_WORD(ram_4145d, part) &= 0x7fff;
    PART_PRESENT(part) = w;
}


int CheckStatusBits_Zero(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0;
}
