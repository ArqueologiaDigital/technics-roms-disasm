/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AE_21b.c (2026-11-18-21-sub-r21c-staged)
   sha256 f125330397da25f7470c96482a86fdc6ba8d9cbe469b39ed2a371b49133f7cff (tar-sha256); compiled at -Xr */
/* lane_sub helper AE, round 21, form b (KN5000 sub-CPU payload v1.42, v142/subcpu).  Same functions as
   sub_AE_21a.c; form b differs from form a only as said here.
   - VoiceState_SwapSlot_DE_BC / _HL_IY: one function-level `unsigned int o;` reassigned before each access (form a
     has a new block-local o per access).
   - TVF_Lookup_Depth_Amount: lo and hi both `register`.
   - VoiceParam_Set_Tone_Option: the constant behind a unary plus, `ram_44fce[(int)(unsigned int)idx + +472]`.
   - Debug_Print_Word: the int prototype kept; the byte put in the register variable,
     `__WA = (unsigned char)w; BootROM_HEX_BYTE_TO_ASCII(__WA);`.
   - RingBuf_ReadByte / DSP_RingBuf_Read: the parameter an unsigned long, `*(unsigned char *)((unsigned long)i + 6 + r)`,
     fields through struct casts.
   - DSP1_ResolveStreamPtr: `v = *((unsigned long *)(base + off) + n);`.
   - DSP_EFFParam_DiffAllAndFlag: ram_4600 a byte array, the +8 behind a unary plus, `WT(int, ram_4600, i * 56 + +8)`.
   - Keybed_Read_Event: no hi variable; declared lo, st, d.
   - WaveSel_StageB_Build_Reg040: `p = (unsigned long)*(unsigned char **)a1;`.
   - DSP_ParamInterp_3Point_WithOffset: no result local, the store inside the returned expression,
     `return (*pp = p, 0L) + ((c + v0 + (u - v0) * b / 0x63) << 8);` (V4.23 evaluates the complex operand first). */

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
#define RG(r) ((struct ring *)(r))
#define ROWP(a) (ram_24e6 + (int)(a) * 12)
#define GET(d, r, k) o = (k); d = *(ROWP(r) + o);
#define PUT(r, k, v) o = (k); *(ROWP(r) + o) = (v);

#define WT(type, base, s) (*(type *)&(base)[(unsigned int)(s)])
#define FL(base, i, j) WT(unsigned int, base, (i) * 50 + (j) * 2)
#define FL56(type, base, i, j) WT(type, base, (i) * 56 + (j) * 2)

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct ring { unsigned int w, r, n; };

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
extern void BootROM_HEX_BYTE_TO_ASCII(int);
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
    unsigned int o;
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
    unsigned int o;
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
    register unsigned int hi;
    unsigned int n;
    register unsigned int lo;
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
    return hi | lo;
}

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    ram_44fce[(int)(unsigned int)idx + +472] = v;
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
    __WA = (unsigned char)w;
    BootROM_HEX_BYTE_TO_ASCII(__WA);
    __WA = 0;
}

int RingBuf_ReadByte(unsigned long r)
{
    unsigned int i;
    int c;
    unsigned int u;

    if (RG(r)->n != 0) {
        i = RG(r)->r++ & 0xfff;
        u = *(unsigned char *)((unsigned long)i + 6 + r);
        c = u;
        RG(r)->n--;
    } else
        c = -1;
    return c;
}

int DSP_RingBuf_Read(unsigned long r)
{
    unsigned int i;
    int c;
    unsigned int u;

    if (RG(r)->n != 0) {
        i = RG(r)->r++ & 0x7ff;
        u = *(unsigned char *)((unsigned long)i + 6 + r);
        c = u;
        RG(r)->n--;
    } else
        c = -1;
    return c;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned long v;
    unsigned char *base;
    unsigned long off;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    v = *((unsigned long *)(base + off) + n);
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
        if (WT(int, ram_4600, i * 56 + +8) !=((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
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
    int st;
    unsigned int d;

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
    unsigned long p;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = (unsigned long)*(unsigned char **)a1;
    p += ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup((unsigned char *)p, SW(v, 6)) + 4];
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
    long v0;
    long v1;
    unsigned char *p;
    long u;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    return (*pp = p, 0L) + ((c + v0 + (u - v0) * b / 0x63) << 8);
}
