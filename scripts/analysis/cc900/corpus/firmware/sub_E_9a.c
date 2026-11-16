/* lane_sub helper E, round 9, form a: KN5000 sub-CPU payload v1.42 (v142/subcpu).  Round 8's closest misses:
   the result local declared before the quotient (Div0xC6), round 7's integer record address with a char-pointer
   parameter (WriteParameter), a converted constant message address (ToneGen_Process_Notes), the serial byte in an
   int local (Serial1_DataTransmit_Loop), the masked value used through its assignment (Div0xB4). */

/* cc900-module: Keybed_Read_Event SAVE_BYTE_TO_RING_BUFFER Serial1_Enable_TX_Interrupt Serial1_HandleEnableCommand */

struct bcfg { int a; int b; int c; int d; long e; };

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
extern unsigned int Keybed_Read_Event(unsigned char *ev);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, void *buf);
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(int c);

long DSP_ParamInterp_Div0xB4(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    r = (v = (v >> 8) & 0xffffff) * b / 0xb4;
    *pp = p;
    return r;
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    long r;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    r = (v0 >> 8) + q * t;
    *pp = p;
    return r;
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, unsigned char *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
    }
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
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        }
    }
}

int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    int c;

    while (n--) {
        if (!(ram_1034 & 4)) {
            c = *p++;
            Serial1_HandleEnableCommand(c);
        } else {
            c = *p++;
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, c);
            Serial1_Enable_TX_Interrupt();
        }
    }
    return 0;
}
