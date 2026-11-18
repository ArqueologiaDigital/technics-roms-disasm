/* sub_AI_22a.c -- lane_sub helper AI, round 21 (files numbered 22), form a (KN5000 sub-CPU payload v1.42;
   core/08_voice_noteon_and_tonegen.s and core/10_dsp_voice_params.s).  Names are the tree's labels; ram_<hex> is a
   RAM cell (sub-CPU address).  No __IZ / __XIZ anywhere (V4.23 page fault, bug candidate 12).
   Every call is an absolute `call` except EFF_RoutingInit's four calr callees (module lines; nothing else here
   calls them).

   What run 2026-11-18-19-sub-r21b-staged showed (sub_AI_21*), and what this form changes:
   - V4.23 narrowed `sel * 2 + 39`, `slot * 37 + 0x6e`, `grp * 16 + k * 4`, `sel * 80` and `byte & K` to 8 bits;
     the ROM extends first: every such product now has an `(int)` operand, and the masked bytes are
     `x = byte; x &= K;` on an unsigned int (the matched DSP_VoiceCoeffRoute2 spelling, dsp_algo_select_t_18c.c);
   - `(&rec[i])[1]` was folded into `rec[i + 1]`; the ROM keeps +1 as a displacement:
     `*(unsigned char *)((unsigned long)&rec[i] + 1)` (DSP_VoiceCoeffRoute2);
   - pointer locals the ROM keeps in XIZ were put on the stack: `register` (as the matched
     dsp_control_routines_fp_20d.c);
   - the row tail `(unsigned char)(d & 0xff)` / `(unsigned char)(d >> 8)` and `((struct r16 *)...)->b[13]` are
     DSP_VoiceCoeffRoute2's (the ROM's bytes from `ld hl,13` on are the same there);
   - EFF_RoutingInit: record rows as `&((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f))[...]`
     (DSP_VoiceCoeffRoute2's), the +39 as `(unsigned long)&... + 39`;
   - DSP_VoiceParamReadWrite: V4.23 merged the two bit tests into one `and a,0xe0`; nested ifs here, and the
     part row as `(unsigned long)(ram + part * 287L) + slot term` so the base is added before the slot offset;
   - DSP_VoiceParam_Dispatch: the ROM's row is in BC: the dead parameter b holds it; the table base is
     `off = ToneDB_RelBase + off;` (ROM: computed in XWA, moved to off's XDE);
   - VoiceAlloc_Apply_Algo_Group2: ToneGen_WriteExtParams_15_Banked has 32 characters: short C name.
   - DSP_SetCoeff_RouteWithCallback: helper AF's sub_AF_21d/e are the base; this form adds DSP_VoiceCoeffRoute2's
     own `tbl = (unsigned char *)t;` before the loop (AF's forms index t directly).
   - Audio_Cmd_ToneEdit_Field_Write_And_Reply: new.  WaveSel_StageA1_FromToneSlot is void in its built C (a tail
     call), but this caller uses XHL after it: declared here as returning the pointer. */

struct r16 { unsigned char b[16]; };
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_44fce[];
extern unsigned char ram_45210[];
extern unsigned int ram_451cc[];
extern unsigned char *ram_4531c;
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch);
void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteExtParams_15_Bank(int, unsigned int *);
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define PART_ROW(p)     ((unsigned char *)(unsigned long)(ram_41368 + (p) * 0x11f))

/* cc900-name: ToneGen_WriteExtParams_15_Bank=ToneGen_WriteExtParams_15_Banked */
/* cc900-module: RoutingFlag_Encode */
/* cc900-module: SlotRouting_WriteSingle */
/* cc900-module: SlotRouting_Chan1 */
/* cc900-module: SlotRouting_Chan3 */

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
        ToneGen_WriteExtParams_15_Bank(i, ram_451cc);
    }
}

void DSP_SetVoiceCoefficients(unsigned char part, unsigned char sel, unsigned char *out)
{
    register unsigned char *s = 0;
    unsigned long off = 0;
    unsigned char *rec;
    unsigned int n;
    unsigned int x;
    unsigned int y;
    unsigned int h;
    unsigned int d;
    unsigned int i;

    rec = ToneDB_Find_ToneRecord(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
    x = rec[(int)sel * 2 + 0x27];
    y = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 0x27] + 1);
    switch (y & 0x20) {
    case 0:
        x &= 0x7f;
        h = y & 0x1f;
        switch (y & 0xc0) {
        case 0x00:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ToneDB_RootPtr[31];
            break;
        }
        d = *(unsigned long *)((unsigned long)(((h << 7) + x) * 2) + off + ToneDB_RelBase);
        off = ToneDB_RootPtr[44];
        s = (unsigned char *)(ToneDB_RelBase + off);
        s += d * 10;
        break;
    case 0x20:
        s = ToneDB_Find_SubToneRecord(rec, sel, 0xff);
        break;
    }
    n = 10;
    for (i = 0; i < n; i++) *out++ = *s++;
}

void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp)
{
    struct slotrt *p;
    unsigned char *q;
    unsigned char k;

    p = (struct slotrt *)&PART_ROW(part)[(int)slot * 37 + 110];
    p->w[grp] = 0;
    for (k = 0; k < 4; k++) {
        q = (unsigned char *)((unsigned long)&PART_ROW(part)[(int)grp * 16 + (int)k * 4] + 39);
        if (*q & 0x0a) {
            RoutingFlag_Encode(p, q, slot, grp, k);
        } else if (*q & 5) {
            switch (grp) {
            case 0:
                SlotRouting_WriteSingle(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[6]);
                break;
            case 1:
                SlotRouting_Chan1(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[38]);
                break;
            case 2:
                SlotRouting_Chan3(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[56]);
                break;
            }
        }
    }
}

void DSP_SetCoeff_RouteComplex(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *rec;
    unsigned int x;
    unsigned int y;
    unsigned int f;
    unsigned int i;
    unsigned long off;
    register unsigned char *q;

    rec = PART_PATCH(part);
    x = rec[(int)sel * 2 + 39];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    y &= 31;
    f = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    f &= 32;
    off = ToneDB_RootPtr[31];
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + off + ToneDB_RelBase);
    off = ToneDB_RootPtr[32];
    tbl = (unsigned char *)(ToneDB_RelBase + off);
    n = 13;
    switch (f) {
    case 0:
        for (i = 0; i < n; i++)
            ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
        break;
    case 0x20:
        for (i = 0; i < n; i++) {
            q = &ram_4531c[(int)sel * 80 + 19111];
            ram_45210[i + 6] = q[i];
        }
        break;
    }
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
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
            if (((*(unsigned char **)((unsigned long)(ram_41368 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)((unsigned long)(ram_41368 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}

unsigned int DSP_VoiceParam_Dispatch(unsigned int a, unsigned int b, unsigned char *d)
{
    unsigned int n, i;
    unsigned char *s;
    unsigned int h;
    unsigned long off;

    switch (b & 0x20) {
    case 0:
        a &= 0x7f;
        h = b & 0x1f;
        switch (b & 0xc0) {
        case 0:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ToneDB_RootPtr[31];
            break;
        }
        b = *(unsigned long *)(((h << 7) + a) * 2 + off + ToneDB_RelBase);
        off = ToneDB_RootPtr[32];
        off = ToneDB_RelBase + off;
        s = (unsigned char *)off + (unsigned long)b * 16;
        break;
    case 0x20:
        s = ToneDB_Find_ToneRecord(a, b);
        break;
    }
    n = 13;
    for (i = 0; i < n; i++) *d++ = s[i];
    return n;
}

void DSP_SetCoeff_RouteWithCallback(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char *q;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    unsigned long t;

    s = e;
    s &= 15;
    q = ToneDB_Find_SubToneRecord(*(unsigned char **)&ram_4136e[(a) * 0x11f], c, a);
    q = &q[(int)s * 21 + 16];
    x = (unsigned char)q[1];
    x &= 127;
    y = (unsigned char)q[2];
    y &= 15;
    switch ((int)q[2] & 192) {
    case 0x00:
    case 0x40:
    case 0x80:
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[19];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[35];
    t = ToneDB_RelBase;
    t += (unsigned long)tbl;
    tbl = (unsigned char *)t;
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

void Audio_Cmd_ToneEdit_Field_Write_And_Reply(unsigned char *m)
{
    unsigned char *r;
    unsigned char t;

    r = ToneDB_Find_SubToneRecord(PART_PATCH(m[1]), ram_4531c[29351], m[1]);
    t = (m[2] & 0xc0) >> 6;
    r += (int)t * 21 + 16;
    r = WaveSel_StageA1_FromToneSlot(t, r, ram_4531c[29351], m[1]);
    r += m[2] & 63;
    *r = m[4];
    InterCPU_E1_DMA_Transfer(r, 1,
        (unsigned char *)((unsigned long)((unsigned char *)0x1e0000 + ((int)ram_4531c[29351] * 80 + (int)t * 11)) + 19169)
        + (m[2] & 63));
}
