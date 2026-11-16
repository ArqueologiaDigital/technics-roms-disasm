/* lane_sub probe round 5, helper D, form c: DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s).
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   The config pointer is an unsigned long parameter; slot records are addressed as offset + p.
   EFF_SlotActiveFlags (0x4930): active[5], chip[2], algo-changed word, five 50-byte records (f0, a[1], flags[17],
   q[1], g[5]). */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };

extern struct slot __near ram_4496[];
extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern int __near ram_4600;
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern unsigned char __near ram_3b13;
extern unsigned char __near ram_3b14[];
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

extern char Str_EffParamEdit_Prefix[], Str_EffParamEdit_Mid[], Str_EffParamEdit_Suffix[];
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];
extern void (*Voice_PolyNoteOn_Setup_PtrTable[])(int, int, int, int);

extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void BootROM_HEX_BYTE_TO_ASCII(int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);

void Debug_Print_Word(unsigned int w)
{
    __IZ = w;
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(__IZ >> 8));
    __WA = 0;
    __WA = (unsigned char)__IZ;
    BootROM_HEX_BYTE_TO_ASCII(__WA);
    __WA = 0;
}

int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        c = *((unsigned long)i + 6 + (unsigned char *)r);
        r->n--;
    } else
        c = -1;
    return c;
}

int RingBuf_ReadByte(struct ring4k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0xfff;
        c = *((unsigned long)i + 6 + (unsigned char *)r);
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

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    v = tbl[n];
    off = (unsigned long)base;
    return (unsigned char *)(off + v);
}

struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        __XWA = (unsigned long)&ram_4496[i];
        return (struct slot *)__XWA;
    default:
        return (struct slot *)0xffffffff;
    }
}

void DSP_SlotParam_DiffAndFlag(unsigned long p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != ((struct slot *)(((unsigned long)i * 56 + 8) + p))->type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}

void DSP_Config_ClampLimits(unsigned long p)
{
    unsigned int i;

    if (((struct cfg *)p)->f6 > 1)
        ((struct cfg *)p)->f6 = 0;
    for (i = 0; i < 5; i++)
        if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type > 0x63)
            ((struct slot *)(((unsigned long)i * 56 + 8) + p))->type = 0x63;
}

void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (ram_45d4[i][j] != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                ram_4942[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4942[i][j] = 0;
        }
        for (j = 0; j < 17; j++) {
            if (ram_45d6[i][j] != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                ram_4944[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4944[i][j] = 0;
        }
        for (j = 0; j < 1; j++) {
            if (ram_45fa[i][j] != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                ram_4966[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4966[i][j] = 0;
        }
        if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ((struct slot *)(((unsigned long)i * 56 + 8) + p))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
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
            switch (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (((struct cfg *)p)->f0 == 1 && EFF_SlotActiveFlags.r[i].g[4] == 1) || (EFF_SlotActiveFlags.r[i].g[4] == 1 && found == 1)) {
                EFF_SlotActiveFlags.active[i] = 1;
                ram_4944[i][((struct slot *)(((unsigned long)i * 56 + 8) + p))->idx] = 1;
                EFF_SlotActiveFlags.r[i].g[1] = 1;
                EFF_SlotActiveFlags.r[i].g[2] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
                if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->r42[3] != 0x63)
                    EFF_SlotActiveFlags.r[i].g[0] = 1;
            } else
                EFF_SlotActiveFlags.active[i] = 0;
        }
    }
}

void EFF_DspChannel_InitFlags(unsigned long p)
{
    unsigned int i;
    unsigned int j;
    unsigned int k;

    for (i = 0; i < 5; i++) {
        if (DSP_AlgoChangedFlag == 1)
            ram_4940[i].f0 = 1;
        if (ram_4940[i].f0 == 1) {
            for (j = 0; j < 17; j++)
                ram_4944[i][j] = 1;
            for (j = 0; j < 1; j++)
                ram_4942[i][j] = 1;
            for (j = 0; j < 1; j++)
                ram_4966[i][j] = 1;
            EFF_SlotActiveFlags.r[i].g[0] = 1;
            EFF_SlotActiveFlags.r[i].g[1] = 1;
            EFF_SlotActiveFlags.r[i].g[2] = 1;
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
            if (i == 1) {
                k = ((struct cfg *)p)->s[0].idx + 1;
                switch (((struct cfg *)p)->s[0].type) {
                default:
                    *(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;
                    break;
                case 0x0f: case 0x35:
                    k++;
                    *(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;
                    break;
                }
            }
        }
        if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x27) {
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
        if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x4f) {
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
        if ((((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x35 || ((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x0f) && EFF_SlotActiveFlags.r[i].flags[13] == 1) {
            if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[13] == 1) {
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
            if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x3f && (EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1))
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        }
        if (EFF_SlotActiveFlags.r[i].g[3] == 1)
            ram_4944[i][((struct slot *)(((unsigned long)i * 56 + 8) + p))->idx] = 1;
    }
}

void EFF_ParamEdit_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    Debug_Print_String(Str_EffParamEdit_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffParamEdit_Mid);
    Debug_Print_Byte(idx);
    Debug_Print_String(Str_EffParamEdit_Suffix);
    Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
    DSP_WriteParameter(slot, b, idx, p);
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
        if (((struct slot *)(((unsigned long)slot * 56 + 8) + p))->on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6];
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = t;
        }
    }
}

void EFF_ParamIterator_Process(unsigned int slot, unsigned long p)
{
    unsigned int i;
    unsigned int n;
    unsigned char *q;

    switch (((struct slot *)(((unsigned long)slot * 56 + 8) + p))->type) {
    default:
        n = ((struct slot *)(((unsigned long)slot * 56 + 8) + p))->r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if (ram_4944[slot][i] == 1 && i != ((struct slot *)(((unsigned long)slot * 56 + 8) + p))->idx)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(((unsigned long)slot * 56 + 8) + p))->type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(((struct slot *)(((unsigned long)slot * 56 + 8) + p))->param[13] & 1) * 11];
        while (*q != 12) {
            if (ram_4944[slot][*q] == 1)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)(((unsigned long)slot * 56 + 8) + p))->type, *q, p);
            q++;
        }
        break;
    }
}

void EFF_VolumeLoop(unsigned long p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (ram_4944[i][((struct slot *)(((unsigned long)i * 56 + 8) + p))->idx] == 1) {
            d = ((struct slot *)(((unsigned long)i * 56 + 8) + p))->idx;
            if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->type == 0x3f) {
                ((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[0] = ((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[0] - EFF_VolumeReduction_Steps[((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[1]];
                if (((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[0] < 0)
                    ((struct slot *)(((unsigned long)i * 56 + 8) + p))->param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, ((struct slot *)(((unsigned long)i * 56 + 8) + p))->type, d, p);
        }
    }
}

void Voice_Poly_NoteOn(unsigned char *m)
{
    unsigned char st;
    unsigned char ch;
    unsigned char vel;
    unsigned char note;

    st = m[1];
    ch = st & 0xf;
    if (st < 0xf0)
        return;
    if (ch > 5)
        ch = 0;
    ram_3b13 = (ram_3b13 + 1) & 7;
    vel = m[3] & 0x7f;
    note = m[2] & 0x7f;
    if (vel != 0) {
        ram_18 &= ~0x80;
        ram_100000 = ram_3b13 + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = ram_3b13 + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        (*Voice_PolyNoteOn_Setup_PtrTable[ch])(ram_3b13, ch, note, vel);
        ram_3b14[ram_3b13] = note | 0x80;
    } else {
        note |= 0x80;
        for (ch = 0; ch < 8; ch++) {
            if (ram_3b14[ch] == note) {
                ram_18 &= ~0x80;
                ram_100000 = ch + 0x840;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xa200;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                ram_18 &= ~0x80;
                ram_100000 = ch + 0x800;
                __ASM(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xa280;
                __ASM(" jr $+2");
                __ASM(" nop");
                __ASM(" nop");
                __ASM(" nop");
                ram_3b14[ch] &= ~0x80;
                break;
            }
        }
    }
}
