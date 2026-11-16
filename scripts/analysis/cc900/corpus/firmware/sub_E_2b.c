/* lane_sub helper E, round 2, form b: other spellings of sub_E_2a.c's functions (sub-CPU payload v1.42):
   case order reversed in the switches, the other operand order in the byte-assembly sums, DSP_DispatchData
   with an unsigned char parameter instead of a cast, void * message pointers, early returns. */

struct bcfg { int a; int b; int c; int d; long e; };
struct dspstate { int w[0x90]; int busy; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2]; };

extern unsigned char __tiny ram_1c;                           /* P7 */
extern unsigned char __tiny ram_44;                           /* PH */

extern struct bcfg ToneGen_WorkArea[];
extern struct bcfg DSP_Bytecode_Global_Config[];
extern unsigned char EFF_SlotToChip_Table[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];
extern struct dspstate ram_45324;
extern struct dspstate ram_45446;

extern int DSP_DispatchData(unsigned char d, int chip);
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, unsigned char *desc, unsigned char *rec,
                                     int v, unsigned char *vals);
extern void DSP_State_ApplyAll(struct dspstate *s);
extern void Kernel_StartTask(int n);
extern void MsgQueue_Send(int q, void *m);
extern void *MsgQueue_ReceiveBlocking(int q);

void DSP1_Assert_Reset(void) { ram_44 &= 0xfd; }
void DSP2_Assert_Reset(void) { ram_44 &= 0xfb; }
void DSP_Set_Command_Mode(void) { ram_1c &= 0xbf; }
void DSP_Assert_Write(void) { ram_1c &= 0xf7; }
void DSP_Assert_Read(void) { ram_1c &= 0xef; }

long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, long i)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p) {
    case 2:
        r = DSP_FreqParamCurve_Algo2[i];
        break;
    case 1:
        r = DSP_FreqParamCurve_Algo1[i];
        break;
    case 0:
        r = DSP_FreqParamCurve_Algo0[i];
        break;
    }
    p++;
    *pp = p;
    return r;
}

unsigned long DSP_UnpackParam3B(unsigned char **pp)
{
    unsigned char *p;
    unsigned long v;

    p = *pp;
    v = ((long)p[1] << 8) + ((long)p[0] << 16) + p[2];
    *pp = p + 3;
    return v;
}

char *DSP_StreamDecode_3ByteWord(char *p, long *out)
{
    long a;

    a = ((long)*p++ << 24) & 0xff000000;
    *out = a + (((long)*p++ << 16) & 0xff0000) + (((long)*p++ << 8) & 0xff00);
    return p;
}

unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out)
{
    unsigned char *next;
    unsigned int w;

    while (((w = p[1] + ((unsigned int)p[0] << 8)) >> 8) != 0xf0) {
        next = p + w;
        p += 2;
        if (*p == key) {
            p += len + 1;
            if (p >= next) *out = 4;
            else *out = 0;
            return p;
        }
        p = next;
    }
    *out = 3;
    return p;
}

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;

    while (((w = p[1] + ((unsigned int)p[0] << 8)) >> 8) != 0xf0) {
        if (n == 0) {
            *st = 0;
            *out = p + w;
            p += 2;
            return p;
        }
        p += w;
        n--;
    }
    *st = 2;
    return p;
}

void DSP_WriteParamWord(long v, int chip)
{
    DSP_DispatchData((v >> 16) & 0xff, chip);
    DSP_DispatchData((v >> 8) & 0xff, chip);
}

void DSP_WriteCoeffData_5B(long v, int chip)
{
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((v >> 17) & 0x7f, chip);
    DSP_DispatchData((v >> 9) & 0xff, chip);
    DSP_DispatchData((v >> 1) & 0xff, chip);
    DSP_DispatchData(((v << 7) & 0x80) + 0x15, chip);
}

void DSP_WriteCoeffData_5B_Direct(long v, int chip)
{
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((v >> 17) & 0x7f, chip);
    DSP_DispatchData((v >> 9) & 0xff, chip);
    DSP_DispatchData((v >> 1) & 0xff, chip);
    DSP_DispatchData(((v << 7) & 0x80) + 0x26, chip);
}

void DSP_WriteOscParam_Offset(unsigned int a, long v, int chip, long off, unsigned int base)
{
    DSP_DispatchData(8, chip);
    DSP_DispatchData(1, chip);
    DSP_DispatchData(((a + base) >> 4) & 0xf, chip);
    DSP_DispatchData((((a + base) << 4) & 0xf0) + 8, chip);
    DSP_DispatchData(0x25, chip);
    v += off;
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((v >> 17) & 0x7f, chip);
    DSP_DispatchData((v >> 9) & 0xff, chip);
    DSP_DispatchData((v >> 1) & 0xff, chip);
    DSP_DispatchData(((v << 7) & 0x80) + 0x4c, chip);
}

int DSP_WriteEFFConfig(unsigned int slot, unsigned char *code)
{
    return DSP_BytecodeInterpreter_Init(EFF_SlotToChip_Table[slot], slot, ToneGen_WorkArea, code);
}

int DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    return DSP_BytecodeInterpreter_Init(chip, 0, DSP_Bytecode_Global_Config, code);
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, p->e[slot].f, v,
                                     DSP_EffA_Param_Values);
            break;
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, p->e[slot].f, v,
                                     DSP_Eff9_Param_Values);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], p->e[slot].f, v,
                                 DSP_Param_Block_Ptrs_A[type]);
    }
}

void DSP_State_DmaLoadPresets(void)
{
    Kernel_StartTask(3);
    MsgQueue_Send(1, &ram_45324);
    MsgQueue_Send(1, &ram_45446);
}

void DSP_State_ApplyTask(void)
{
    struct dspstate *p;

    while (1) {
        p = MsgQueue_ReceiveBlocking(2);
        DSP_State_ApplyAll(p);
        p->busy = 0;
        MsgQueue_Send(1, p);
    }
}

int __cdecl Audio_CmdHandler_40_5F(unsigned char n, unsigned char *d)
{
    unsigned char i;

    i = n;
    while (i-- != 0)
        ;
    return 0;
}
