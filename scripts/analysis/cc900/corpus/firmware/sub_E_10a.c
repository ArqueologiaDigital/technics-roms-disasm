/* lane_sub helper E, round 10, form a: KN5000 sub-CPU payload v1.42 (v142/subcpu), core/14_dsp_control_routines.s, at
   -Xr.  Round 9's near misses: the message address passed as an integer (ToneGen_Process_Notes: the ROM loads
   `ld xde,0x4a42` first), the record address as a char-pointer sum with the field taken through a struct pointer
   (DSP_WriteParameter: the ROM has the base in XIX and `lda xbc,(xde+4)`), an unused local beside the reused
   quotient (DSP_ParamInterp_Div0xC6). */

/* cc900-module: Keybed_Read_Event */

struct bcfg { int a; int b; int c; int d; long e; };
struct pent { char pad[4]; unsigned char f[52]; };

extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
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
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned long buf);

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
                                     ((struct pent *)(p + ((unsigned long)slot * 56 + 8)))->f);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     ((struct pent *)(p + ((unsigned long)slot * 56 + 8)))->f);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, ((struct pent *)(p + ((unsigned long)slot * 56 + 8)))->f);
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
                InterCPU_DMA_Send(2, 3, (unsigned long)ram_4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned long)ram_4a42);
        }
    }
}
