/* lane_sub probe round 4, helper D, form b: DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s).
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   A slot record of the config buffer is reached as an integer address, (unsigned long)i * 56 + 8 + (unsigned long)p,
   because every pointer spelling makes V4.23 add the member offset 8 in 16 bits (round 3); the ROM adds it in 32.
   EFF_SlotActiveFlags (0x4930) is the effect flag block: active[5], chip[2], algo-changed word, five 50-byte records
   (f0, a[1], flags[17], q[1], g[5]); a constant flags[k] / g[k] of record i reads as lda (block + 4 + 2k) + 16 + i*50. */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };

extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern int __near ram_4600;
extern unsigned int __near ram_4488;
extern unsigned int __near ram_448a;
extern unsigned int __near ram_448c;
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern struct ring2k __near DSP2_RingBuffer;
extern unsigned long __near ram_1040;
extern unsigned char __tiny ram_3c;

extern char Str_EffHeader_Prefix[], Str_EffHeader_Suffix[];
extern char Str_EffParamEdit_Prefix[], Str_EffParamEdit_Mid[], Str_EffParamEdit_Suffix[];
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern char Str_DspTrace_Start[], Str_DspTrace_Stop[];
extern unsigned char EFF_SlotToChip_Table[];
extern unsigned char EFF_Header_Program[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];

extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void BootROM_HEX_BYTE_TO_ASCII(int);
extern void DSP_WriteGlobalConfig(unsigned int, unsigned char *);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, struct cfg *);
extern void Kernel_YieldRotate(int);

void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    __A = w;
    BootROM_HEX_BYTE_TO_ASCII(__A);
    __WA = 0;
}

int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        c = *(unsigned char *)((unsigned long)r + ((unsigned long)i + 6));
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
        c = *(unsigned char *)((unsigned long)r + ((unsigned long)i + 6));
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

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    return base + tbl[n];
}

void DSP_SlotParam_DiffAndFlag(struct cfg *p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}

void DSP_Config_ClampLimits(struct cfg *p)
{
    unsigned int i;

    if (p->f6 > 1)
        p->f6 = 0;
    for (i = 0; i < 5; i++)
        if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type > 0x63)
            ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type = 0x63;
}

void DSP_EFFParam_DiffAllAndFlag(struct cfg *p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (ram_45d4[i][j] != ((unsigned int *)((unsigned long)i * 56 + (unsigned long)j * 2 + (unsigned long)p))[5]) {
                ram_4942[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4942[i][j] = 0;
        }
        for (j = 0; j < 17; j++) {
            if (ram_45d6[i][j] != ((int *)((unsigned long)i * 56 + (unsigned long)j * 2 + (unsigned long)p))[6]) {
                ram_4944[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4944[i][j] = 0;
        }
        for (j = 0; j < 1; j++) {
            if (ram_45fa[i][j] != ((int *)((unsigned long)i * 56 + (unsigned long)j * 2 + (unsigned long)p))[24]) {
                ram_4966[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4966[i][j] = 0;
        }
        if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}

void EFF_SlotActive_UpdateFlags(struct cfg *p)
{
    unsigned int i;
    unsigned int found;

    found = 0;
    if (DSP_AlgoChangedFlag == 1) {
        for (i = 0; i < 5; i++)
            EFF_SlotActiveFlags.active[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (p->f0 == 1 && EFF_SlotActiveFlags.r[i].g[4] == 1) || (EFF_SlotActiveFlags.r[i].g[4] == 1 && found == 1)) {
                EFF_SlotActiveFlags.active[i] = 1;
                ram_4944[i][((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->idx] = 1;
                EFF_SlotActiveFlags.r[i].g[1] = 1;
                EFF_SlotActiveFlags.r[i].g[2] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
                if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->r42[3] != 0x63)
                    EFF_SlotActiveFlags.r[i].g[0] = 1;
            } else
                EFF_SlotActiveFlags.active[i] = 0;
        }
    }
}

void EFF_DspChannel_InitFlags(struct cfg *p)
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
                k = p->s[0].idx + 1;
                switch (p->s[0].type) {
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
        if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x27) {
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
        if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x4f) {
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
        if ((((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x35 || ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x0f) && EFF_SlotActiveFlags.r[i].flags[13] == 1) {
            if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->param[13] == 1) {
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
            if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x3f && (EFF_SlotActiveFlags.r[i].flags[1] == 1 || EFF_SlotActiveFlags.r[i].flags[2] == 1))
                EFF_SlotActiveFlags.r[i].flags[0] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        }
        if (EFF_SlotActiveFlags.r[i].g[3] == 1)
            ram_4944[i][((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->idx] = 1;
    }
}

int __cdecl Audio_CmdHandler_60_7F(unsigned int n, unsigned char *p)
{
    unsigned int i;
    unsigned int size;

    if (ram_448c != 0) {
        if (ram_448c > 1)
            i = 0;
        if ((unsigned int)(ram_448a + n) < ram_4488) {
            ram_448a += n;
            ram_448c++;
        } else {
            ram_448a = 0;
            ram_448c = 0;
        }
    } else if (n == 0x20) {
        size = p[5] & 0x7ff;
        size <<= 7;
        ram_4488 = p[6] + size + 8;
        ram_448a += 32;
        ram_448c = 1;
    } else {
        ram_448a = 0;
        ram_448c = 0;
    }
    for (i = 0; i < n; i++) {
        DSP2_RingBuffer.buf[DSP2_RingBuffer.w++ & 0x7ff] = *p++;
        DSP2_RingBuffer.n++;
    }
    return 0;
}

void DSP_WaitForDelay(unsigned int t)
{
    unsigned long half;
    unsigned long target;

    half = ((unsigned long)t + 1) >> 1;
    half += ram_1040;
    target = half;
    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}

void DSP2_SPI_ClockPulseHigh(void)
{
    ram_3c |= 4;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    ram_3c |= 1;
    __ASM(" jr $+2");
    __ASM(" nop");
    ram_3c &= ~1;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    ram_3c &= ~4;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    Debug_Print_String(Str_DspTrace_Start);
}

void DSP2_SPI_BusIdle(void)
{
    ram_3c &= ~4;
    ram_3c &= ~1;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    ram_3c |= 4;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    ram_3c |= 1;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" jr $+2");
    __ASM(" nop");
    Debug_Print_String(Str_DspTrace_Stop);
}

void EFF_WriteHeader(unsigned int slot)
{
    unsigned int chip;

    Debug_Print_String(Str_EffHeader_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffHeader_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    if (chip == 0)
        DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)EFF_Header_Program);
}

void EFF_ParamEdit_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, struct cfg *p)
{
    Debug_Print_String(Str_EffParamEdit_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffParamEdit_Mid);
    Debug_Print_Byte(idx);
    Debug_Print_String(Str_EffParamEdit_Suffix);
    Debug_Print_Word(((int *)((unsigned long)slot * 56 + (unsigned long)idx * 2 + (unsigned long)p))[6]);
    DSP_WriteParameter(slot, b, idx, p);
}

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, struct cfg *p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)((unsigned long)slot * 56 + (unsigned long)idx * 2 + (unsigned long)p))[6]);
        if (((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)((unsigned long)slot * 56 + (unsigned long)idx * 2 + (unsigned long)p))[6];
            ((int *)((unsigned long)slot * 56 + (unsigned long)idx * 2 + (unsigned long)p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)((unsigned long)slot * 56 + (unsigned long)idx * 2 + (unsigned long)p))[6] = t;
        }
    }
}

void EFF_ParamIterator_Process(unsigned int slot, struct cfg *p)
{
    unsigned int i;
    unsigned int n;
    unsigned char *q;

    switch (((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->type) {
    default:
        n = ((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->r42[1];
        if (n > 17)
            n = 17;
        for (i = 0; i < n; i++)
            if (ram_4944[slot][i] == 1 && i != ((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->idx)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->type, i, p);
        break;
    case 0x35: case 0x0f:
        q = &EFF_ParamIter_OrderTable[(((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->param[13] & 1) * 11];
        while (*q != 12) {
            if (ram_4944[slot][*q] == 1)
                EFF_ParamEdit_WithDebug(slot, ((struct slot *)((unsigned long)slot * 56 + 8 + (unsigned long)p))->type, *q, p);
            q++;
        }
        break;
    }
}

void EFF_VolumeLoop(struct cfg *p)
{
    unsigned int i;
    int d;

    for (i = 0; i < 5; i++) {
        if (ram_4944[i][((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->idx] == 1) {
            d = ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->idx;
            if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type == 0x3f) {
                ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->param[0] -= EFF_VolumeReduction_Steps[((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->param[1]];
                if (((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->param[0] < 0)
                    ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, ((struct slot *)((unsigned long)i * 56 + 8 + (unsigned long)p))->type, d, p);
        }
    }
}
