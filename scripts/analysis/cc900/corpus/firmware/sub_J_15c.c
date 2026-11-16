/* lane_sub helper J, round 15, form c: third spellings of sub_J_15a.c's functions (KN5000 sub-CPU payload v1.42):
   - DSP_Config_Init: the last register address written `ram_100000 = i | 0`.
   - Voice_PortamentoTarget_ComputePitch: the register local s declared between l and w.
   - DSP_ParamInterp_Div0xC6: r = q * t; r = r + (v0 >> 8).
   - DSP_MixSendConfig: the callee declared to return plain char *, its result cast to unsigned char *.

   cc900-module: ToneGen_WriteGlobalConfig ToneGen_WriteVoiceParams ToneGen_WriteSingleReg
   cc900-module: ToneGen_WriteExtParams_15 ToneGen_WriteExtParams_56 ToneGen_WriteExtParams_56b */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern unsigned int __near ram_2aa4[];
extern unsigned char ToneGen_GlobalConfig_Defaults[];
extern unsigned int ToneGen_VoiceParamShadow_Defaults[];
extern unsigned char ram_41368[];
extern unsigned long ram_45310;                 /* ToneDB_RelBase */
extern unsigned char *ram_45314;                /* ToneDB_RootPtr */

struct shadow { unsigned int w[34]; };
struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };

extern void ToneGen_WriteGlobalConfig(unsigned char *cfg);
extern void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern char *ToneDB_Find_ToneRecord(unsigned int, unsigned int);

void DSP_Config_Init(void)
{
    unsigned int i;
    unsigned int *q;
    unsigned int *p;
    ToneGen_WriteGlobalConfig(ToneGen_GlobalConfig_Defaults);
    q = ram_2aa4;
    p = q;
    *(struct shadow *)q = *(struct shadow *)ToneGen_VoiceParamShadow_Defaults;
    for (i = 0; i < 0x40; i++) {
        ram_18 &= ~0x80;
        ram_100000 = i + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ToneGen_WriteVoiceParams(i, p);
        ToneGen_WriteSingleReg(i, *p);
        ram_18 &= ~0x80;
        ram_100000 = i + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0xc0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i | 0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0x7e00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ToneGen_WriteExtParams_15(i, p);
        ToneGen_WriteExtParams_56(i, p);
        ToneGen_WriteExtParams_56b(i, p);
    }
}

void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    struct pslot3 *s;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    s = (struct pslot3 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e];
    s->pitch = (unsigned long)w * k + l + ram_45310;
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    long q;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    r = q * t;
    r = r + (v0 >> 8);
    *pp = p;
    return r;
}

void DSP_MixSendConfig(unsigned int a, unsigned int c, unsigned char *d)
{
    unsigned int n;
    unsigned int i;
    unsigned char *s;
    s = (unsigned char *)ToneDB_Find_ToneRecord(a, c);
    n = 0x11;
    for (i = 0; i < n; i++)
        *d++ = *s++;
}
