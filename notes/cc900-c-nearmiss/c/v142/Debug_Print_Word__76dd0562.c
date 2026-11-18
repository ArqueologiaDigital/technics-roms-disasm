/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AE_20c.c (2026-11-18-6-sub-r20a)
   sha256 76dd05625b2c30f5c9ddf2afd24a73f7d072b1dd8faf34e46ec2300b150dff42 (tar-sha256); compiled at -Xr */
/* lane_sub helper AE, round 20, form c (KN5000 sub-CPU payload v1.42, v142/subcpu).  Same functions as
   sub_AE_20a.c; form c differs from form a only as said here.
   - Voice_PortaLevel_Compute: no `(void *)&a;`, a declared `volatile` instead.
   - VoiceState_SwapSlot_DE_BC / _HL_IY: the +4 inside the cast, `*((unsigned int)(c + 4) + ROWP(a))`.
   - TVF_Lookup_Depth_Amount: lo, hi declared in the function, n in an inner block holding the body.
   - VoiceParam_Set_Tone_Option: `o = (int)(unsigned int)idx + 472;` in one statement, q assigned after it.
   - Debug_Print_Word: `(unsigned char)(char)w`.
   - RingBuf_ReadByte / DSP_RingBuf_Read: the offset through an unsigned long local,
     `t = (unsigned long)i + 6; u = *(unsigned char *)(t + (unsigned long)r);`.
   - DSP1_ResolveStreamPtr: form a's merged off, declared base, off, tbl, v.
   - DSP_EFFParam_DiffAllAndFlag: byte arrays as in form b, WT = `*(type *)((unsigned int)(s) + (base))`;
     the last test with the ram_4600 word first.
   - Keybed_Read_Event: declared st, hi, lo, d.
   - Voice_ScanSlots_ReassignSources: declared r, s, i, q, j.
   - WaveSel_StageB_Build_Reg040: the Lookup argument `*(unsigned char **)a1 + ToneDB_RelBase` (pointer + long, no
     cast); a2 uncast.
   - DSP_ParamInterp_3Point_WithOffset: `register long r;` declared first.
   DSP_WriteParameter is already built (v142/subcpu/cc900/dsp_control_routines_e_10a.c): not repeated. */

/* cc900-module: Detune_ScaleUnsigned */
/* cc900-module: Detune_ScaleSymmetric */
/* cc900-module: Int_ClampSignedToRange */
/* cc900-module: PitchBend_Scale */
/* cc900-module: VoiceSlot_UpdateNoteSource */
/* cc900-module: Quad_Decode_A_To_L */
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
#define ROWP(a) (ram_24e6 + (int)(a) * 12)
#define AT(r, o) (*((unsigned int)(o) + ROWP(r)))
#define AT4(r, o) (*((unsigned int)((o) + 4) + ROWP(r)))

#define WT(type, base, s) (*(type *)((unsigned int)(s) + (base)))
#define FL(base, i, j) WT(unsigned int, base, (i) * 50 + (j) * 2)
#define FL56(type, base, i, j) WT(type, base, (i) * 56 + (j) * 2)

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };

#ifdef __GNUC__
extern int __wa;                /* only for syntax_check.sh, which maps the cc900 register variable __WA to __wa */
#endif

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern int __near ram_2940;
extern unsigned int ram_451e2;
extern unsigned int ram_451ea;
extern unsigned long ToneDB_RelBase;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern unsigned char __near ram_2126[];
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

unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_SwapSlot_DE_BC(int a, int c);
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
unsigned int Detune_ScaleUnsigned(unsigned int a);
int Detune_ScaleSymmetric(int a);
int Int_ClampSignedToRange(int a, int hi, int lo);
int PitchBend_Scale(int a, int b, int c);
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

void Voice_PortaLevel_Compute(unsigned char *v)
{
    unsigned char *t;
    unsigned int b;
    volatile unsigned int a;
    int c;
    unsigned char *u;
    u = P(v, 23);
    t = u;
    if (((char *)u)[7] < 0) {
        a = Detune_ScaleUnsigned(~(int)(char)t[7] + 1);
        b = Detune_ScaleSymmetric(~(int)(char)t[8] + 1);
    } else {
        a = Detune_ScaleUnsigned((char)t[7]);
        b = Detune_ScaleSymmetric((char)t[8]);
    }
    a += PitchBend_Scale((char)t[18], v[12], 6);
    a = Int_ClampSignedToRange(a, 0x7f, 0);
    c = 0x7f;
    c += PitchBend_Scale((char)t[72], v[12], 6);
    c = Int_ClampSignedToRange(c, 0x7f, 0);
    ram_451e2 = (a << 8) | ((unsigned int)c & 0xff);
    ram_451ea = (b << 8) | ((unsigned int)Detune_ScaleSymmetric((char)(t[62] + t[61])) & 0xff);
}

/* cc900-name: VSwapSlot_DE_BC=VoiceState_SwapSlot_DE_BC */
void VSwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = AT(a, c);
    y = AT4(a, c);
    AT(y, c) = x;
    AT4(x, c) = y;
    AT(a, c) = a;
    AT4(a, c) = a;
}

void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char x, y;
    x = AT(a, c);
    y = AT4(a, c);
    AT(y, c) = x;
    AT4(x, c) = y;
    y = AT4(e, c);
    AT(y, c) = a;
    AT4(a, c) = y;
    AT(a, c) = e;
    AT4(e, c) = a;
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int lo;
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
    int o;
    unsigned char *q;

    o = (int)(unsigned int)idx + 472;
    q = ram_44fce;
    q[o] = v;
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
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(char)w);
    __WA = 0;
}

int RingBuf_ReadByte(struct ring4k *r)
{
    unsigned int i;
    int c;
    unsigned int u;
    unsigned long t;

    if (r->n != 0) {
        i = r->r++ & 0xfff;
        t = (unsigned long)i + 6;
        u = *(unsigned char *)(t + (unsigned long)r);
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
    unsigned long t;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        t = (unsigned long)i + 6;
        u = *(unsigned char *)(t + (unsigned long)r);
        c = u;
        r->n--;
    } else
        c = -1;
    return c;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *base;
    unsigned long off;
    unsigned long *tbl;
    unsigned long v;

    base =(unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    tbl += n;
    v = *tbl;
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
        if (WT(int, ram_4600, i * 56 + 8) != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
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
    int st;
    unsigned char hi;
    unsigned char lo;
    unsigned int d;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = (unsigned char)d & 0xff;
        hi = (unsigned char)(d >> 8) & 0xff;
        if (hi == 0xff || (st & 2)) {
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

void Voice_ScanSlots_ReassignSources(unsigned char a)
{
    unsigned char *r;
    unsigned char s;
    unsigned char i;
    unsigned char *q;
    int j;
    r = ram_24e6 + (int)a * 12;
    for (i = 0; i < 4; i++) {
        if ((s = r[(int)i + 8]) < 0xc0) {
            q = &ram_2126[(int)s * 5];
            if (q[4] == a) {
                if (r[i] != a) q[4] = r[i];
                else {
                    q[4] = 0xff;
                    j = s;
                    VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L(s));
                }
            }
            VoiceState_SwapSlot_DE_BC(a, i);
            r[(int)i + 8] = 0xff;
        }
    }
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    k = a1[(int)WaveSel_KeyTable_Lookup(*(unsigned char **)a1 + ToneDB_RelBase, SW(v, 6)) + 4];
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
    register long r;
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
    r = (c + v0 + (u - v0) * b / 0x63) << 8;
    *pp = p;
    return r;
}
