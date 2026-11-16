/* lane_sub helper E, round 9, form b: other spellings of sub_E_9a.c's functions (sub-CPU payload v1.42): the quotient
   reused as the result with the divisor's address taken (to keep it on the stack), a void * record parameter, the
   message address converted through an integer, the serial byte in an unsigned local. */

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

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    q = (v0 >> 8) + q * *&t;
    *pp = p;
    return q;
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, void *p)
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
                InterCPU_DMA_Send(2, 3, (void *)(unsigned long)ram_4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (void *)(unsigned long)ram_4a42);
        }
    }
}

int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    unsigned int c;

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
