/* lane_sub helper E, round 8, form b: other spellings of sub_E_8a.c's functions (sub-CPU payload v1.42): the
   pitch offset added in its own statement, a `register` quotient, a char-pointer record parameter, the message
   bytes as plain cells with a void * conversion, the serial byte passed with an unprototyped callee. */

/* cc900-module: Keybed_Read_Event SAVE_BYTE_TO_RING_BUFFER Serial1_Enable_TX_Interrupt Serial1_HandleEnableCommand */

struct bcfg { int a; int b; int c; int d; long e; };

extern unsigned char __near ram_4a42;
extern unsigned char __near ram_4a43;
extern unsigned char __near ram_4a44;
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
extern unsigned int Keybed_Read_Event(unsigned char *ev);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, void *buf);
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand();

long DSP_PitchParam_Scale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    r = (b << 21) / v << 2;
    r += (long)0xff800000;
    *pp = p;
    return r;
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    register long q;

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

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, unsigned char *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     p + ((unsigned long)slot * 56 + 8) + 4);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     p + ((unsigned long)slot * 56 + 8) + 4);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, p + ((unsigned long)slot * 56 + 8) + 4);
    }
}

void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (void *)&ram_4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (void *)&ram_4a42);
        }
    }
}

int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    while (n--) {
        if (!(ram_1034 & 4)) {
            Serial1_HandleEnableCommand((int)*p++);
        } else {
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, *p++);
            Serial1_Enable_TX_Interrupt();
        }
    }
    return 0;
}
