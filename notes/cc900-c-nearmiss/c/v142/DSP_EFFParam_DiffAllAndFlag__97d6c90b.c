/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AE_21c.c (2026-11-18-21-sub-r21c-staged)
   sha256 97d6c90b16d3803d479ee8ef7fcea112471572857f4d17a20b489d76ff0ae2c7 (tar-sha256); compiled at -Xr */
/* lane_sub helper AE, round 21, form c (KN5000 sub-CPU payload v1.42, v142/subcpu).  Same functions as
   sub_AE_21a.c; form c differs from form a only as said here.
   - VoiceState_SwapSlot_DE_BC / _HL_IY: block-local o per access as in form a, the offset on the left,
     `*(o + ROWP(a))`.
   - TVF_Lookup_Depth_Amount: `register unsigned int lo;` declared first, n in an inner block holding the body.
   - VoiceParam_Set_Tone_Option: the constant first, `ram_44fce[472 + (int)(unsigned int)idx]`.
   - Debug_Print_Word: BootROM_HEX_BYTE_TO_ASCII prototyped with an unsigned char parameter, the second call
     passing `w` uncast.
   - RingBuf_ReadByte / DSP_RingBuf_Read: unsigned char pointer parameter as in form a, `((unsigned long)i + 6)[r]`.
   - DSP1_ResolveStreamPtr: tbl kept but indexed, `tbl = (unsigned long *)(base + off); v = tbl[n];`.
   - DSP_EFFParam_DiffAllAndFlag: ram_4600 a byte array, the constant first, `WT(int, ram_4600, 8 + i * 56)`.
   - Keybed_Read_Event: no hi variable; declared lo, d, st.
   - WaveSel_StageB_Build_Reg040: p an unsigned char pointer, `p = *(unsigned char **)a1; p += ToneDB_RelBase;`,
     passed as `(unsigned char *)(unsigned long)p`.
   - DSP_ParamInterp_3Point_WithOffset: the quotient in its own long local q, then `r = (c + v0 + q) << 8;`
     (r declared first, function returning long). */

/* cc900-module: VoiceState_SwapSlot_DE_BC */
/* cc900-module: WaveSel_KeyTable_Lookup */
/* cc900-module: WaveSel_Emit_ZoneRecord_S4 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S6 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S10 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S12 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S13 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S15 */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 */
/* cc900-module: Keybed_Decode_Event */
/* cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE */

#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define UW(p, o) (*(unsigned int *)((p) + (o)))
#define ROWP(a) (ram_24e6 + (int)(a) * 12)
#define GET(d, r, k) { unsigned int o = (k); d = *(o + ROWP(r)); }
#define PUT(r, k, v) { unsigned int o = (k); *(o + ROWP(r)) = (v); }

#define WT(type, base, s) (*(type *)&(base)[(unsigned int)(s)])
#define FL(base, i, j) WT(unsigned int, base, (i) * 50 + (j) * 2)
#define FL56(type, base, i, j) WT(type, base, (i) * 56 + (j) * 2)

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct sv56 { char pad[8]; int on; char pad2[46]; };

#ifdef __GNUC__
extern int __wa;                /* only for syntax_check.sh, which maps the cc900 register variable __WA to __wa */
#endif

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern int __near ram_2940;
extern unsigned long ToneDB_RelBase;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern unsigned char __near ram_24e6[];
extern unsigned char ram_44fce[];
extern unsigned char __near ram_45d4[];
extern unsigned char __near ram_45d6[];
extern unsigned char __near ram_45fa[];
extern unsigned char __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned char __near ram_4942[];
extern unsigned char __near ram_4944[];
extern unsigned char __near ram_4966[];

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
extern void BootROM_HEX_BYTE_TO_ASCII(unsigned char);
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
extern void Keybed_Decode_Event(unsigned char *ev, char d);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);

/* cc900-name: VSwapSlot_DE_BC=VoiceState_SwapSlot_DE_BC */
void VSwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    GET(x, a, c)
    GET(y, a, c + 4)
    PUT(y, c, x)
    PUT(x, c + 4, y)
    PUT(a, c, a)
    PUT(a, c + 4, a)
}

void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char x, y;
    GET(x, a, c)
    GET(y, a, c + 4)
    PUT(y, c, x)
    PUT(x, c + 4, y)
    GET(y, e, c + 4)
    PUT(y, c, a)
    PUT(a, c + 4, y)
    PUT(a, c, e)
    PUT(e, c + 4, a)
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    register unsigned int lo;
    unsigned int hi;
    {
        unsigned int n;
        n = a & 0xf;
        if (a & 0x80) {
            hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3);
            hi <<= 8;
            lo = TVF_DepthRecords_B[n][0];
            ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
        } else {
            hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3);
            hi <<= 8;
            lo = TVF_DepthRecords_A[n][0];
            ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
        }
    }
    return hi | lo;
}

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    ram_44fce[472 + (int)(unsigned int)idx] = v;
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

void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII(w);
    __WA = 0;
}

int RingBuf_ReadByte(unsigned char *r)
{
    unsigned int i;
    int c;
    unsigned int u;

    if (UW(r, 4) != 0) {
        i = UW(r, 2)++ & 0xfff;
        u = ((unsigned long)i + 6)[r];
        c = u;
        UW(r, 4)--;
    } else
        c = -1;
    return c;
}

int DSP_RingBuf_Read(unsigned char *r)
{
    unsigned int i;
    int c;
    unsigned int u;

    if (UW(r, 4) != 0) {
        i = UW(r, 2)++ & 0x7ff;
        u = ((unsigned long)i + 6)[r];
        c = u;
        UW(r, 4)--;
    } else
        c = -1;
    return c;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned long v;
    unsigned char *base;
    unsigned long *tbl;
    unsigned long off;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    v = tbl[n];
    off = (unsigned long)base;
    base += v;
    return base;
}

void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (FL56(unsigned int, ram_45d4, i, j) != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                FL(ram_4942, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4942, i, j) = 0;
        }
        for (j = 0; j < 17; j++) {
            if (FL56(int, ram_45d6, i, j) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                FL(ram_4944, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4944, i, j) = 0;
        }
        for (j = 0; j < 1; j++) {
            if (FL56(int, ram_45fa, i, j) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                FL(ram_4966, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4966, i, j) = 0;
        }
        if (WT(int, ram_4600, 8 + i * 56) !=((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned char lo;
    unsigned int d;
    int st;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = (unsigned char)d & 0xff;
        if (((unsigned char)(d >> 8) & 0xff) == 0xff || (st & 2)) {
            if (lo & 0x80)
                return 0xffff;
            Keybed_Decode_Event(ev, lo);
            ev[1] = 0;
            return 0;
        } else {
            Keybed_Decode_Event(ev, lo);
            return 0;
        }
    }
    return 0xffff;
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char k;
    unsigned char *p;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = *(unsigned char **)a1;
    p += ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup((unsigned char *)(unsigned long)p, SW(v, 6)) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, a2, k);
    }
}

long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long r;
    long v0;
    long v1;
    unsigned char *p;
    long u;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    q = (u - v0) * b / 0x63;
    r = (c + v0 + q) << 8;
    *pp = p;
    return r;
}
