/* lane_sub helper J, round 15, form a: the four round-14 misses of the KN5000 sub-CPU payload v1.42 (v142/subcpu),
   each started from its best round-14 spelling and changed only where its new first difference is:
   - DSP_Config_Init (sub_J_14c, +37): the loop body is 2 bytes short: the ROM writes the last register address as
     `ld wa,iz` + `ld (latch),wa`, V4.23 stores IZ straight; written `ram_100000 = i + 0`.
   - Voice_PortamentoTarget_ComputePitch (sub_J_14c, +99): the ROM keeps the slot record in XBC and stores through
     (XBC+8): a register local s receives the record pointer, then s->pitch is stored; s declared last.
   - DSP_ParamInterp_Div0xC6 (sub_J_14b, +91): the ROM's result lives in XHL, the register of the multiply's result:
     r = q * t first, then r = (v0 >> 8) + r (the old r copied to XWA, v0 >> 8 built in XHL).
   - DSP_MixSendConfig (sub_J_14c, +7): V4.23 leaves the result pointer in XHL (the call's register), the ROM copies it
     to XBC; the callee declared to return unsigned long and its result cast, locals n, i, s.

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
extern unsigned long ToneDB_Find_ToneRecord(unsigned int, unsigned int);

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
        ram_100000 = i + 0;
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
    unsigned int w;
    struct pslot3 *s;
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
    r = (v0 >> 8) + r;
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
