/* lane_sub helper E, round 8, form a: KN5000 sub-CPU payload v1.42 (v142/subcpu), core/14_dsp_control_routines.s,
   subcpu_data_tables.s.  Round 7's near misses and the 3-byte decoder callers whose round-5 listings looked right but
   could not be checked (`and QWA,0xff` did not assemble in the checker's translation). */

/* cc900-module: Keybed_Decode_Event Keybed_Read_Event SAVE_BYTE_TO_RING_BUFFER Serial1_Enable_TX_Interrupt Serial1_HandleEnableCommand */

struct bcfg { int a; int b; int c; int d; long e; };
struct pblk;

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern int ram_110002;
extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned char __near ram_1034;                         /* SERIAL_1_VAR_1034 */
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];

extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
extern void Keybed_Decode_Event(unsigned char *ev, unsigned char d);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, void *buf);
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(unsigned int c);

long DSP_ParamInterp_FPScale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    r = b * 0xac44 / 0x3e8 + v;
    *pp = p;
    return r;
}

long DSP_ParamInterp_Div0xB4(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    r = v * b / 0xb4;
    *pp = p;
    return r;
}

long DSP_PitchParam_Scale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    r = ((b << 21) / v << 2) + 0xff800000;
    *pp = p;
    return r;
}

long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    r = (c + v0 + ((v1 = (v1 >> 8) & 0xffffff) - v0) * b / 0x63) << 8;
    *pp = p;
    return r;
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    volatile long t;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    q = (v0 >> 8) + q * t;
    *pp = p;
    return q;
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     &((unsigned char *)p)[(unsigned long)slot * 56 + 8] + 4);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     &((unsigned char *)p)[(unsigned long)slot * 56 + 8] + 4);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, &((unsigned char *)p)[(unsigned long)slot * 56 + 8] + 4);
    }
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned int d;
    int st;
    unsigned char hi;
    unsigned char lo;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = d & 0xff;
        hi = (d >> 8) & 0xff;
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

void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, ram_4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, ram_4a42);
        }
    }
}

int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    while (n--) {
        if (!(ram_1034 & 4)) {
            Serial1_HandleEnableCommand(*p++);
        } else {
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, *p++);
            Serial1_Enable_TX_Interrupt();
        }
    }
    return 0;
}
