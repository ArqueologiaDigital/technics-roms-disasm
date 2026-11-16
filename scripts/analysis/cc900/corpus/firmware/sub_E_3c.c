/* lane_sub helper E, round 3, form c: third spellings of sub_E_3a.c's functions (sub-CPU payload v1.42):
   the locals of DSP_StreamDecode_3ByteWord in the other order without a pointer copy, a local copy of the record
   pointer in DSP_WriteParameter, two statements in DSP_State_LoadAndApplyAll. */

struct bcfg { int a; int b; int c; int d; long e; };
struct dspstate { int w[0x90]; int busy; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2]; };

extern struct dspstate *__near ram_4a3e;
extern int ram_45324[];
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];

extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *rec,
                                     int v, void *vals);
extern void DSP_State_ApplyAll(struct dspstate *s);

char *DSP_StreamDecode_3ByteWord(char *p, long *out)
{
    long c;
    long b;
    long a;

    a = ((long)*p++ << 24) & 0xff000000;
    b = ((long)*p++ << 16) & 0xff0000;
    c = ((long)*p++ << 8) & 0xff00;
    *out = a + b + c;
    return p;
}

void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    ram_4a3e = (struct dspstate *)ram_45324;
    *ram_4a3e = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    struct pblk *q;

    q = p;
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, q->e[slot].f, v,
                                     DSP_Eff9_Param_Values);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, q->e[slot].f, v,
                                     DSP_EffA_Param_Values);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], q->e[slot].f, v,
                                 DSP_Param_Block_Ptrs_A[type]);
    }
}
