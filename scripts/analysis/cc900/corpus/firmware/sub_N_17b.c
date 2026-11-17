/* lane_sub helper N, round 17, form b (KN5000 sub-CPU payload v1.42); written by gen_N_17.py (lane_sub's
   scratch N/).  The four functions open after round 16, DSP_OscAlgoSelect (the twin of DSP_AlgoDescriptor_Emit)
   and pool D's near misses, each its best earlier file changed only where said (DSP_FlushAllSlots and
   DSP_WriteCount_Compute are new: FlushAllSlots as a 295-byte image struct at offset 0x4980 of the buffer in
   forms a / c, as byte-pointer arithmetic in form b):
   DSP_AlgoDescriptor_Emit / DSP_OscAlgoSelect: sub_L_16a (p and k initialised, k unsigned, void * prototype) with
     the last parameter an unsigned int and the sum written (*p & 0xff) + sub * 3.
   EGEnv_Compute_A: `(unsigned int)x | (unsigned int)(int)T[..]`; _B: the table word in a register local.
   VoiceParam_Set_Tone_Option: `int o = idx;` indexed with `(unsigned int)o + 472`.
   DSP_VoiceCoeffRoute2: form a with the relocation through an unsigned long local and entry 13 as
     (&tbl[d * 16])[13].
   Debug_Print_Word: the boot ROM routine without a prototype, the bytes cast to unsigned char.
   RingBuf_ReadByte: `(int)(unsigned int)` on the byte; DSP_RingBuf_Read: the struct's buf member through an
     unsigned char local.
   DSP1_ResolveStreamPtr: `v = *tbl; q = base; base += v; return base;` (the ROM copies base to XBC, unused).
   DSP_WriteCount_Compute: a while loop with n-- at its end.
   ToneGen_SetupPolyVoice: the pitch word through an unsigned int temporary.
   EFF_VolumeUpdate_WithDebug: the on flag cast to unsigned int in the test.
   EFF_* flag arrays: round 8's word arrays with int column indices (bounds 17u / 1u); the idx column through a
     byte view of the rows, [i][idx * 2]; the order-table column as *(*q + row).
   EFF_SecondaryLinkPath: m a register local declared before i. */

/* cc900-module: EnvDepth_Cap */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 */
/* cc900-module: DSP_VelocityToVolume */
/* cc900-module: DSP_GetEffectRouting */
/* cc900-module: Unsigned_Max_Select */
/* cc900-module: DSP_InitChannelSlot */
/* cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE */

#define PART(p) ((unsigned char *)(unsigned long)(ram_41368 + (p) * 0x11f))
#define ROUTE(p, s) (*(unsigned char **)((unsigned long)&PART(p)[(int)(s) * 37 + 110] + 4))
#define JT int
#define N17 17u
#define N1 1u
#define FLG(i, j) ram_4944[i][j]
#define FLA(i, j) ram_4942[i][j]
#define FLQ(i, j) ram_4966[i][j]
#define FLGI(i, x) (*(unsigned int *)&((unsigned char (*)[50])ram_4944)[i][(x) * 2])
#define FLGQ(i, c) (*((c) + ram_4944[i]))
#define KT int
#define KSET(k) EFF_SlotActiveFlags.active[(k) + 10] = 1

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
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
struct img295 { unsigned char hdr[16]; unsigned char x[23]; struct e2 slots[128]; };
struct g7800 { unsigned char pad[0x4980]; struct img295 img; };
#define G7800 ((struct g7800 *)ram_4531c)

extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern struct sv56 __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char *ram_4531c;
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
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
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
extern void DSP_InitChannelSlot();
extern void InterCPU_E1_DMA_Transfer(unsigned char *p, unsigned int n, unsigned long dst);
void Debug_Print_Word(unsigned int w);
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p);

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, unsigned int len)
{
    int st;
    unsigned int v;
    unsigned char *p = tbl;
    unsigned int k = 0x78;

    p = DSP_TableWalk_Search(p, k, len, &st);
    v = (*p & 0xff) + sub * 3;
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    if (type != 0x63) {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
        st = DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        st = DSP_DispatchData(0, chip);
    } else {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x20, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
    }
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(7, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}

int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                      unsigned int base, unsigned int len)
{
    int st;
    unsigned int v;
    unsigned char *p = tbl;
    unsigned int k = 0x78;

    p = DSP_TableWalk_Search(p, k, len, &st);
    v = (*p & 0xff) + sub * 3;
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    st = DSP_DispatchData(8, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData((unsigned char)(((type + a) >> 4) & 0xf), chip);
    st = DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
    st = DSP_DispatchData(0x21, chip);
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(8, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(8, chip);
    }
    return st;
}

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_4424e + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_A[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | (unsigned int)(int)EGEnv_ModeBits_Table[p[0] & 3];
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    register unsigned int m;
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
    m = EGEnv_ModeBits_Table[p[0] & 3];
    return (unsigned int)x | m;
}

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    int o = idx;
    ram_44fce[(unsigned int)o + 472] = v;
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
    unsigned long t;

    s = sel;
    s &= 15;
    z = (sel & 0xf0) >> 4;
    x = ROUTE(part, s)[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&ROUTE(part, s)[(int)z * 2 + 3] + 1) & 192) {
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
    t = ToneDB_RelBase + (unsigned long)tbl;
    tbl = (unsigned char *)t;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = (&tbl[(unsigned long)d * 16])[13];
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
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)w);
    __WA = 0;
}

int RingBuf_ReadByte(struct ring4k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0xfff;
        c = (int)(unsigned int)*(unsigned char *)(((unsigned long)i + 6) + (unsigned long)r);
        r->n--;
    } else
        c = -1;
    return c;
}

int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;
    unsigned char b;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        b = r->buf[i];
        c = b;
        r->n--;
    } else
        c = -1;
    return c;
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *base;
    unsigned long *tbl;
    unsigned long v;
    unsigned char *q;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    tbl = (unsigned long *)(base + *(unsigned long *)(base + 8));
    tbl += n;
    v = *tbl;
    q = base;
    base += v;
    return base;
}

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int n;
    unsigned int *p;
    unsigned int s;

    n = 0x4970;
    n >>= 1;
    p = (unsigned int *)(ram_4531c + 16);
    s = 0;
    while (n != 0) {
        s += *p++;
        n--;
    }
    return ~s;
}

void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    {
        unsigned char x;

        x = Audio_DSP_StateTable_Packed[type] + note;
        note = x;
    }
    note &= 0x7f;
    ram_3b2a = ((unsigned int)note << 8) | 0x80;
    if (ToneGen_VoiceType_Default_Level[type] != 0)
        vel = ToneGen_VoiceType_Default_Level[type];
    ram_3b20 |= DSP_VelocityToVolume(vel);
    ram_3b22 |= DSP_GetEffectRouting();
    {
        unsigned int t;

        t = ToneGen_Semitone_Pitch_Table[note % 12];
        ram_3b1e = t;
    }
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}

void DSP_FlushAllSlots(unsigned char a, unsigned char b)
{
    struct img295 *rec;
    unsigned int i;

    rec = (struct img295 *)ToneDB_Find_ToneRecord(a, b);
    *(struct img295 *)(ram_4531c + 0x4980) = *rec;
    for (i = 0; i < 0x80; i++) {
        ((struct e2 *)(((unsigned long)i + (unsigned long)i + 0x49a7) + (unsigned long)ram_4531c))->b1 &= ~0x20;
        ((struct e2 *)(((unsigned long)i + (unsigned long)i + 0x49a7) + (unsigned long)ram_4531c))->b1 |= 0x20;
    }
    for (i = 0; i < 0x80; i++)
        DSP_InitChannelSlot(rec, i);
    for (i = 0; i < 0x10; i++)
        *(unsigned char *)(((unsigned long)i + 0x4980) + (unsigned long)ram_4531c) = DSP1_ImageHeader_UserKit[i];
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
        if ((unsigned int)((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6];
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = t;
        }
    }
}

void EFF_VolumeLoop(unsigned long p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (FLGI(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) == 1) {
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
                FLGI(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) = 1;
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
    JT i;
    unsigned int n;
    unsigned char *q;

    switch (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type) {
    default:
        n = ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if (FLG(slot, i) == 1 && i != ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->idx)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->param[13] & 1) * 11];
        while (*q != 12) {
            if (FLGQ(slot, *q) == 1)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type, *q, p);
            q++;
        }
        break;
    }
}

void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    JT j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < N1; j++) {
            if (ram_45d4[i][j] != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                FLA(i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FLA(i, j) = 0;
        }
        for (j = 0; j < N17; j++) {
            if (ram_45d6[i][j] != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                FLG(i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FLG(i, j) = 0;
        }
        for (j = 0; j < N1; j++) {
            if (ram_45fa[i][j] != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                FLQ(i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FLQ(i, j) = 0;
        }
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on != ram_4600[i].on) {
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
    JT j;
    KT k;

    for (i = 0; i < 5; i++) {
        if (DSP_AlgoChangedFlag == 1)
            ram_4940[i].f0 = 1;
        if (ram_4940[i].f0 == 1) {
            for (j = 0; j < N17; j++)
                FLG(i, j) = 1;
            for (j = 0; j < N1; j++)
                FLA(i, j) = 1;
            for (j = 0; j < N1; j++)
                FLQ(i, j) = 1;
            EFF_SlotActiveFlags.r[i].g[0] = 1;
            EFF_SlotActiveFlags.r[i].g[1] = 1;
            EFF_SlotActiveFlags.r[i].g[2] = 1;
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
            if (i == 1) {
                k = ((struct cfg *)p)->s[0].idx + 1;
                switch (((struct cfg *)p)->s[0].type) {
                default:
                    KSET(k);
                    break;
                case 0x0f: case 0x35:
                    k++;
                    KSET(k);
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
            FLGI(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) = 1;
    }
}

void EFF_SecondaryLinkPath(struct cfg *p)
{
    register unsigned int m;
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
